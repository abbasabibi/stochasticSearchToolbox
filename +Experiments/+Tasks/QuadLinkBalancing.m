classdef QuadLinkBalancing < Experiments.Tasks.StepBasedTask
    
    properties
        
    end
    
    methods
        function obj = QuadLinkBalancing()
            obj = obj@Experiments.Tasks.StepBasedTask('QuadLinkBalancing', false);
        end
        
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.Tasks.StepBasedTask(trial);
                        
            Common.SettingsManager.activateDebugMode();
                        
            Common.Settings().setProperty('numTimeSteps', 150);                                        
            Common.Settings().setProperty('dt', 0.066);            
            Common.Settings().setProperty('Noise_std', 0.5);
        end
                
        
        function setupRewardFunction(obj, trial)
            trial.rewardFunction = RewardFunctions.BalancingRewardFunction(trial.dataManager);            
        end
        
        function setupEnvironment(obj, trial)
                       
            trial.transitionFunction = Environments.DynamicalSystems.QuadLink(trial.sampler);
            
            rangeInitialMin = [0.01, - 0.01, - 0.01,- 0.01, - 0.01,- 0.01, - 0.01,- 0.01];
            rangeInitialMax = [0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01];            
            trial.dataManager.setRange('actions', [-10, -10, -10, -10], [10, 10, 10, 10]);            
            trial.dataManager.setPeriodicity('states', [true, false, true, false, true, false, true, false]);
            trial.dataManager.addDataEntry('contexts', 8,  rangeInitialMin, rangeInitialMax);            
            
            obj.setupRewardFunction(trial);
            
            trial.sampler.stepSampler.setIsActiveSampler(trial.rewardFunction);
            trial.returnSampler = RewardFunctions.ReturnForEpisode.ReturnDecayedSummedReward(trial.dataManager);
        end                
    end
    
end

