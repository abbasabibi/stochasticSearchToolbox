classdef PongTask < Experiments.Tasks.DecisionStepBasedTask
    
    properties
        
    end
    
    methods
        function obj = PongTask(taskName, isInfiniteHorizon)
            obj = obj@Experiments.Tasks.DecisionStepBasedTask(taskName, isInfiniteHorizon);
            
        end
        
        function [] = setupEnvironment(obj, trial)
%             obj.setupSampler@Experiments.Tasks.DecisionStepBasedTask(trial);
            trial.transitionFunction        = Environments.Pong.Pong(trial.sampler, 60, 20);
            trial.decisionTerminationSampler = trial.transitionFunction;
            trial.returnSampler             = RewardFunctions.ReturnForEpisode.PongReturn(trial.dataManager);
            
            
            trial.sampler.initObject();
            
            

%             trial.dataManager.setRange('contexts', [-5 trial.transitionFunction.field.ballInitHeight -0.3 -1 0 -20], ...
%                 [5 trial.transitionFunction.field.ballInitHeight 0.3 -1 0 20]);
            
%             trial.dataManager.setRange('contexts', [-20 trial.transitionFunction.field.ballInitHeight -2 -1 0 -20], ...
%                 [20 trial.transitionFunction.field.ballInitHeight 2 -1 0 20]); %[posX, posY, velX, velY, reward, opponentX]
            
            trial.dataManager.setRange('contexts', [-20 trial.transitionFunction.field.ballInitHeight -pi/3 -1 0 -20], ...
                [20 trial.transitionFunction.field.ballInitHeight pi/3 -1 0 20]); %[posX, posY, velX, velY, reward, opponentX]
            
            trial.dataManager.addDataAliasForDepth(2,'contextsForFeatures', 'contexts', [1,3,6]);
            trial.dataManager.addDataAliasForDepth(2,'nextContextsForFeatures', 'nextContexts', [1,3,6]);
            trial.dataManager.finalizeDataManager();
            
            trial.actionPolicy          = TrajectoryGenerators.TrajectoryTracker.ConstantTrajectoryTracker(trial.dataManager, 2);
        end
        
    end
end


