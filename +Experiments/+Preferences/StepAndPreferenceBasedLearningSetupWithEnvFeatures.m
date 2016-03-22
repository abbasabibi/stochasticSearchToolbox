classdef StepAndPreferenceBasedLearningSetupWithEnvFeatures < Experiments.Learner.StepAndPreferenceBasedLearningSetupPolicyEvaluation
    
    methods
        function obj = StepAndPreferenceBasedLearningSetupWithEnvFeatures(learnerName,calcGlobal)
            obj = obj@Experiments.Learner.StepAndPreferenceBasedLearningSetupPolicyEvaluation(learnerName,calcGlobal);
        end
        
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.Learner.StepAndPreferenceBasedLearningSetupPolicyEvaluation(trial);
            
            trial.setprop('utilityFeatureFunction', @FeatureGenerators.EnvironmentFeatures);
        end
        
        function [] = setupPolicyEvaluation(obj, trial)
            obj.setupPolicyEvaluation@Experiments.Learner.StepBasedLearningSetupPolicyEvaluation(trial);
            
            trial.featureExpectations = trial.featureExpectations(trial.dataManager, trial.utilityFeatureFunction.outputName);
            
            trial.trajectoryRanker = trial.trajectoryRanker(trial.dataManager,obj.calcGlobal);
            trial.preferenceGenerator = trial.preferenceGenerator(trial.dataManager, obj.calcGlobal, trial.trajectoryRanker.outputName);
            
            trial.utilityFunctionCalculator = trial.utilityFunctionCalculator(trial.dataManager, trial.utilityFeatureFunction.outputName);
            trial.utilityCalculator = trial.utilityCalculator(trial.dataManager, trial.utilityFunctionCalculator);
        end
        
        function setupFeatures(obj, trial)
            obj.setupFeatures@Experiments.Learner.StepAndPreferenceBasedLearningSetupPolicyEvaluation(trial);
            
            trial.utilityFeatureFunction = trial.utilityFeatureFunction(trial.dataManager, 'nextStates', ':', trial.transitionFunction);
        end
        
    end
    
end
