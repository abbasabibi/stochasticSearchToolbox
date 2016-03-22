classdef DoubleLinkSwingUpFiniteHorizon < Experiments.Tasks.StepBasedTask
    
    properties
        
    end
    
    methods
        function obj = DoubleLinkSwingUpFiniteHorizon()
            obj = obj@Experiments.Tasks.StepBasedTask('DoubleLinkSwingUpFH', false);
        end
        
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.Tasks.StepBasedTask(trial);
                        
            trial.setprop('initialRangeMultiplier', 1.0);           
            
            Common.SettingsManager.activateDebugMode();                        
            Common.Settings().setProperty('numTimeSteps', 70);                                        
            Common.Settings().setProperty('dt', 0.066); 
            Common.Settings().setProperty('usePeriodicity', 1); 
            
        end
                
        function setupViaPoint(obj,trial)
            trial.setprop('viaPoint');
            if(isempty(trial.viaPoint))
                trial.viaPoint.times   = [51:70]; 
                trial.viaPoint.factors = repmat([1e4, 1e3, 1e4, 1e3], length(trial.viaPoint.times), 1);
                %trial.viaPoint.factors(end,:) =  [1e4, 1e4, 1e4, 1e4];
                for i = 1:length(trial.viaPoint.factors)
                    trial.viaPoint.points{i}  = [0.0, 0.0, 0.0, 0.0];
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
                       
            trial.transitionFunction = Environments.DynamicalSystems.DoubleLink(trial.sampler);
            
            
            
            rangeInitialMin = [pi - 0.05, - 0.1, - 0.05,- 0.1];
            rangeInitialMax = [pi + 0.05, 0.1,  0.05, 0.1];
            
            rangeMean = (rangeInitialMin + rangeInitialMax) * 0.5;
            
            rangeInitialMin = trial.initialRangeMultiplier * (rangeInitialMin - rangeMean) + rangeMean;
            rangeInitialMax = trial.initialRangeMultiplier * (rangeInitialMax - rangeMean) + rangeMean;            
            
            trial.dataManager.addDataEntry('contexts', 4,  rangeInitialMin, rangeInitialMax);            
            
            obj.setupViaPoint(trial);            
            obj.setupRewardFunction(trial);

        end                
    end
    
end

