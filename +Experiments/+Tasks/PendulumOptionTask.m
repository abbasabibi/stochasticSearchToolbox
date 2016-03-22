classdef PendulumOptionTask < Experiments.Tasks.StepBasedTask
    
    properties(SetObservable, AbortSet)
        isPeriodic      = false;        
    end
    
    methods
        function obj = PendulumOptionTask(taskName, isInfiniteHorizon, isPeriodic)
            obj = obj@Experiments.Tasks.StepBasedTask(taskName, isInfiniteHorizon);
            if(exist('isPeriodic','var'))
                obj.isPeriodic = isPeriodic;
            end
            
            
            
        end
        
        function [] = setupEnvironment(obj, trial)
            trial.transitionFunction            = Environments.DynamicalSystems.Pendulum(trial.sampler, obj.isPeriodic); %non periodic
            trial.transitionFunction.initObject();
            
            trial.initialStateSampler           = Sampler.InitialSampler.InitialStateSamplerStandard(trial.sampler);

            
            actionCost          = 0;
            stateCost           = [10 0; 0 0];
            trial.rewardFunction      = RewardFunctions.QuadraticRewardFunctionSwingUpSimple(trial.dataManager); %non multimodal reward
            trial.rewardFunction.setStateActionCosts(stateCost, actionCost);
            trial.returnSampler       = RewardFunctions.ReturnForEpisode.ReturnAvgReward(trial.dataManager);
            
            
  
            
            trial.sampler.initObject();
            
            trial.dataManager.finalizeDataManager();
            
            
            
            
        end
        
    end
end


