classdef SparseLeastSquaresTDLearningCorrectRegularizer < PolicyEvaluation.LeastSquaresTDLearningCorrectRegularizer
    
    methods (Static)
        function [learner] = CreateFromTrialLearnVFunction(trial)
            
            stateFeatureName = trial.stateFeatures.outputName;
            nextStepFeatureName = trial.nextStateFeatures.outputName;
            learner = PolicyEvaluation.SparseLeastSquaresTDLearningCorrectRegularizer(trial.dataManager,trial.policyEvaluationFunction, stateFeatureName, nextStepFeatureName);
        end
        
        function [learner] = CreateFromTrialLearnQFunction(trial)
            
            stateFeatureName = trial.stateActionFeatures.outputName;
            nextStepFeatureName = trial.nextStateActionFeatures.outputName;
            rewardName = 'rewards';
            if (isprop(trial,'rewardName'))
                rewardName = trial.rewardName;
            end
            if (isprop(trial,'useImportanceSampling') && trial.useImportanceSampling && isempty(findstr(class(trial.nextStateActionFeatures),'CurrentPolicy')))
                learner = PolicyEvaluation.SparseLeastSquaresTDLearningCorrectRegularizer(trial.dataManager,trial.policyEvaluationFunction, stateFeatureName, nextStepFeatureName, rewardName, 'importanceWeights');
            else
                learner = PolicyEvaluation.SparseLeastSquaresTDLearningCorrectRegularizer(trial.dataManager,trial.policyEvaluationFunction, stateFeatureName, nextStepFeatureName, rewardName);
            end
        end
    end
    
    methods
        %%
        function obj = SparseLeastSquaresTDLearningCorrectRegularizer(dataManager, functionApproximator, stateFeatures, nextStateFeatures, rewardName, varargin)
            
            obj = obj@PolicyEvaluation.LeastSquaresTDLearningCorrectRegularizer (dataManager, functionApproximator, stateFeatures, nextStateFeatures, rewardName, varargin{:});
        end
        
        
        function [theta] = learnLSTDInternal(obj, currentFeatures, currentFeaturesWeighted, nextFeatures, rewards)
            valid = sum(currentFeatures)+sum(nextFeatures);
            
            theta = zeros(size(currentFeatures,2),1);
            
            currentFeatures = sparse(currentFeatures(:,valid~=0));
            currentFeaturesWeighted = sparse(currentFeaturesWeighted(:,valid~=0));
            nextFeatures = sparse(nextFeatures(:,valid~=0));
                      
            regMat1 = speye(size(currentFeatures,2)) * obj.lstdRegularizationFactor;
            regMat2 = speye(size(currentFeatures,2)) * obj.lstdProjectionRegularizationFactor;
            if (obj.useBias)
                regMat1(1,1) = 10^-6;
                regMat2(1,1) = 0;
            end
            
            obj.projector = (currentFeaturesWeighted' * currentFeatures + regMat2) \ currentFeaturesWeighted';
            if sum(sum(isnan(obj.projector)))>0
                obj.projector = pseudoinverse(currentFeaturesWeighted' * currentFeatures + regMat2) * currentFeaturesWeighted';
            end
            M = (currentFeatures - obj.discountFactor * currentFeatures * (obj.projector * nextFeatures));
            if (obj.useBias)
                theta(valid~=0) = (M' * M + regMat1) \ M' * (rewards - M(:,1) * obj.lstdBiasPrior);
                theta(1) = theta(1) + obj.lstdBiasPrior;
            else
                theta(valid~=0) = (M' * M + regMat1) \ M' * rewards;
            end
        end
        
        
    end
end

