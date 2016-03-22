classdef GPHyperParameterLearnerTestSetLikelihood < Kernels.Learner.GPHyperParameterLearner
    % The test set is everything all points that are not in the reference
    % set
    
    properties               
        useOnlyTestData = true;
        indexTestData = [];        
    end
    
    properties (SetObservable, AbortSet)
        numFolds = 2
    end
    
    methods (Static)
        function [kernelLearner] = CreateFromTrial(trial, gpName)
            kernelLearner = Kernels.Learner.GPHyperParameterLearnerTestSetLikelihood(trial.dataManager, trial.(gpName));
        end
        
        function [kernelLearner] = CreateWithStandardReferenceSet(dataManager, GP)
            referenceSetLearner = Kernels.Learner.RandomKernelReferenceSetLearner(dataManager, GP);
            kernelLearner = Kernels.Learner.GPHyperParameterLearnerTestSetLikelihood(dataManager, GP, referenceSetLearner);
        end
    end
    
    
    methods
        function obj = GPHyperParameterLearnerTestSetLikelihood(dataManager, gp, gpReferenceSetLearner)
            obj = obj@Kernels.Learner.GPHyperParameterLearner(dataManager, gp, gpReferenceSetLearner);
            obj.linkProperty('numFolds', ['NumFoldsGPOptimization', upper(gp.outputVariable(1)), gp.outputVariable(2:end)]);
            obj.gpLearner.learnWithReferenceSet = false;
        end        
        
        function [] = learnFinalModel(obj, data)
            if (obj.gpLearner.learnWithReferenceSet)
                inputData = obj.gp.getReferenceSet();
                outputData = obj.gp.getReferenceSetOutputs();
                weighting = obj.gp.getReferenceSetWeights();
            
                obj.gpLearner.learnFunction(inputData, outputData, weighting);
            else
                obj.gpLearner.learnFunction(obj.inputData, obj.outputData, obj.weighting);
            end
        end
        
        function [likelihood, gradient] = objectiveFunction(obj, params)
            if (nargin > 1)
                obj.setParametersToOptimize(params);
            end
            
            numFolds = max(2, obj.numFolds);
            likelihood = 0;
            n_samples = size(obj.inputData,1);
            
            for i = 1:obj.numFolds
                val_start = i;
                val_idx = val_start:numFolds:n_samples;
                train_idx = setdiff(1:n_samples, val_idx);
                
                obj.gpLearner.learnFunction(obj.inputData(train_idx, :), obj.outputData(train_idx, :), obj.weighting(train_idx, :));
                                                    
                likelihood = likelihood + sum(obj.gp.getDataProbabilities(obj.inputData(val_idx,:), obj.outputData(val_idx,obj.gp.getDimIndicesForOutput())) .* obj.weighting(val_idx));                    
            end
        end
        
        function [] = processTrainingData(obj, data)
            obj.processTrainingData@Kernels.Learner.GPHyperParameterLearner(data);                                   
            
            if (obj.useOnlyTestData)
                referenceSetIdx = obj.gp.getReferenceSetIndices();
                obj.indexTestData = true(size(obj.weighting,1),1);
                obj.indexTestData(referenceSetIdx) = false;                
            else
                obj.indexTestData = true(size(obj.weighting,1),1);
            end
                                    
            %obj.inputDataTest = obj.inputData(obj.indexTestData,:);
            %obj.outputDataTest = obj.outputData(obj.indexTestData,obj.gp.getDimIndicesForOutput());
            %obj.weightingTest = obj.weighting(obj.indexTestData);
            
        end
        
                
      
    end
        
end

