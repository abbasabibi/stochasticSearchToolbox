classdef GridWorldTask < Experiments.Tasks.StepBasedTask
    
    properties
        worldName
    end
    
    methods
        function obj = GridWorldTask(worldName, varargin)
            obj = obj@Experiments.Tasks.StepBasedTask('GridWorld', varargin{:})
            obj.worldName = worldName;
        end
        
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.Tasks.StepBasedTask(trial);
            
            trial.setprop('gridWorld', obj.worldName);
            Common.SettingsManager.activateDebugMode();
            
            %trial.setprop('returnSampler',@RewardFunctions.ReturnForEpisode.ReturnDecayedSummedReward);
            trial.setprop('discActionName', 'actions');
        end
        
        function setupEnvironment(obj, trial)
            trial.transitionFunction = trial.gridWorld(trial.sampler);
            trial.transitionFunction.initObject();
            trial.rewardFunction = trial.transitionFunction;
            trial.initialStateSampler = trial.transitionFunction;
            trial.contextSampler = trial.transitionFunction;
            
            %trial.returnSampler = trial.returnSampler(trial.sampler);
            
            %Should be in setupSampler, but environment is not initialized
            %environmentActive = Sampler.IsActiveStepSampler.IsActiveEnvironment(trial.dataManager,trial.sampler.getStepSampler().isActiveSampler, trial.transitionFunction);
            %trial.sampler.getStepSampler().setIsActiveSampler(environmentActive);
        end
        
    end
    
end

