classdef GPLearner < Learner.SupervisedLearner.SupervisedLearner & Learner.ParameterOptimization.HyperParameterObject
    % The LinearFeatureFunctionMLLearner is a Learner.SupervisedLearner.SupervisedLearner
    % that will model a learner via weighted linear regression
    properties(SetObservable, AbortSet)     
        minRelWeight = 1e-3
    end
        
    properties 
        learnWithReferenceSet = true;
        learnWithMean = false;
    end
  
    % Class methods
    methods
        function obj = GPLearner(dataManager, gaussianProcess, varargin)
            obj = obj@Learner.SupervisedLearner.SupervisedLearner(dataManager, gaussianProcess, varargin{:});
           
        end
        
        function [] = setWeightName(obj, weightName)
            obj.functionApproximator.setWeightName(weightName);
            obj.setWeightName@Learner.SupervisedLearner.SupervisedLearner(weightName)
        end
                
        function [] = learnFunction(obj, inputData, outputData, varargin)
            % @param inputData input data of the training set
            % @param outputData output data of the training set
            % @param weighting weighting for each datapoint
            
            GP = obj.functionApproximator;
            
            if obj.learnWithMean
                meanOutput = mean(outputData);
                outputData = outputData - meanOutput;
            else
                outputData = outputData - GP.priorMean;
            end
            
            if (obj.learnWithReferenceSet)
                GP.setReferenceSetMatrices(inputData, outputData, varargin{:});
            end
            
            weightingReferenceSet = GP.getReferenceSetWeights();
            weightingReferenceSet = weightingReferenceSet / max(weightingReferenceSet);
            outputReferenceSet = GP.getReferenceSetOutputs();
                                                           
            K = GP.GPPriorVariance * GP.getKernelMatrix();
            
            GPRegularizerEffective = GP.GPRegularizer;
            counter = 1;
            while true
                
                Ky = K + diag(1./weightingReferenceSet) * GPRegularizerEffective;
                try
                    cholKy = chol(Ky);
                    break;
                catch
                    GPRegularizerEffective = GPRegularizerEffective * 2;
                end
                counter = counter + 1;
                assert(counter < 100);
            end
            
            alpha = cholKy \ (cholKy' \ outputReferenceSet(:, GP.getDimIndicesForOutput()));
           
            if obj.learnWithMean
                GP.setGPModel(alpha, cholKy, meanOutput);
            else
                GP.setGPModel(alpha, cholKy);
            end
            
        end
        
        %%% Hyper Parameter Functions
        
        function [numParams] = getNumHyperParameters(obj)
            numParams = obj.functionApproximator.getNumHyperParameters() ;
        end
        
        function [] = setHyperParameters(obj, params)
            obj.functionApproximator.setHyperParameters(params);
        end
        
        function [params] = getHyperParameters(obj)
            params = [obj.functionApproximator.getHyperParameters()];
        end
        
        function [expParameterTransformMap] = getExpParameterTransformMap(obj)
            expParameterTransformMap = obj.functionApproximator.getExpParameterTransformMap();
        end
    end
    
end
