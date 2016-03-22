classdef BanditRewardModelLearningSetup < Experiments.Configurator    
    properties
        
    end
    
    methods
        function obj = BanditRewardModelLearningSetup(learnerName, varargin)
            obj = obj@Experiments.Configurator(learnerName, varargin{:});
        end
        
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.Configurator(trial);
            
            trial.setprop('learnedRewardFunction', @Functions.SquaredFunction);
           
            trial.setprop('rewardFunctionLearner', @Learner.ModelLearner.ContextualLowDimBayesianLearnerWithContextSubtraction);
            trial.setprop('learnedContextDistribution', @Distributions.Gaussian.GaussianContextDistribution);
            trial.setprop('contextDistributionLearner', @Learner.SupervisedLearner.LinearGaussianMLLearner);
            trial.setprop('useVirtualSamples', false);
        end
        
        function postConfigureTrial(obj, trial)
            obj.configureRewardLearner(trial);
            obj.postConfigureTrial@Experiments.Learner.TrajectoryBasedLearningSetup(trial);
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
