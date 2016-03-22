classdef StepBasedTaskExternal < Experiments.Tasks.BanditTask
    
    properties
        isInfiniteHorizon
    end
    
    methods
        function obj = StepBasedTaskExternal(taskName)
            obj = obj@Experiments.Tasks.BanditTask(taskName);
        end
        
        function postConfigureTrial(obj, trial)
            trial.setprop('rewardFunction');
    
            
            Common.Settings().setProperty('numIterations', trial.numIterations);

            obj.postConfigureTrial@Experiments.Tasks.BanditTask(trial);
        end
        
        function addDefaultCriteria(obj, trial, evaluationCriterion)  
            obj.addDefaultCriteria@Experiments.Tasks.BanditTask(trial, evaluationCriterion);

            evaluationCriterion.addSaveDataEntry('states');
            evaluationCriterion.addSaveDataEntry('actions');
            evaluationCriterion.addSaveDataEntry('rewards');
            evaluationCriterion.addSaveDataEntry('nextStates');
            evaluationCriterion.addSaveDataEntry('timeSteps');

        end
        
        
        function  setupSampler(obj, trial)
            
            trial.sampler = Sampler.ExternalEpisodeSampler();
            trial.dataManager = trial.sampler.getEpisodeDataManager();    
            
            trial.dataManager.addDataEntry('returns',1);

            trial.dataManager.finalizeDataManager();
        end
        
        function registerSamplers(obj, trial)
            
            if (~isempty(trial.rewardFunction))
                trial.sampler.setRewardFunction(trial.rewardFunction);
            end
                       
            if (trial.isProperty('actionPolicy') && ~isempty(trial.actionPolicy))
                trial.sampler.setActionPolicy(trial.actionPolicy);
            end
            
            if (isempty(trial.returnSampler))
                if(obj.isInfiniteHorizon)
                    trial.returnSampler = RewardFunctions.ReturnForEpisode.ReturnSummedReward(trial.dataManager);
                    %should use the average return evaluator...
                else
                    trial.returnSampler = RewardFunctions.ReturnForEpisode.ReturnSummedReward(trial.dataManager);
                end
            end
            
        
            
            obj.registerSamplers@Experiments.Tasks.BanditTask(trial);
        end
    end
end


