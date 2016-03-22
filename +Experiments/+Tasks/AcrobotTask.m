classdef AcrobotTask < Experiments.Tasks.StepBasedTask
    
    properties
        useDiscreteActions = true;
    end
    
    methods
        function obj = AcrobotTask(useDiscreteActions, varargin)
            obj = obj@Experiments.Tasks.StepBasedTask('Acrobot', varargin{:});
            if (exist('useDiscreteActions', 'var'))
                obj.useDiscreteActions = useDiscreteActions;
            end
        end
        
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.Tasks.StepBasedTask(trial);
            
            Common.SettingsManager.activateDebugMode();
            
            Common.Settings().setProperty('discreteActionBuckets',3);
            
            trial.setprop('discreteActions', @Environments.DiscreteActionGenerator);
            trial.setprop('discActionName', 'actions');
            
        end
        
        function setupEnvironment(obj, trial)
            trial.transitionFunction = Environments.Acrobot.Acrobot(trial.sampler);
            trial.transitionFunction.initObject();
            trial.rewardFunction = trial.transitionFunction;
            trial.initialStateSampler = trial.transitionFunction;
            trial.contextSampler = trial.transitionFunction;
            
            if (obj.useDiscreteActions)
                trial.discreteActions = trial.discreteActions(trial.dataManager,trial.transitionFunction);
            else
                trial.dataManager.setRestrictToRange('actions', false);
            end
            
            %Should be in setupSampler, but environment is not initialized
            environmentActive = Sampler.IsActiveStepSampler.IsActiveEnvironment(trial.dataManager,trial.sampler.getStepSampler().isActiveSampler, trial.transitionFunction);
            trial.sampler.getStepSampler().setIsActiveSampler(environmentActive);
        end
        
    end
    
end

