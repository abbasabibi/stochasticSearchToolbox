classdef BanditLearnedRewardModelLearningSetup < Experiments.Learner.BanditLearningSetup
    
    properties
        
    end
    
    methods
        function obj = BanditLearnedRewardModelLearningSetup(learnerName)
            obj = obj@Experiments.Learner.BanditLearningSetup(learnerName);
        end
        
        function addDefaultCriteria(obj, trial, evaluationCriterion)
            obj.addDefaultCriteria@ Experiments.Learner.BanditLearningSetup(trial, evaluationCriterion);
            
        end
        
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@ Experiments.Learner.BanditLearningSetup(trial);
            
            trial.setprop('learnedRewardFunction', @Functions.SquaredFunction);
            trial.setprop('rewardFunctionLearner', @Learner.ModelLearner.simpleQuadraticBayesianlearner);
            trial.setprop('learnedContextDistribution', @Distributions.Gaussian.GaussianContextDistribution);
            trial.setprop('contextDistributionLearner', @Learner.SupervisedLearner.LinearGaussianMLLearner);

            trial.setprop('learner', @Learner.EpisodicRL.EntropyREPS.CreateFromTrial);
            trial.setprop('useVirtualSamples', false);
           % trial.setprop('useImportanceWeightings', false);

        end
        
        function postConfigureTrial(obj, trial)
            obj.configureRewardLearner(trial);
            obj.postConfigureTrial@Experiments.Learner.BanditLearningSetup(trial);   
            %trial.rewardFunctionLearner.policy = trial.parameterPolicy; 
            %obj.setupLearner(trial);

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
            
%             if (trial.useImportanceWeightings)
%                 
%                 trial.setprop('importanceSampler', Experiments.Preprocessor.ImportanceSamplingLastKPreprocessor());
%                 trial.preprocessors = [{trial.importanceSampler}, trial.preprocessors];
%             
%             end
            
        end
        
        
        function [] = setupScenarioForLearners(obj, trial)
            
            obj.setupScenarioForLearners@Experiments.Learner.BanditLearningSetup(trial);
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
