classdef KMeansLearner < Learner.AbstractInputOutputLearnerInterface & Data.DataManipulator
    
    
    properties
        numClasses
        learner
    end
    
    properties (SetObservable,AbortSet)
        

        isDebug             = false;
        respName            = 'outputResponsibilities';
        learnOutputShape    = false;
        learnInputShape     = true;
        useWhitening    = true;


    end
    
    % Class methods
    methods
        function obj = KMeansLearner(dataManager, learner, respName,  varargin)
            obj = obj@Data.DataManipulator(dataManager);
            obj = obj@Learner.AbstractInputOutputLearnerInterface(dataManager, learner.functionApproximator, varargin{:});
            
            if(~exist('respName','var') || isempty(respName) )
                obj.respName = 'outputResponsibilities';
            else
                obj.respName = respName;
            end
            
            obj.setTakesData('learnFunction', true);
            obj.learner     = learner;
            
            obj.numClasses = obj.functionApproximator.numOptions;
            
            obj.linkProperty('isDebug', 'DebugMode');
            obj.linkProperty('learnOutputShape', 'learnOutputShapeKMeans');
            obj.linkProperty('learnInputShape', 'learnInputShapeKMeans');
            obj.linkProperty('useWhitening', 'useWhiteningKMeans');
            
            
            obj.registerLearnFunction();
            
        end
        
        
        
        function [] = setWeightName(obj, weightName)
            obj.setWeightName@Learner.AbstractInputOutputLearnerInterface(weightName);
            
            obj.learner.setWeightName(weightName);
        end
        
        function [] = learnFunction(obj, data, inputData, outputData, weighting)
            if (~exist('weighting', 'var') || sum(weighting)==0 )
                weighting = ones(size(outputData,1),1);
            end
            
            allData = zeros(size(outputData,1),0);
            
            if(obj.learnInputShape)                                
                allData = [allData, inputData];                            
            end
            if(obj.learnOutputShape)                                
                allData = [allData, outputData];                            
            end
           
            if(isempty(allData))
                error('Neither learnInputShape nor learnOutputShape is true');
            end
            
            
            
            
            dataRange       = range(allData);
            minData         = min(allData);
            
            %Centers = [class, position]
            %Randomly initialize centers within data range
            centers     = rand(obj.numClasses, size(allData,2));
            if(obj.useWhitening)
                allData     = bsxfun(@minus, allData, minData);
                allData     = bsxfun(@rdivide, allData, dataRange);
            else
                centers     = bsxfun(@plus, bsxfun(@times, centers, dataRange),  minData);
            end

%             centers     = sort(centers,1);
            centersNew      = zeros(obj.numClasses, size(allData,2));

            
            weightedData    = bsxfun(@times, allData, weighting);
            
            
            err         = inf;
            iter        = 0;
            while (err > 1e-3 && iter < 1e3)
                %diff = [sampleIdx, position, classIdx]
                %Stores the squared distance per dimension from each class center to each
                %sample
                diff = bsxfun(@minus, allData, permute(centers, [3, 2, 1]));
                diff = diff.^2;
                
                
                %Dist stores the squared distance, permute to drop
                %singleton dimension (faster than squeeze).
                %dist = [sampleIdx, optionIdx]
                dist = sum(diff,2);
                dist = permute(dist, [1, 3 , 2]);
                
                [~, oIdx] = min(dist,[],2);
                for o = 1 : obj.numClasses
                    if(sum(oIdx==o) > 0)
                        centersNew(o,:) = sum(weightedData(oIdx==o,:))/ sum(weighting(oIdx==o,:));
                    else
                        %Randomly assign new position to sad centers that
                        %didn't get anything.
                        centersNew(o,:) = rand(1, size(allData,2));
                        if(~obj.useWhitening)
                            centersNew(o,:) = centersNew(o,:) .* dataRange +  minData;
                        end
                    end
                end
                err    = centersNew - centers;
                err    = sum(abs(err(:)));
                centers  = centersNew;
                
                iter     = iter + 1;
            end
            
            responsibilities = zeros(size(allData,1),obj.numClasses);
            for o = 1 : obj.numClasses
                idx = oIdx==o;
                responsibilities(idx,o) = 1;
            end
            
            data.setDataEntry(obj.respName, responsibilities);
            
            obj.learner.updateModel(data);
            
            
        end
        
        
    end
    
    methods (Access = protected)
        function [] = registerLearnFunction(obj)
            if (isempty(obj.inputVariables))
                inputVariablesTemp = {''};
            else
                inputVariablesTemp = obj.inputVariables;
            end
            obj.addDataManipulationFunction('learnFunction', {inputVariablesTemp{:}, obj.outputVariable, obj.weightName{:}}, {});
            obj.setTakesData('learnFunction', true);
        end
        
    end
    
        
end


%%

