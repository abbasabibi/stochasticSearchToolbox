classdef LeastSquaresTDLearningCorrectRegularizer < PolicyEvaluation.LeastSquaresTDLearning
    
    properties(SetObservable,AbortSet)
        lstdProjectionRegularizationFactor = 10^-6;
        lstdBiasPrior = -10^4;
    end
    
    properties(SetAccess=protected)
    end
    
    methods (Static)
        function [learner] = CreateFromTrialLearnVFunction(trial)
            
            stateFeatureName = trial.stateFeatures.outputName;
            nextStepFeatureName = trial.nextStateFeatures.outputName;
            learner = PolicyEvaluation.LeastSquaresTDLearningCorrectRegularizer(trial.dataManager,trial.policyEvaluationFunction, stateFeatureName, nextStepFeatureName);
        end
        
        function [learner] = CreateFromTrialLearnQFunction(trial)
            
            stateFeatureName = trial.stateActionFeatures.outputName;
            nextStepFeatureName = trial.nextStateActionFeatures.outputName;
            rewardName = 'rewards';
            if (isprop(trial,'rewardName'))
                rewardName = trial.rewardName;
            end
            if (isprop(trial,'useImportanceSampling') && trial.useImportanceSampling && isempty(findstr(class(trial.nextStateActionFeatures),'CurrentPolicy')))
                learner = PolicyEvaluation.LeastSquaresTDLearningCorrectRegularizer(trial.dataManager,trial.policyEvaluationFunction, stateFeatureName, nextStepFeatureName, rewardName, 'importanceWeights');
            else
                learner = PolicyEvaluation.LeastSquaresTDLearningCorrectRegularizer(trial.dataManager,trial.policyEvaluationFunction, stateFeatureName, nextStepFeatureName, rewardName);
            end
        end
    end
    
    methods
        %%
        function obj = LeastSquaresTDLearningCorrectRegularizer(dataManager, functionApproximator, stateFeatures, nextStateFeatures, rewardName, varargin)
            
            obj = obj@PolicyEvaluation.LeastSquaresTDLearning(dataManager, functionApproximator, stateFeatures, nextStateFeatures, rewardName, varargin{:});
            
            obj.linkProperty('lstdProjectionRegularizationFactor');
%            obj.unlinkProperty('lstdProjectionRegularizationFactor');
            
            obj.linkProperty('lstdBiasPrior');
%            obj.unlinkProperty('lstdBiasPrior');
        end
        
        function [projector] = getProjector(obj)
            projector = obj.projector;
        end
                
        function [theta] = learnLSTDInternal(obj, currentFeatures, currentFeaturesWeighted, nextFeatures, rewards)
            regMat1 = eye(size(currentFeatures,2)) * obj.lstdRegularizationFactor;
            regMat2 = eye(size(currentFeatures,2)) * obj.lstdProjectionRegularizationFactor;
            if (obj.useBias)
                regMat1(1,1) = 10^-6;
                regMat2(1,1) = 0;
            end
            
            projector = (currentFeaturesWeighted' * currentFeatures + regMat2) \ (currentFeaturesWeighted' * nextFeatures);
            M = (currentFeatures - obj.discountFactor * currentFeatures * projector);
            if (obj.useBias)
                theta = (M' * M + regMat1) \ M' * (rewards - M(:,1) * obj.lstdBiasPrior);
                theta(1) = theta(1) + obj.lstdBiasPrior;
            else
                theta = (M' * M + regMat1) \ M' * rewards;
            end
        end
        
        function [numParams] = getNumHyperParameters(obj)
            numParams = obj.getNumHyperParameters@PolicyEvaluation.LeastSquaresTDLearning() + 2;
        end
        
        function [] = setHyperParameters(obj, params)
            obj.setHyperParameters@PolicyEvaluation.LeastSquaresTDLearning(params(1:end-2));
            obj.lstdProjectionRegularizationFactor = params(end - 1);
            obj.lstdBiasPrior = params(end);
        end
        
        function [params] = getHyperParameters(obj)
            params = [obj.getHyperParameters@PolicyEvaluation.LeastSquaresTDLearning(), obj.lstdProjectionRegularizationFactor, obj.lstdBiasPrior];
        end
        
        function [expParameterTransformMap] = getExpParameterTransformMap(obj)
            expParameterTransformMap = [obj.getExpParameterTransformMap@PolicyEvaluation.LeastSquaresTDLearning(), true, false];
        end
        
    end
end

