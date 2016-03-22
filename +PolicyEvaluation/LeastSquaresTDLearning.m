classdef LeastSquaresTDLearning < Learner.Learner & Data.DataManipulator & Learner.ParameterOptimization.HyperParameterObject
    
    properties(SetObservable,AbortSet)
        discountFactor = 0.98;        
        useBias = false;
        lstdRegularizationFactor = 10^-8;
        lstdLearningRate = 1.0;
    end
    
    properties(SetAccess=protected)
        stateFeatures
        nextStateFeatures
        rewardName
        sampleWeighting
        
        functionApproximator
       
                       
        featureGeneratorStateActions;
        nextActionSelector;
        
    end
    
    methods (Static)
        function [learner] = CreateFromTrialLearnVFunction(trial)
            
            stateFeatureName = trial.stateFeatures.outputName;
            nextStepFeatureName = trial.nextStateFeatures.outputName;
            learner = PolicyEvaluation.LeastSquaresTDLearning(trial.dataManager,trial.policyEvaluationFunction, stateFeatureName, nextStepFeatureName);
        end
        
        function [learner] = CreateFromTrialLearnQFunction(trial)
            
            stateFeatureName = trial.stateActionFeatures.outputName;
            nextStepFeatureName = trial.nextStateActionFeatures.outputName;
            rewardName = 'rewards';
            if (isprop(trial,'rewardName'))
                rewardName = trial.rewardName;
            end
            if (isprop(trial,'useImportanceSampling') && trial.useImportanceSampling && isempty(findstr(class(trial.nextStateActionFeatures),'CurrentPolicy')))
                learner = PolicyEvaluation.LeastSquaresTDLearning(trial.dataManager,trial.policyEvaluationFunction, stateFeatureName, nextStepFeatureName, rewardName, 'importanceWeights');
            else
                learner = PolicyEvaluation.LeastSquaresTDLearning(trial.dataManager,trial.policyEvaluationFunction, stateFeatureName, nextStepFeatureName, rewardName);
            end
        end
    end
    
    methods
        %%
        function obj = LeastSquaresTDLearning(dataManager, functionApproximator, stateFeatures, nextStateFeatures, rewardName, sampleWeighting)
            
            obj = obj@Learner.Learner();
            obj = obj@Data.DataManipulator(dataManager);
            
            
            obj.functionApproximator = functionApproximator;
            obj.stateFeatures = stateFeatures;
            obj.nextStateFeatures = nextStateFeatures;
            
            if (exist('rewardName', 'var'))
                obj.rewardName = rewardName;
            else
                obj.rewardName = 'rewards';
            end
            if (exist('sampleWeighting', 'var'))
                obj.sampleWeighting = {sampleWeighting};
            else
                obj.sampleWeighting = {};
            end
            
            obj.linkProperty('discountFactor');
            obj.linkProperty('useBias', 'LSTDuseBias');
            obj.linkProperty('lstdRegularizationFactor');
            obj.linkProperty('lstdLearningRate');
            
                        
            obj.addDataManipulationFunction('learnLSTD', {obj.stateFeatures, obj.nextStateFeatures, obj.rewardName, obj.sampleWeighting{:}}, {});
                      
        end
        
        %% Trajectory Generation
        function [] = updateModel(obj, data)
            obj.callDataFunction('learnLSTD', data);
        end
               
        function [theta] = learnLSTDInternal(obj, currentFeatures, currentFeaturesWeighted, nextFeatures, reward)
            regMat = eye(size(currentFeatures,2)) * obj.lstdRegularizationFactor;
            if (obj.useBias)
                regMat(1,1) = 0;
            end
            
            theta = (currentFeaturesWeighted' * (currentFeatures - obj.discountFactor * nextFeatures) + regMat) \ currentFeaturesWeighted' * reward;            
        end
        
        function [] = learnLSTD(obj, stateActionFeatures, nextStateActionFeatures, reward, sampleWeighting)
            
            
            if (obj.useBias)
                stateFeatureMatrix = [ones(size(stateActionFeatures,1), 1), stateActionFeatures];
                nextStateFeatureMatrix = [ones(size(nextStateActionFeatures,1), 1), nextStateActionFeatures];
            else
                stateFeatureMatrix = stateActionFeatures;
                nextStateFeatureMatrix = nextStateActionFeatures;
            end
            
            if (~exist('sampleWeighting', 'var'))
                sampleWeighting = ones(size(stateActionFeatures,1),1);
            end
            thetaOld = obj.functionApproximator.getParameterVector();
            
            stateFeatureMatrixWeighted = bsxfun(@times, stateFeatureMatrix, sampleWeighting);            
            theta = obj.learnLSTDInternal(stateFeatureMatrix, stateFeatureMatrixWeighted, nextStateFeatureMatrix, reward);
                 
            theta = thetaOld * (1 - obj.lstdLearningRate) + obj.lstdLearningRate * theta;
            if (obj.useBias)
                bias = theta(1);
                beta = theta(2:end);
            else
                bias = 0;
                beta = theta;
            end
            obj.functionApproximator.setWeightsAndBias(beta, bias);            
        end
        
        function [numParams] = getNumHyperParameters(obj)
            numParams = obj.functionApproximator.getNumHyperParameters() + 1;
        end
        
        function [] = setHyperParameters(obj, params)
            obj.functionApproximator.setHyperParameters(params(1:end-1));
            obj.lstdRegularizationFactor = params(end);
        end
        
        function [params] = getHyperParameters(obj)
            params = [obj.functionApproximator.getHyperParameters(), obj.lstdRegularizationFactor];
        end
        
        function [expParameterTransformMap] = getExpParameterTransformMap(obj)
            expParameterTransformMap = [obj.functionApproximator.getExpParameterTransformMap(), true];
        end
        
    end
end

