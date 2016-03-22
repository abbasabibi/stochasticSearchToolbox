classdef LSTDFeatureLearnerMSPBE < PolicyEvaluation.FeatureLearner.LSTDFeatureLearner
    
    properties(SetObservable,AbortSet)
        lstdProjectionRegularizationFactor = 10^-6;
    end
    
    properties(SetAccess=protected)
 
    end     
    
    methods (Static)
        function [obj] = CreateFromTrial(trial, featureName)
            currentFeatures = [featureName, 'Features'];
            nextFeatures = ['next', upper(featureName(1)), featureName(2:end), 'Features'];
            referenceSetLearner = [featureName, 'KernelReferenceSetLearner'];
            
            obj = PolicyEvaluation.FeatureLearner.LSTDFeatureLearnerMSPBE(trial.dataManager, trial.policyEvaluationLearner, currentFeatures, nextFeatures, ...
                trial.policyEvaluationFunction, trial.(referenceSetLearner), 'rewards');
        end
    end
    
    methods
        %%
        function obj = LSTDFeatureLearnerMSPBE(dataManager, lstdLearner, currentFeatureName, nextFeatureName, qFunction, varargin)
                        
            obj = obj@PolicyEvaluation.FeatureLearner.LSTDFeatureLearner(dataManager, lstdLearner, currentFeatureName, nextFeatureName, qFunction, varargin{:});                        
        end
                
        function [error]  = errorFunction(obj, rewards, features, nextFeatures)
            predictedValue = obj.discountFactor * obj.qFunction.getExpectation(size(nextFeatures,1), nextFeatures);
            currentValue = obj.qFunction.getExpectation(size(nextFeatures,1), features);
                       
           
            features = [ones(size(features,1),1 ), features];
            regMat2 = speye(size(features,2)) * obj.lstdProjectionRegularizationFactor;
            regMat2(1,1) = 0;
                        
            projector = (features' * features + regMat2) \ features';
          
            projPredictedValue = features * (projector * predictedValue);
                        
            error = - mean( (currentValue -  projPredictedValue - rewards) .^2);
        end        
        
        function [] = setHyperParameters(obj, params)
            obj.setHyperParameters@PolicyEvaluation.FeatureLearner.LSTDFeatureLearner(params(1:end-1));
            obj.lstdProjectionRegularizationFactor = params(end);
            if (isprop(obj.lstdLearner, 'lstdProjectionRegularizationFactor'))
                obj.lstdLearner.lstdProjectionRegularizationFactor = params(end);
            end
        end
        
        function [params] = getHyperParameters(obj)
            params = [obj.getHyperParameters@PolicyEvaluation.FeatureLearner.LSTDFeatureLearner(), obj.lstdProjectionRegularizationFactor];
        end
                
        function [numParams] = getNumHyperParameters(obj)
            numParams = obj.parameterObject.getNumHyperParameters() + 2;
        end
    end
end

