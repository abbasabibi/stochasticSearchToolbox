classdef StepBasedQApproxLearningSetup < Experiments.Learner.StepBasedLearningSetup
    
    properties
    end
    
    methods
        function obj = StepBasedQApproxLearningSetup(learnerName)
            obj = obj@Experiments.Learner.StepBasedLearningSetup(learnerName, Experiments.LearnerType.TypeA);
        end
        
        function addDefaultCriteria(obj, trial, evaluationCriterion)
            obj.addDefaultCriteria@Experiments.Learner.StepBasedLearningSetup(trial, evaluationCriterion);
        end
        
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.Learner.StepBasedLearningSetup(trial);
            
            trial.setprop('stateFeatures', @(trial) FeatureGenerators.SquaredFeatures.CreateStateFeaturesFromTrial(trial, true, 'states'));
            
            trial.setprop('stateActionFeatures', @(trial) FeatureGenerators.SquaredFeatures.CreateStateFeaturesFromTrial(trial, true, {'states', 'actions'}));
            trial.setprop('policyEvalPreprocessor', @(dataManager) DataPreprocessors.PolicyEvalMonteCarloPreprocessor(dataManager));
            
            trial.setprop('actionPolicyPerTimeStep', @Distributions.Gaussian.GaussianActionPolicy);
            trial.setprop('actionPolicy', @Distributions.TimeDependent.ComposedTimeDependentPolicy);
            
            trial.setprop('policyLearnerPerTimeStep', @Learner.SupervisedLearner.LinearGaussianMLLearner);
            trial.setprop('policyLearner', @Learner.SupervisedLearner.TimeDependentLearner);
            
            trial.setprop('learner', @(trial) Learner.StepBasedRL.StepBasedREPS.CreateFromTrial(trial, 'qValue', 'preprocessedData'));
            trial.setprop('preprocessors');
            
            %%% state distribution learners per timestep
            trial.setprop('stateDistributionPerTimeStep', @Distributions.Gaussian.GaussianStateDistribution);
            trial.setprop('stateDistribution', @Distributions.TimeDependent.ComposedTimeDependentPolicy);
            
            trial.setprop('stateLearnerPerTimeStep', @Learner.SupervisedLearner.LinearGaussianMLLearner);
            trial.setprop('stateLearner', @Learner.SupervisedLearner.TimeDependentLearner);
            
            trial.setprop('timeIndepenpentStateActionProbabilities', @DataPreprocessors.TimeIndependentStateActionProbabilities);
            %trial.setprop('timeIndepenpentStateActionProbabilities', []); 
            % trial.setprop('timeIndepenpentStateProbabilities', @DataPreprocessors.TimeIndependentStateProbabilities);
            trial.setprop('timeDependentStateDistributionLearner', @DataPreprocessors.TimeDependentStateDistributionLearner);
        end
        
        function setupLearner(obj, trial)
            trial.actionPolicy = trial.actionPolicy(trial.dataManager, trial.actionPolicyPerTimeStep);
            trial.policyLearner = trial.policyLearner(trial.dataManager, trial.actionPolicy, trial.policyLearnerPerTimeStep);
            if (isprop(trial, 'timeIndepenpentStateActionProbabilities') && ~isempty(trial.timeIndepenpentStateActionProbabilities))
                trial.stateDistribution = trial.stateDistribution(trial.dataManager, trial.stateDistributionPerTimeStep);
                trial.stateLearner = trial.stateLearner(trial.dataManager, trial.stateDistribution, trial.stateLearnerPerTimeStep);
            end
            if(isprop(trial, 'learner'))
                if(~isempty(trial.learner))
                    trial.learner = trial.learner(trial);
                end
            end
        end
        
        function postConfigureTrial(obj, trial)
            if (~isempty(trial.stateFeatures))
                trial.stateFeatures = trial.stateFeatures(trial);
            end
            if (~isempty(trial.stateActionFeatures))
                trial.stateActionFeatures = trial.stateActionFeatures(trial);
            end
            
            obj.postConfigureTrial@Experiments.Learner.StepBasedLearningSetup(trial);
            
            %%% at this point the RewardTocome DataPreprocessor has already
            %%% been set, we add after it the policy evaluation
            %%% preprocessors
            if (isprop(trial, 'timeIndepenpentStateActionProbabilities') && ~isempty(trial.timeIndepenpentStateActionProbabilities))
                trial.learner.addDataPreprocessor(trial.timeDependentStateDistributionLearner(trial.stateLearner));
                % trial.learner.addDataPreprocessor(trial.timeIndepenpentStateProbabilities(trial));
                trial.learner.addDataPreprocessor(trial.timeIndepenpentStateActionProbabilities(trial)); % in case importance sampling is used between timesteps
            end
            trial.learner.addDataPreprocessor(trial.policyEvalPreprocessor(trial));
        end
        
        function [] = setupScenarioForLearners(obj, trial)
            obj.setupScenarioForLearners@Experiments.Learner.StepBasedLearningSetup(trial);
            trial.scenario.addInitObject(trial.actionPolicy);
            if (isprop(trial, 'timeIndepenpentStateActionProbabilities') && ~isempty(trial.timeIndepenpentStateActionProbabilities))
                trial.scenario.addInitObject(trial.stateDistribution);
            end
        end
    end
    
end
