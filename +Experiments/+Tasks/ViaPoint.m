classdef ViaPoint < Experiments.Tasks.StepBasedTask
    
    properties
        
    end
    
    methods
        function obj = ViaPoint()
            obj = obj@Experiments.Tasks.StepBasedTask('ViaPoint', false);
        end
        
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.Tasks.StepBasedTask(trial);
                        
            Common.SettingsManager.activateDebugMode();
            
            trial.setprop('numDimensions',1);
            
            Common.Settings().setProperty('dt', 0.005);                                        

        end
                
        function setupViaPoint(obj,trial)
            trial.setprop('viaPoint');
            if(isempty(trial.viaPoint))
                trial.viaPoint.times   = [0.5, 1.0] * Common.Settings().getProperty('numTimeSteps'); 
                trial.viaPoint.factors = repmat([1e4, 1e2; 1e4, 1e2], 1, trial.numDimensions);
                trial.viaPoint.points  = {repmat([1, -1], 1, trial.numDimensions), repmat([0.2, 0], 1, trial.numDimensions)};
                trial.viaPoint.uFactor = 10^-3 * Common.Settings().getProperty('dt') / 0.005;
            end
        end
        
        function setupRewardFunction(obj, trial)
            trial.rewardFunction = RewardFunctions.TimeDependent.ViaPointRewardFunction(trial.dataManager, trial.viaPoint.times,trial.viaPoint.points,trial.viaPoint.factors,trial.viaPoint.uFactor);
            %trial.rewardFunction = RewardFunctions.test.TimeDependentRewardTest(trial.settings, trial.sampler);
        end
        
        function setupEnvironment(obj, trial)

            Common.Settings().setProperty('numTimeSteps', floor(1 / Common.Settings().getProperty('dt')));
                       
            trial.transitionFunction = Environments.DynamicalSystems.LinearSystem(trial.sampler, trial.numDimensions);
            rangeInitial = repmat([0.01, 0.05], 1, trial.numDimensions);
            trial.dataManager.addDataEntry('contexts', trial.numDimensions * 2, -rangeInitial, rangeInitial);            
            
            obj.setupViaPoint(trial);            
            obj.setupRewardFunction(trial);

        end                
    end
    
end

