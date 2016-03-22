classdef LSTDFeatureLearnerTD2 < PolicyEvaluation.FeatureLearner.LSTDFeatureLearner
    
    properties(SetObservable,AbortSet)        
    end
    
    properties(SetAccess=protected)
 
    end     
    
    methods (Static)
        function [obj] = CreateFromTrial(trial)
            obj = PolicyEvaluation.FeatureLearner.LSTDFeatureLearnerTD2(trial.dataManager, trial.policyEvaluationLearner, 'stateActionFeatures', 'nextStateActionFeatures', trial.policyEvaluationFunction, trial.stateActionKernelReferenceSetLearner, 'rewards');
        end
    end
    
    methods
        %%
        function obj = LSTDFeatureLearnerTD2(dataManager, lstdLearner, currentFeatureName, nextFeatureName, qFunction, varargin)
                        
            obj = obj@PolicyEvaluation.FeatureLearner.LSTDFeatureLearner(dataManager, lstdLearner, currentFeatureName, nextFeatureName, qFunction, varargin{:});                        
        end
                
        function [error]  = errorFunction(obj, rewards, features, nextFeatures)
                       
            tdError = rewards + obj.discountFactor * obj.qFunction.getExpectation(size(nextFeatures,1), nextFeatures) - ... 
                obj.qFunction.getExpectation(size(nextFeatures,1), features);
            
            error = - sum(tdError.^2);
        end                                
                
    end
end

