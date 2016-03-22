classdef InitGMMLearner < Learner.Learner & Data.DataManipulator & Learner.AbstractInputOutputLearnerInterface
    % The Learner.Learner class serves as a base class for all learners and predefines all necessary methods.
    
    properties (SetObservable,AbortSet)
        doKMeansInit = true;
        keepOptionsShape = false;
        
    end
    
    properties
        mixtureModelLearner
        KMeansLearner
    end
    
    % Class methods
    methods
        function obj = InitGMMLearner (dataManager, mixtureModelLearner )
            obj = obj@Learner.Learner();
            obj = obj@Data.DataManipulator(dataManager);
            obj = obj@Learner.AbstractInputOutputLearnerInterface(dataManager, mixtureModelLearner.functionApproximator);
            
            obj.mixtureModelLearner = mixtureModelLearner;
            
            obj.linkProperty('doKMeansInit');
            obj.linkProperty('keepOptionsShape');
            
            obj.KMeansLearner   = Learner.ClassificationLearner.KMeansLearner(...
                obj.dataManager, obj.mixtureModelLearner, obj.mixtureModelLearner.respName);
            obj.KMeansLearner.learnOutputShape = true;
        end
        
        function [] = setWeightName(obj, weightName)
            obj.setWeightName@Learner.AbstractInputOutputLearnerInterface(weightName);
            
            obj.KMeansLearner.setWeightName(weightName);
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
                
                
                
                obj.KMeansLearner.callDataFunction('learnFunction', data);
                
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
