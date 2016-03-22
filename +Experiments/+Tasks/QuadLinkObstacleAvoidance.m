classdef QuadLinkObstacleAvoidance < Experiments.Tasks.StepBasedTask
    
    properties
        
    end
    
    methods
        function obj = QuadLinkObstacleAvoidance()
            obj = obj@Experiments.Tasks.StepBasedTask('QuadLinkObstacleAvoidance', false);
        end
        
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.Tasks.StepBasedTask(trial);
                        
            Common.SettingsManager.activateDebugMode();
                        
            Common.Settings().setProperty('numTimeSteps', 70);                                        
            Common.Settings().setProperty('dt', 0.066);                                                                         
        end
                
        
        function setupRewardFunction(obj, trial)
            trial.rewardFunction = RewardFunctions.TimeDependent.ObstacleAvoidanceRewardFunction(trial.dataManager, trial.transitionFunction);            
        end
        
        function setupEnvironment(obj, trial)
                       
            trial.transitionFunction = Environments.DynamicalSystems.QuadLink(trial.sampler);
            
            rangeInitialMin = [pi - 0.01, - 0.01, - 0.01,- 0.01, - 0.01,- 0.01, - 0.01,- 0.01];
            rangeInitialMax = [pi + 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01];            
            trial.dataManager.setRange('actions', [-20, -20, -20, -20], [20, 20, 20, 20]);
            trial.dataManager.addDataEntry('contexts', 8,  rangeInitialMin, rangeInitialMax);            
            
            obj.setupRewardFunction(trial);

        end                
    end
    
end

