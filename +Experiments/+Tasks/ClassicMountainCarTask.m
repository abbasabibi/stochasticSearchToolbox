classdef ClassicMountainCarTask < Experiments.Tasks.StepBasedTask
    
    methods
        function obj = ClassicMountainCarTask(varargin)
            obj = obj@Experiments.Tasks.StepBasedTask('MountainCar', varargin{:})
        end
        
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.Tasks.StepBasedTask(trial);
            
            Common.SettingsManager.activateDebugMode();
            
            Common.Settings().setProperty('discreteActionBuckets',3);
            
            trial.setprop('discreteActions', @Environments.DiscreteActionGenerator);
            trial.setprop('discActionName', 'actions');
        end
        
        function setupEnvironment(obj, trial)
            trial.transitionFunction = Environments.MountainCar.ClassicMountainCar(trial.sampler);
            trial.transitionFunction.initObject();
            trial.rewardFunction = trial.transitionFunction;
            trial.initialStateSampler = trial.transitionFunction;
            trial.contextSampler = trial.transitionFunction;
            
            trial.discreteActions = trial.discreteActions(trial.dataManager,trial.transitionFunction);
            
            %Should be in setupSampler, but environment is not initialized
            environmentActive = Sampler.IsActiveStepSampler.IsActiveEnvironment(trial.dataManager,trial.sampler.getStepSampler().isActiveSampler, trial.transitionFunction);
            trial.sampler.getStepSampler().setIsActiveSampler(environmentActive);
        end
        
    end
    
end

