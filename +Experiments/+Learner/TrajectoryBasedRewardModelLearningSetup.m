classdef TrajectoryBasedRewardModelLearningSetup < Experiments.Learner.TrajectoryBasedLearningSetup
    
    properties
        
    end
    
    methods
        function obj = TrajectoryBasedRewardModelLearningSetup(learnerName, varargin)
            obj = obj@Experiments.Learner.TrajectoryBasedLearningSetup(learnerName, varargin{:});
        end
        
         function addDefaultCriteria(obj, trial, evaluationCriterion)            
            obj.addDefaultCriteria@ Experiments.Learner.TrajectoryBasedLearningSetup(trial, evaluationCriterion);
       
        end
        
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.Learner.TrajectoryBasedLearningSetup(trial);
            
            trial.setprop('learnedRewardFunction', @Functions.SquaredFunction);

            %trial.setprop('rewardFunctionLearner', @Learner.ModelLearner.LowDimBayesianLearner);
            trial.setprop('rewardFunctionLearner', @Learner.ModelLearner.ContextualLowDimBayesianLearnerWithContextSubtraction);
            %trial.setprop('rewardFunctionLearner', @Learner.SupervisedLearner.BayesianLearner.BestLowDimProjector);            %trial.setprop('rewardFunctionLearner', @Learner.SupervisedLearner.BayesianLearner.PCAproj);
            trial.setprop('learnedContextDistribution', @Distributions.Gaussian.GaussianContextDistribution);
            trial.setprop('contextDistributionLearner', @Learner.SupervisedLearner.LinearGaussianMLLearner);
            trial.setprop('useVirtualSamples', false);
        end
        
        function postConfigureTrial(obj, trial)
            obj.postConfigureTrial@Experiments.Learner.TrajectoryBasedLearningSetup(trial);
        end
        
        function [] = setupAdditionalLearners(obj, trial)
            obj.configureRewardLearner(trial);
        end
                        
        function [] = configureRewardLearner(obj, trial)
            if (trial.dataManager.isDataAlias('contexts'))
                trial.learnedRewardFunction = trial.learnedRewardFunction(trial.dataManager, 'returns', {'contexts', 'parameters'}, 'squaredReturn');
            else
                trial.learnedRewardFunction = trial.learnedRewardFunction(trial.dataManager, 'returns', {'parameters'}, 'squaredReturn');
            end
            
            trial.rewardFunctionLearner = trial.rewardFunctionLearner(trial.dataManager, trial.learnedRewardFunction);
            
            if (~isempty(trial.learnedContextDistribution))
                trial.learnedContextDistribution = trial.learnedContextDistribution(trial.dataManager);
                trial.contextDistributionLearner = trial.contextDistributionLearner(trial.dataManager, trial.learnedContextDistribution);
            end
            
            if (trial.useVirtualSamples)
                trial.setprop('virtualSampleGenerator', DataPreprocessors.LearnedEpisodicRewardFunctionDataGenerator(trial.dataManager, trial.sampler, trial.learnedRewardFunction, trial.rewardFunctionLearner, trial.learnedContextDistribution, trial.contextDistributionLearner));
                trial.preprocessors = [{trial.virtualSampleGenerator}, trial.preprocessors];
            end
        end
        
        function [] = setupScenarioForLearners(obj, trial)
            obj.setupScenarioForLearners@Experiments.Learner.TrajectoryBasedLearningSetup(trial);
            
            if (trial.useVirtualSamples)
                trial.scenario.addInitObject(trial.virtualSampleGenerator);
            end
            trial.scenario.addInitObject(trial.learnedRewardFunction);
            trial.scenario.addInitObject(trial.rewardFunctionLearner);
            
            if (~isempty(trial.learnedContextDistribution))
                trial.scenario.addInitObject(trial.learnedContextDistribution);
                trial.scenario.addInitObject(trial.contextDistributionLearner);                
            end
            
        end
              
    end
    
end
