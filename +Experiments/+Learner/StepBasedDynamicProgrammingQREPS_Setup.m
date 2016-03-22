classdef StepBasedDynamicProgrammingQREPS_Setup < Experiments.Learner.StepBasedLearningSetup
    
    properties
    end
    
    methods
        function obj = StepBasedDynamicProgrammingQREPS_Setup(learnerName)
            obj = obj@Experiments.Learner.StepBasedLearningSetup(learnerName, Experiments.LearnerType.TypeA);
        end
        
        function addDefaultCriteria(obj, trial, evaluationCriterion)
            obj.addDefaultCriteria@Experiments.Learner.StepBasedLearningSetup(trial, evaluationCriterion);
        end
        
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.Learner.StepBasedLearningSetup(trial);
            
            trial.setprop('stateFeatures', @(trial) FeatureGenerators.SquaredFeatures.CreateStateFeaturesFromTrial(trial, true, 'states'));            
            trial.setprop('stateActionFeatures', @(trial) FeatureGenerators.SquaredFeatures.CreateStateFeaturesFromTrial(trial, true, {'states', 'actions'}));
            
            trial.setprop('actionPolicyPerTimeStep', @Distributions.Gaussian.GaussianActionPolicy);
            trial.setprop('actionPolicy', @Distributions.TimeDependent.ComposedTimeDependentPolicy);
            
            trial.setprop('policyLearnerPerTimeStep', @Learner.SupervisedLearner.LinearGaussianMLLearner);
            trial.setprop('policyLearner', @Learner.SupervisedLearner.TimeDependentLearner);

            %%% the policy eval preprocessor is not used in the traditional
            %%% way, but called directly in the update model of the learner
            trial.setprop('policyEvalPreprocessor', @(dataManager) DataPreprocessors.PolicyEvalMonteCarloPreprocessor(dataManager));
            trial.setprop('learner', @(trial) Learner.StepBasedRL.StepBasedDynamicProgrammingQREPS(trial, 'qValue'));
            
            %%% state distribution learners per timestep
            trial.setprop('stateDistributionPerTimeStep', @Distributions.Gaussian.GaussianStateDistribution);
            trial.setprop('stateDistribution', @Distributions.TimeDependent.ComposedTimeDependentPolicy);
            
            trial.setprop('stateLearnerPerTimeStep', @Learner.SupervisedLearner.LinearGaussianMLLearner);
            trial.setprop('stateLearner', @Learner.SupervisedLearner.TimeDependentLearner);
            
            % will call the state distribution learners
            trial.setprop('timeDependentStateDistributionLearner', @DataPreprocessors.TimeDependentStateDistributionLearner);
            
            % will compute the time independent proba of each sample
            trial.setprop('timeIndepenpentStateActionProbabilities', @DataPreprocessors.TimeIndependentStateActionProbabilities);
        end
        
        function setupLearner(obj, trial)
            trial.actionPolicy = trial.actionPolicy(trial.dataManager, trial.actionPolicyPerTimeStep);
            trial.policyLearner = trial.policyLearner(trial.dataManager, trial.actionPolicy, trial.policyLearnerPerTimeStep);
            trial.stateDistribution = trial.stateDistribution(trial.dataManager, trial.stateDistributionPerTimeStep);
            trial.stateLearner = trial.stateLearner(trial.dataManager, trial.stateDistribution, trial.stateLearnerPerTimeStep);
            trial.learner = trial.learner(trial);
        end
        
        function postConfigureTrial(obj, trial)
            trial.stateFeatures = trial.stateFeatures(trial);
            trial.stateActionFeatures = trial.stateActionFeatures(trial);
            
            obj.postConfigureTrial@Experiments.Learner.StepBasedLearningSetup(trial);
            
            %%% at this point the RewardTocome DataPreprocessor has already
            %%% been set
            trial.learner.addDataPreprocessor(trial.timeDependentStateDistributionLearner(trial.stateLearner));
            trial.learner.addDataPreprocessor(trial.timeIndepenpentStateActionProbabilities(trial));
        end
        
        function [] = setupScenarioForLearners(obj, trial)
            obj.setupScenarioForLearners@Experiments.Learner.StepBasedLearningSetup(trial);
            trial.scenario.addInitObject(trial.actionPolicy);
            trial.scenario.addInitObject(trial.stateDistribution);
        end
    end
end
