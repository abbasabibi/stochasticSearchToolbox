classdef TestTask < Experiments.ConfiguredTask
    
    properties
        
    end
    
    methods
        function obj = TestTask()
            obj = obj@Experiments.ConfiguredTask('TestTask', Experiments.LearnerType.TypeA);
        end
        
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.ConfiguredTask(trial);
            
            trial.settings.isDebug = true;
            trial.setprop('dimContext', 2);
            trial.setprop('dimParameters', 5);
        end
        
        function postConfigureTrial(obj, trial)
            obj.postConfigureTrial@Experiments.ConfiguredTask(trial);
            
            trial.settings.setParameter('numIterations', trial.numIterations);
            
          
            obj.setupEnvironment(trial);
        end
        
        
        function setupEnvironment(obj, trial)
            trial.setprop('environment');
            
            numDimensions = trial.dimParameters + trial.dimContext;
            
            rewardCenter = randn(1, numDimensions);
            rewardDistance = randn(numDimensions, numDimensions);
            rewardDistance = rewardDistance' * rewardDistance;
            
            trial.environment =  Environments.BanditEnvironments.SquaredReward(trial.settings, trial.sampler, trial.dimContext, trial.dimParameters, rewardCenter, rewardDistance);

        end
        
        function  setupSampler(obj, trial)
            
            trial.sampler = Sampler.EpisodeSampler(trial.settings);
            
            trial.dataManager = trial.sampler.getEpisodeDataManager();
            trial.dataManager.finalizeDataManager();

        end
        
        function  setupScenario(obj, trial, evalCriterion)
            trial.sampler.setContextSampler(trial.environment);
                        
            trial.sampler.setParameterPolicy(trial.parameterPolicy);            
            trial.sampler.setReturnFunction(trial.environment);

            trial.scenario = LearningScenario.LearningScenario(trial.dataManager, evalCriterion, trial.sampler);
            trial.scenario.addInitObject(trial.parameterPolicy);
        end
    end
end


