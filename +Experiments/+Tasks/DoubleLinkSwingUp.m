classdef DoubleLinkSwingUp < Experiments.Tasks.StepBasedTask
    
    properties
        
    end
    
    methods
        function obj = DoubleLinkSwingUp()
            obj = obj@Experiments.Tasks.StepBasedTask('DoubleLinkSwingUp', false);
        end
        
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.Tasks.StepBasedTask(trial);
                        
            trial.setprop('initialRangeMultiplier', 1.0);           
            
            Common.SettingsManager.activateDebugMode();                        
            Common.Settings().setProperty('numTimeSteps', 70);                                        
            Common.Settings().setProperty('dt', 0.066);                  
        
            
            Common.Settings().setProperty('InitialStateDistributionMinRange', [pi - 0.05, - 0.1, - 0.05,- 0.1]);
            Common.Settings().setProperty('InitialStateDistributionMaxRange', [pi + 0.05, + 0.1, + 0.05,+ 0.1]);
            Common.Settings().setProperty('InitialStateDistributionType', 'Uniform');            
        end
                        
        function setupRewardFunction(obj, trial)
            trial.rewardFunction = RewardFunctions.SwingUpRewardFunction(trial.dataManager, trial.transitionFunction);
            %trial.rewardFunction = RewardFunctions.test.TimeDependentRewardTest(trial.settings, trial.sampler);
        end
        
        function setupEnvironment(obj, trial)
                       
            trial.transitionFunction = Environments.DynamicalSystems.DoubleLink(trial.sampler, true);
            trial.dataManager.setRestrictToRange('actions', true); % get rid of restriction for now
            obj.setupRewardFunction(trial);
            trial.dataManager.setRange('actions', -[15, 15], [15, 15]);
            %trial.dataManager.addDataEntry('contexts', 4,  rangeInitialMin, rangeInitialMax);            
            
            
            

        end                
    end
    
end

