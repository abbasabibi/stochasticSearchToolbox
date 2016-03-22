classdef InitMMLearner < Learner.Learner & Data.DataManipulator
    % The Learner.Learner class serves as a base class for all learners and predefines all necessary methods.
    
    properties (SetObservable,AbortSet)
        doKMeansInit            = true;
        keepOptionsShape        = true;
        KMeansUseTrainingData   = true;
        numInitStates           = 200;
        
    end
    
    properties
        mixtureModelLearner
    end
    
    % Class methods
    methods
        function obj = InitMMLearner (dataManager, mixtureModelLearner )
            obj = obj@Learner.Learner();
            obj = obj@Data.DataManipulator(dataManager);
            
            obj.mixtureModelLearner = mixtureModelLearner;
            
            obj.linkProperty('doKMeansInit');
            obj.linkProperty('keepOptionsShape');
            obj.linkProperty('numInitStates', 'numInitStatesKMeans');
        end
        
        
        function obj = updateModel(obj, data)
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%
            if(obj.doKMeansInit )
                
                if(obj.keepOptionsShape)
                    for i = 1 : length(obj.mixtureModelLearner.functionApproximator.options)
                        storedBias{i} = obj.mixtureModelLearner.functionApproximator.options{i}.bias;
                        storedWeights{i} = obj.mixtureModelLearner.functionApproximator.options{i}.weights;
                        storeCov{i} = obj.mixtureModelLearner.functionApproximator.options{i}.cholA;
                    end
                end

                
                % initContexts    = bsxfun(@times, (rand(numInitStates, dataManager.getNumDimensions('contexts'))-0.5) , dataManager.getRange('contexts'));
                inputVar        = obj.mixtureModelLearner.functionApproximator.inputVariables{1};
                outputVar       = obj.mixtureModelLearner.functionApproximator.outputVariable; % 'parameters'
                
                if( obj.KMeansUseTrainingData && data.dataStructure.numElements > 0)
                    initParams      = data.getDataEntry(outputVar);
                    initContexts    = data.getDataEntry(inputVar);
                    numInitStates   = size(initContexts,1);
                    
                else          
                    numInitStates   = obj.numInitStates;
                    initParams      = bsxfun(@times, (rand(numInitStates, obj.dataManager.getNumDimensions(outputVar))) ,...
                        obj.dataManager.getRange(outputVar));
                    initParams      = bsxfun(@plus, initParams, obj.dataManager.getMinRange(outputVar) );

                    
                    initContexts    = bsxfun(@times, (rand(numInitStates, obj.dataManager.getNumDimensions(inputVar))), ...
                        obj.dataManager.getRange(inputVar));
                    initContexts    = bsxfun(@plus, initContexts, obj.dataManager.getMinRange(inputVar) );
                end
                
%                 subManager      = obj.dataManager.getDataManagerForDepth( ...
%                     obj.dataManager.getDataEntryDepth(outputVar) );
                
%                 initData        = subManager.getDataObject(numInitStates);
                initData        = obj.dataManager.getDataObject(numInitStates);
                initData.setDataEntry(inputVar,initContexts);
                initData.setDataEntry(outputVar,initParams);

                if(~isempty(obj.mixtureModelLearner.weightName))
                    initData.setDataEntry(obj.mixtureModelLearner.weightName{1}, ones(numInitStates,1));
                end
                
                
                KMeansLearner   = Learner.ClassificationLearner.KMeansLearner(...
                    obj.dataManager, obj.mixtureModelLearner, obj.mixtureModelLearner.respName, [], inputVar);
                KMeansLearner.callDataFunction('learnFunction', initData);
                
                %This only adapts the gating but keeps the initialization
                %of the policies
                if(obj.keepOptionsShape)
                    for i = 1 : length(obj.mixtureModelLearner.functionApproximator.options)
                        obj.mixtureModelLearner.functionApproximator.options{i}.setWeightsAndBias(storedWeights{i}, storedBias{i});
                        obj.mixtureModelLearner.functionApproximator.options{i}.setSigma(storeCov{i});
                    end
                end
                
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%
            
        end
        
    end
end
