classdef BicycleBalanceTask < Experiments.Tasks.StepBasedTask
    
    properties
        worldName
    end
    
    methods
        function obj = BicycleBalanceTask(varargin)
            obj = obj@Experiments.Tasks.StepBasedTask('BicycleBalance', varargin{:});
        end
        
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.Tasks.StepBasedTask(trial);
            
            Common.SettingsManager.activateDebugMode();
            Common.Settings().setProperty('InitialStateDistributionMinRange', - [0.0738    0.3495    0.1413    0.3320] * 0);
            Common.Settings().setProperty('InitialStateDistributionMaxRange', [0.0738    0.3495    0.1413    0.3320] * 0);
            
            trial.setprop('discreteActionMap', [-2,0;2,0;0,-0.02;0,0.02;0,0]);
            
                     
            trial.setprop('discActionName', 'discreteActions');
        end
            
        
        function setupEnvironment(obj, trial)
            trial.transitionFunction = Environments.BicycleBalance.BicycleBalance(trial.sampler);
            trial.transitionFunction.initObject();
            trial.rewardFunction = trial.transitionFunction;                        
            
            trial.initialStateSampler = Sampler.InitialSampler.InitialStateSamplerStandard(trial.sampler);
            trial.contextSampler = trial.transitionFunction;
            
            %Should be in setupSampler, but environment is not initialized
            environmentActive = Sampler.IsActiveStepSampler.IsActiveEnvironment(trial.dataManager,trial.sampler.getStepSampler().isActiveSampler, trial.transitionFunction);
            trial.sampler.getStepSampler().setIsActiveSampler(environmentActive);
            
            trial.setprop('discreteActionInterpreter',  Distributions.Discrete.DiscreteActionInterpreter(trial.dataManager, trial.discreteActionMap));

        end
        
    end
    
end

