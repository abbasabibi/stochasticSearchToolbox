classdef BanditLearnedRewardModelLearningSetupBestProjMat < Experiments.Learner.BanditLearningSetup
    
    properties
        
    end
    
    methods
        function obj = BanditLearnedRewardModelLearningSetupBestProjMat(learnerName)
            obj = obj@Experiments.Learner.BanditLearningSetup(learnerName);
        end
        
        function addDefaultCriteria(obj, trial, evaluationCriterion)            
            obj.addDefaultCriteria@ Experiments.Learner.BanditLearningSetup(trial, evaluationCriterion);
       
        end
        
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@ Experiments.Learner.BanditLearningSetup(trial);
            
            trial.setprop('learnedRewardFunction', @Functions.LowDimSquaredFunction.BayesianLowDimSquaredFunction);            
            trial.setprop('rewardFunctionLearner', @Learner.SupervisedLearner.BayesianLearner.BestLowDimProjector);
            trial.setprop('learnedContextDistribution', []);
            
            
            trial.setprop('learner', @Learner.EpisodicRL.EntropyREPS.CreateFromTrial);                        
        end
        
        function postConfigureTrial(obj, trial)
           obj.postConfigureTrial@Experiments.Learner.BanditLearningSetup(trial);
            
           obj.configureRewardLearner(trial);
        end
        
        function [] = configureRewardLearner(obj, trial)
            trial.learnedRewardFunction = trial.learnedRewardFunction(trial.dataManager, 'returns', {'contexts', 'parameters'}, 'squaredReturn');
            
            trial.rewardFunctionLearner = trial.rewardFunctionLearner(trial.dataManager, trial.learnedRewardFunction);
            
            if (~isempty(trial.learnedContextDistribution))
                trial.learnedContextDistribution = trial.learnedContextDistribution(trial.dataManager);
            end
            
            trial.setprop('virtualSampleGenerator', DataPreprocessors.LearnedEpisodicRewardFunctionDataGenerator(trial.dataManager, trial.sampler, trial.learnedRewardFunction, trial.rewardFunctionLearner, trial.learnedContextDistribution));
            trial.preprocessors = [{trial.virtualSampleGenerator}, trial.preprocessors];
        end
           
       
        function [] = setupScenarioForLearners(obj, trial)
            
           obj.setupScenarioForLearners@Experiments.Learner.BanditLearningSetup(trial);
           trial.scenario.addInitObject(trial.virtualSampleGenerator);
           trial.scenario.addInitObject(trial.learnedRewardFunction);
           trial.scenario.addInitObject(trial.rewardFunctionLearner);
           
            
        end
        
    end
    
end
