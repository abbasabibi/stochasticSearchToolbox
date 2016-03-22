classdef FiniteHorizonTask < Experiments.Tasks.BanditTask
    
    properties
        
    end
    
    methods
        function obj = FiniteHorizonTask(taskName)
            obj = obj@Experiments.Tasks.BanditTask(taskName);
        end
        
        function postConfigureTrial(obj, trial)
            trial.setprop('rewardFunction');
            trial.setprop('actionPolicy');
            trial.setprop('transitionFunction');
            trial.setprop('initialStateSampler');
            
            trial.setprop('numTimeSteps',29);            
            
            Common.Settings().setProperty('numIterations', trial.numIterations);
            Common.Settings().setProperty('numTimeSteps', trial.numTimeSteps);
            
            
            obj.postConfigureTrial@Experiments.Tasks.BanditTask(trial);
        end
        
        function  setupSampler(obj, trial)
            
            trial.sampler = Sampler.EpisodeWithStepsSampler();
            
            trial.dataManager = trial.sampler.getEpisodeDataManager();
            trial.dataManager.finalizeDataManager();
        end
        
        function registerSamplers(obj, trial)
            
            if (~isempty(trial.rewardFunction))
                trial.sampler.setRewardFunction(trial.rewardFunction);
            end
            
            if (~isempty(trial.actionPolicy))
                trial.sampler.setActionPolicy(trial.actionPolicy);
            end
            
            if (~isempty(trial.transitionFunction))
                trial.sampler.setTransitionFunction(trial.transitionFunction);
            end
            
            if (isempty(trial.returnSampler))
                trial.returnSampler = RewardFunctions.ReturnForEpisode.ReturnSummedReward(trial.sampler);
            end
            
            if (isempty(trial.contextSampler) && trial.dataManager.isDataEntry('contexts'))
                trial.contextSampler = Sampler.InitialSampler.InitialContextSamplerStandard(trial.sampler);
            end
            
            if (~isempty(trial.contextSampler) && isempty(trial.initialStateSampler))
                trial.initialStateSampler = Sampler.InitialSampler.InitialStateSamplerStandard(trial.sampler);
                trial.initialStateSampler.setInitStateFromContext(true);
            end
            
            if (~isempty(trial.initialStateSampler))
                trial.sampler.setInitialStateSampler(trial.initialStateSampler);
            end            
            
            obj.registerSamplers@Experiments.Tasks.BanditTask(trial);
        end
    end
end


