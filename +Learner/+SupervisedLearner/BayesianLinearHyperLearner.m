classdef BayesianLinearHyperLearner < Learner.ParameterOptimization.AbstractHyperParameterOptimizer
    % Abstract class for learning the parameters of bayesian linear model
    
    properties
       
       functionApproximator

       learner               

       weighting
       rawInputData
       rawInputDataName
       outputData

       varianceFunctionFactor = 1.0;
       varianceNoiseFactor = 0.001;    
       dataManager
    end
    
    properties(SetObservable,AbortSet)             
        kernelMedianBandwidthFactor = 1.0;
    end    
    
    methods
        function obj = BayesianLinearHyperLearner(dataManager, functionApproximator)
            
            learner_local = Learner.SupervisedLearner.BayesianLinearPolicyLearner(dataManager, functionApproximator);
            obj = obj@ Learner.ParameterOptimization.AbstractHyperParameterOptimizer(dataManager, learner_local, ['BayesLinearOptimizer', upper(functionApproximator.outputVariable(1)), functionApproximator.outputVariable(2:end)], true);
            
            obj.dataManager = dataManager;
            
            obj.functionApproximator = functionApproximator;
            obj.learner = learner_local;
            obj.linkProperty('kernelMedianBandwidthFactor');
            
        end     
        
        function inputData = getInputData(obj)
            if(isempty(obj.learner.functionApproximator.featureGenerator))
                inputData = obj.rawInputData;
            else
                
                featureGenerator = obj.learner.functionApproximator.featureGenerator;
            
                inputData = featureGenerator.getFeatures(size(obj.rawInputData,1), obj.rawInputData);
            end
            

        end
        
        function [] = learnFinalModel(obj)
            inputData = obj.getInputData();
            obj.learner.learnFunction(inputData, obj.outputData, obj.weighting);
        end
        
        function [] = setWeightName(obj, weightName)
            obj.learner.setWeightName(weightName);
            
        end

         
                
                        
        function [] = processTrainingData(obj, data)
            if(isempty(obj.learner.functionApproximator.featureGenerator))
                obj.rawInputData = data.getDataEntry(obj.learner.inputVariables{1});
            else
                obj.rawInputData = data.getDataEntry(obj.learner.functionApproximator.featureGenerator.featureVariables{1}{1});
            end
            obj.outputData = data.getDataEntry(obj.learner.outputVariable);
                        
            if (~isempty(obj.learner.weightName))
                obj.weighting = data.getDataEntry(obj.learner.weightName{:});
                obj.weighting = obj.weighting;
            else
                obj.weighting = ones(size(obj.rawInputData,1));                
            end
            obj.weighting = obj.weighting / max(obj.weighting);
           
        end               
        
        function [] = initializeParameters(obj, data)
            if(isprop(obj.functionApproximator.featureGenerator, 'kernel') && ...
                    isprop(obj.functionApproximator.featureGenerator.kernel, 'bandWidth'))
                
                inputFt = obj.learner.functionApproximator.featureGenerator.featureVariables;
                input = cell2mat(data.getDataEntryCellArray(inputFt));
                isPeriodic = obj.dataManager.getPeriodicity(inputFt);

                bandWidth = zeros(1, size(input, 2));
                for i = 1:size(input,2)
                    distances = repmat(input(:,i), 1, size(input,1));
                    distances = (distances - distances');

                    if (isPeriodic(i))
                        distances(distances > pi) = distances(distances > pi) - 2 * pi;
                        distances(distances < - pi) = distances(distances < - pi) + 2 * pi;                    
                    end                
                    distances = distances.^2;

                    bandWidth(i) = sqrt(median(distances(:))) * obj.kernelMedianBandwidthFactor;
                end
                bandWidth(bandWidth == 0) = 1; %catch constant dimensions
                obj.functionApproximator.featureGenerator.kernel.setBandWidth(bandWidth);    
            end
            
            outputVar = max(var(obj.outputData(:)), 10^-8);
            
            obj.functionApproximator.priorVariance = obj.varianceFunctionFactor * outputVar;
            obj.functionApproximator.regularizer = obj.varianceNoiseFactor * outputVar;
            
            obj.learner.updateModel(data);
                        
            % Compute error^2 and set it as initial guess for variance
            inputData = obj.getInputData();
            predOutputData = obj.functionApproximator.getExpectation(size(obj.rawInputData,1), inputData);
            
            weighting = obj.weighting / sum(obj.weighting);            
            biasTerm = ( sum(weighting)^2 - sum(weighting.^2));
            
            % we need the mean in case the functionApproximator is over multiple dimension
            outputVar = mean(sum(bsxfun(@times, (obj.outputData - predOutputData).^2, weighting))) / biasTerm;
            
            obj.functionApproximator.regularizer  = outputVar;
            %assert(false, 'TODO')
        end             
        
    end
    
    methods (Abstract)
%         [funcVal, gradient] = objectiveFunction(obj, params);
    end
    
end

