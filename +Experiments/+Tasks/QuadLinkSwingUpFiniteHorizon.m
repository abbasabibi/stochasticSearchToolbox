classdef QuadLinkSwingUpFiniteHorizon < Experiments.Tasks.StepBasedTask
    
    properties
        
    end
    
    methods
        function obj = QuadLinkSwingUpFiniteHorizon()
            obj = obj@Experiments.Tasks.StepBasedTask('QuadLinkSwingUpFH', false);
        end
        
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.Tasks.StepBasedTask(trial);
                        
            Common.SettingsManager.activateDebugMode();
            
            
            Common.Settings().setProperty('numTimeSteps', 70);                                        
            Common.Settings().setProperty('dt', 0.033);                                        
            
        end
                
        function setupViaPoint(obj,trial)
            trial.setprop('viaPoint');
            if(isempty(trial.viaPoint))
                trial.viaPoint.times   = [51:70]; 
                trial.viaPoint.factors = repmat([1e4, 1e0, 1e4, 1e0, 1e4, 1e0, 1e4, 1e0], length(trial.viaPoint.times), 1);
                %trial.viaPoint.factors(end,:) =  [1e4, 1e4, 1e4, 1e4];
                for i = 1:length(trial.viaPoint.factors)
                    trial.viaPoint.points{i}  = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0];
                end

                 %trial.viaPoint.times   = [51:70]; 
                 %trial.viaPoint.factors = repmat([1e4, 1e3, 1e4, 1e3], 20, 1);
                 %trial.viaPoint.factors(end,:) =  trial.viaPoint.factors(end,:) * 1000;
                 %for i = 1:20
%                     trial.viaPoint.points{i}  = [0.0, 0.0, 0.0, 0.0];
%                 end
                 trial.viaPoint.uFactor = 10^-3;
            end
        end
        
        function setupRewardFunction(obj, trial)
            trial.rewardFunction = RewardFunctions.TimeDependent.ViaPointRewardFunction(trial.dataManager, trial.viaPoint.times,trial.viaPoint.points,trial.viaPoint.factors,trial.viaPoint.uFactor);
            %trial.rewardFunction = RewardFunctions.test.TimeDependentRewardTest(trial.settings, trial.sampler);
        end
        
        function setupEnvironment(obj, trial)
                       
            trial.transitionFunction = Environments.DynamicalSystems.QuadLink(trial.sampler);
            
            rangeInitialMin = [pi - 0.01, - 0.01, - 0.01,- 0.01, - 0.01,- 0.01, - 0.01,- 0.01];
            rangeInitialMax = [pi + 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01];            
            trial.dataManager.setRange('actions', [-20, -20, -20, -20], [20, 20, 20, 20]);
            trial.dataManager.addDataEntry('contexts', 8,  rangeInitialMin, rangeInitialMax);            
            
            trial.transitionFunction.initObject();
            obj.setupViaPoint(trial);            
            obj.setupRewardFunction(trial);

        end                
    end
    
end

