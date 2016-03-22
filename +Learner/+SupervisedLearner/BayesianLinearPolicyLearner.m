classdef BayesianLinearPolicyLearner < Learner.SupervisedLearner.SupervisedLearner & Learner.ParameterOptimization.HyperParameterObject
    % The BayesianLinearPolicyLearner is a Learner.SupervisedLearner.SupervisedLearner
    % that will model a learner via weighted linear regression where the
    % output variance is a quadratic of the input features
    
    properties
        additionalInputVariables = {}
    end
    
    properties(SetObservable, AbortSet)     
        minRelWeight = 1e-3
    end
    
  
    % Class methods
    methods
        function obj = BayesianLinearPolicyLearner(dataManager, functionApproximator, varargin)
            obj = obj@Learner.SupervisedLearner.SupervisedLearner(dataManager, functionApproximator, varargin{:});
           
        end
                
        function [] = learnFunction(obj, inputData, outputData, weighting)
            % @param inputData input data of the training set
            % @param outputData output data of the training set
            % @param weighting weighting for each datapoint
            
            if (~exist('weighting', 'var'))
                weighting = ones(size(inputData,1),1);
            end
            weighting = weighting / max(weighting);  
            
            FA = obj.functionApproximator;
            
            alpha = 1 / FA.priorVariance;
            beta = 1/ FA.regularizer;
            D = size(inputData,2);
            cholA = chol(alpha*eye(D) + beta * inputData' * diag(weighting) * inputData);
            weights = beta * (cholA \ (cholA' \ inputData' * diag(weighting) * outputData));
            
            
            FA.setSigma(cholA)
            FA.setWeightsAndBias(weights, 0)
            
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
