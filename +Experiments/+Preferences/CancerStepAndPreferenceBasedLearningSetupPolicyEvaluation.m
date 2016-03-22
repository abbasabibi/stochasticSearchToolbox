classdef CancerStepAndPreferenceBasedLearningSetupPolicyEvaluation < Experiments.Learner.StepBasedLearningSetupPolicyEvaluation
    
    properties (SetObservable)
        calcGlobal = true;
    end
    
    methods
        function obj = CancerStepAndPreferenceBasedLearningSetupPolicyEvaluation(learnerName,calcGlobal)
            obj = obj@Experiments.Learner.StepBasedLearningSetupPolicyEvaluation(learnerName);
            obj.calcGlobal = calcGlobal;
        end
        
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.Learner.StepBasedLearningSetupPolicyEvaluation(trial);
            
            trial.setprop('featureExpectations', @FeatureGenerators.FeatureExpectations);
            
            if ~isprop(trial,'trajectoryRanker')
                trial.setprop('trajectoryRanker', @Environments.Cancer.CancerTrajectoryRanker);
            end
            
            trial.setprop('trajectorySelector', @Preferences.UtilityCalculator.TrajectorySubsetSelector);
            trial.setprop('utilityFunction', @Preferences.UtilityCalculator.LinearUtilityFunction);
                        
            %trial.setprop('preferenceGenerator', @Preferences.PreferenceGenerator.CompareBestPreferencesGenerator);
            %trial.setprop('preferenceGenerator', @Preferences.PreferenceGenerator.ConsecutiveIterPreferencesGenerator);
            %trial.setprop('preferenceGenerator', @Preferences.PreferenceGenerator.AllPairwisePreferencesGenerator);
            trial.setprop('preferenceGenerator', @Preferences.PreferenceGenerator.NeighbouringRankPreferencesGenerator);
            
            %trial.setprop('utilityFunctionCalculator', @Preferences.UtilityCalculator.IRLAlike);
            trial.setprop('utilityFunctionCalculator', @Preferences.UtilityCalculator.BVIRLAlike);
            trial.setprop('utilityCalculator', @Preferences.UtilityCalculator.UtilityCalculator);
            
        end
                
        function [] = setupPolicyEvaluation(obj, trial)
            trial.featureExpectations = trial.featureExpectations(trial.dataManager, trial.nextStateFeatures.outputName);
            
            trial.utilityFunction = trial.utilityFunction(trial.dataManager, trial.nextStateFeatures.outputName);
            
            trial.trajectorySelector = trial.trajectorySelector(trial.dataManager,trial.utilityFunction,trial.featureExpectations.outputName);
            
            trial.trajectoryRanker = trial.trajectoryRanker(trial.dataManager,obj.calcGlobal,{'cancerEval', trial.trajectorySelector.outputName});
            trial.preferenceGenerator = trial.preferenceGenerator(trial.dataManager, obj.calcGlobal, trial.trajectoryRanker.outputName);
            
            trial.utilityFunctionCalculator = trial.utilityFunctionCalculator(trial.dataManager, trial.utilityFunction, trial.nextStateFeatures.outputName,trial.preferenceGenerator.outputName);
            trial.utilityCalculator = trial.utilityCalculator(trial.dataManager, trial.utilityFunctionCalculator);
            
            trial.setprop('rewardName', trial.utilityFunctionCalculator.outputName); %For LSTD
            
            obj.setupPolicyEvaluation@Experiments.Learner.StepBasedLearningSetupPolicyEvaluation(trial);
        
            trial.setprop('qValueName',trial.policyEvaluationFeature.outputName); %For REPS
        end
        
        function [] = setupScenarioForLearners(obj, trial)
            %obj.setupScenarioForLearners@Experiments.Learner.StepBasedLearningSetupPolicyEvaluation(trial);
            trial.scenario.addLearner(trial.utilityCalculator);

            obj.setupScenarioForLearners@Experiments.Learner.StepBasedLearningSetupPolicyEvaluation(trial);
            
            trial.scenario.addInitObject(trial.utilityCalculator);
        end
        
    end
    
end
