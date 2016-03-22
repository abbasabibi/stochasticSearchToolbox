classdef PendulumTask < Experiments.Tasks.DecisionStepBasedTask
    
    properties
        isPeriodic = false;
    end
    
    methods
        function obj = PendulumTask(taskName, isInfiniteHorizon, isPeriodic)
            obj = obj@Experiments.Tasks.DecisionStepBasedTask(taskName, isInfiniteHorizon);
            if(exist('isPeriodic','var'))
                obj.isPeriodic = isPeriodic;
            end
            
        end
        
        function [] = setupEnvironment(obj, trial)
%             obj.setupSampler@Experiments.Tasks.DecisionStepBasedTask(trial);
            trial.transitionFunction            = Environments.DynamicalSystems.Pendulum(trial.sampler, obj.isPeriodic); %non periodic
            trial.transitionFunction.initObject();
            trial.actionPolicy                  = TrajectoryGenerators.TrajectoryTracker.GoalAttractor(trial.dataManager, 1);
            trial.decisionTerminationSampler    = trial.actionPolicy;
            trial.endStageSampler               = Sampler.test.EnvironmentStageTest(trial.actionPolicy);
            
            
            actionCost          = 0;
            stateCost           = [10 0; 0 0];
            trial.rewardFunction      = RewardFunctions.QuadraticRewardFunctionSwingUpSimple(trial.dataManager); %non multimodal reward
            trial.rewardFunction.setStateActionCosts(stateCost, actionCost);
            trial.returnSampler       = RewardFunctions.ReturnForEpisode.ReturnAvgReward(trial.dataManager);
            
            
            
            
            trial.sampler.initObject();
            
            trial.dataManager.finalizeDataManager();
            
%             minRangeContexts = [-pi, -30];
%             maxRangeContexts = [+pi, 30];
            minRangeContexts = [pi - pi/4, -5]; 
            maxRangeContexts = [pi + pi/4, +5];
            maxRange = 3;
            trial.dataManager.setRange('contexts', minRangeContexts, maxRangeContexts);
            trial.dataManager.setRange('parameters', -maxRange, maxRange);

            trial.dataManager.finalizeDataManager();
            
            
        end
        
    end
end


