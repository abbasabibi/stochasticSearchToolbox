classdef SLTask < Experiments.Tasks.BanditTask
    
    properties        
    end
    
    methods
        function obj = SLTask(taskName)
            obj = obj@Experiments.Tasks.BanditTask(taskName);
        end
        
        function preConfigureTrial(obj, trial)

            obj.preConfigureTrial@Experiments.Tasks.BanditTask(trial);
            trial.setprop('rewardFunction');

            trial.setprop('SLrobot', @Environments.SL.barrett.BarrettCommunication);
            trial.setprop('SLtask', @Environments.SL.SLRobotTask);
            trial.setprop('SLenvironment', @Environments.SL.SLTrajectoryEnvironment);
            
            Common.Settings().setProperty('numInitialSamplesEpisodes', 20);
            Common.Settings().setProperty('numSamplesEpisodes', 10);
            Common.Settings().setProperty('numMaxSamples', 100);

        end
        
        function postConfigureTrial(obj, trial)                        
            obj.postConfigureTrial@Experiments.Tasks.BanditTask(trial);
            
        end
        
        function addDefaultCriteria(obj, trial, evaluationCriterion)  
            obj.addDefaultCriteria@Experiments.Tasks.BanditTask(trial, evaluationCriterion);

            evaluationCriterion.addSaveDataEntry('states');
            evaluationCriterion.addSaveDataEntry('actions');
            evaluationCriterion.addSaveDataEntry('rewards');
            evaluationCriterion.addSaveDataEntry('SLstates');
            evaluationCriterion.addSaveDataEntry('nextStates');
            evaluationCriterion.addSaveDataEntry('timeSteps');
        end
        
        function setupEnvironment(obj, trial)    
            trial.SLrobot = trial.SLrobot();
            trial.SLenvironment = trial.SLenvironment(trial.dataManager, trial.SLrobot);            
            trial.SLtask = trial.SLtask(trial.dataManager, trial.SLrobot);
            
            trial.SLenvironment.setTask(trial.SLtask);

        end
        
        function  setupSampler(obj, trial)
            
            trial.sampler = Environments.SL.SLSampler();
            trial.dataManager = trial.sampler.getEpisodeDataManager();                                                                         
        end
        
        function registerSamplers(obj, trial)
            
            if (~isempty(trial.rewardFunction))
                trial.sampler.setRewardFunction(trial.rewardFunction);
            end                                               
            
            if (isempty(trial.returnSampler) && ~isempty(trial.rewardFunction))
                trial.returnSampler = RewardFunctions.ReturnForEpisode.ReturnAvgReward(trial.sampler);
            end
            
            if (isempty(trial.rewardFunction) && isempty(trial.returnSampler))
                trial.SLenvironment.registerSLReturnAsReward();
            end
            
            if (isempty(trial.contextSampler) && trial.dataManager.isDataAlias('contexts'))
                trial.contextSampler = Sampler.InitialSampler.InitialContextSamplerStandard(trial.sampler);
            end                                                          
            trial.sampler.setSLEpisodeSampler(trial.SLenvironment);
            obj.registerSamplers@Experiments.Tasks.BanditTask(trial);
        end
    end
end


