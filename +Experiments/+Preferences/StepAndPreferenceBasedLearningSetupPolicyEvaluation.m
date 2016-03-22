classdef StepAndPreferenceBasedLearningSetupPolicyEvaluation < Experiments.PolicyEvaluation.StepBasedLearningSetupPolicyEvaluation
    
    properties (SetObservable)
        calcGlobal = true;
        prefCalc;
        utilityFeature;
    end
    
    methods
        function obj = StepAndPreferenceBasedLearningSetupPolicyEvaluation(learnerName,PreferenceCalc,calcGlobal,utilityFeature)
            obj = obj@Experiments.PolicyEvaluation.StepBasedLearningSetupPolicyEvaluation(learnerName);
            obj.calcGlobal = calcGlobal;
            obj.prefCalc = PreferenceCalc;
            if(~exist('utilityFeature','var'))
                utilityFeature = 'nextStateFeatures';
            end
            obj.utilityFeature = utilityFeature;
        end
        
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.PolicyEvaluation.StepBasedLearningSetupPolicyEvaluation(trial);
            
            if ~isprop(trial,'trajectoryRanker')
                trial.setprop('trajectoryRanker', @Preferences.RankingGenerator.RewardSumRanker);
            end
                        
            trial.setprop('featureExpectations', @FeatureGenerators.FeatureExpectations);
            
            %trial.setprop('trajectoryImportanceSampler', @Preferences.UtilityCalculator.TrajectoryImportance);
            
            trial.setprop('trajectorySelector', @Preferences.UtilityCalculator.TrajectorySubsetSelector);
            %trial.setprop('trajectoryRanker', @Preferences.RankingGenerator.RewardSumRankerOnlyComplete);
            %trial.setprop('trajectoryRanker', @Preferences.RankingGenerator.RewardSumRankerWithGoal);
            trial.setprop('utilityFunction', @Preferences.UtilityCalculator.LinearUtilityFunction);
            
            trial.setprop('preferenceGenerator', @Preferences.PreferenceGenerator.CompareBestPreferencesGenerator);
            %trial.setprop('preferenceGenerator', @Preferences.PreferenceGenerator.CompareBestApproxRankPreferencesGenerator);
            %trial.setprop('preferenceGenerator', @Preferences.PreferenceGenerator.ConsecutiveIterPreferencesGenerator);
            %trial.setprop('preferenceGenerator', @Preferences.PreferenceGenerator.AllPairwisePreferencesGenerator);
            %trial.setprop('preferenceGenerator', @Preferences.PreferenceGenerator.NeighbouringRankPreferencesGenerator);
            
            %trial.setprop('utilityFunctionCalculator', @Preferences.UtilityCalculator.IRLAlike);
            trial.setprop('utilityFunctionCalculator', obj.prefCalc);
            trial.setprop('utilityCalculator', @Preferences.UtilityCalculator.UtilityCalculator);
            
        end
        
        function [] = setupPolicyEvaluation(obj, trial)
            %utilityFeature = trial.nextStateFeatures.outputName;
            utilityFeature = trial.(obj.utilityFeature);
            utilityFeature = utilityFeature.outputName;
            
            trial.featureExpectations = trial.featureExpectations(trial.dataManager, utilityFeature);
            
            trial.utilityFunction = trial.utilityFunction(trial.dataManager, utilityFeature);
            
            trial.trajectorySelector = trial.trajectorySelector(trial.dataManager,trial.utilityFunction,trial.featureExpectations.outputName);
            
            trial.trajectoryRanker = trial.trajectoryRanker(trial.dataManager,obj.calcGlobal,{'returns', trial.trajectorySelector.outputName});
            trial.preferenceGenerator = trial.preferenceGenerator(trial.dataManager, obj.calcGlobal, trial.trajectoryRanker.outputName, trial.featureExpectations.outputName);
            
            trial.utilityFunctionCalculator = trial.utilityFunctionCalculator(trial.dataManager, trial.utilityFunction, utilityFeature,trial.preferenceGenerator.outputName);
            
            trial.utilityCalculator = trial.utilityCalculator(trial.dataManager, trial.utilityFunctionCalculator);
            
            trial.setprop('rewardName', trial.utilityFunctionCalculator.outputName); %For LSTD
            
            obj.setupPolicyEvaluation@Experiments.PolicyEvaluation.StepBasedLearningSetupPolicyEvaluation(trial);
            
            %trial.trajectoryImportanceSampler = trial.trajectoryImportanceSampler(trial.dataManager);
            
            trial.setprop('qValueName',trial.policyEvaluationPreProcessor.getQValueName()); %For REPS
        end
        
        function [] = setupScenarioForLearners(obj, trial)
            %obj.setupScenarioForLearners@Experiments.Learner.StepBasedLearningSetupPolicyEvaluation(trial);
            trial.scenario.addLearner(trial.utilityCalculator);
            
            obj.setupScenarioForLearners@Experiments.PolicyEvaluation.StepBasedLearningSetupPolicyEvaluation(trial);
            
            trial.scenario.addInitObject(trial.utilityCalculator);
        end
        
    end
    
end
