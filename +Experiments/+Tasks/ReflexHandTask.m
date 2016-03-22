classdef ReflexHandTask < Experiments.Tasks.StepBasedTaskExternal
    

    
    methods
        function obj = ReflexHandTask()
            obj = obj@Experiments.Tasks.StepBasedTaskExternal('ReflexTask');
        end
        
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.Tasks.StepBasedTaskExternal(trial);
                        
            Common.SettingsManager.activateDebugMode();
            Common.Settings().setProperty('actionCost',0.001);
            trial.setprop('stateCost',1);
            trial.setprop('maxFeat',3000);
            Common.Settings().setProperty('initSigmaActions',0.5);
            Common.Settings().setProperty('resetProbTimeSteps',0.02);
            Common.Settings().setProperty('regularizationRegression',10^-2);
            Common.Settings().setProperty('modelLambda',1e-2); 
            

           
        end
                
        
        function setupRewardFunction(obj, trial)
            rfc = RewardFunctions.ReflexRollingRewards(trial.dataManager);
            
            trial.rewardFunction = rfc;
            %trial.rewardFunction = RewardFunctions.test.TimeDependentRewardTest(trial.settings, trial.sampler);
        end
        
        function setupEnvironment(obj, trial)
            dimState = 6;
            dimAction = 2;
            trial.dataManager.addDataEntry('steps.states', dimState);
            trial.dataManager.addDataEntry('steps.nextStates', dimState);
            trial.dataManager.addDataEntry('steps.actions', dimAction);
            trial.dataManager.addDataEntry('steps.timeSteps', 1);
            trial.dataManager.setRestrictToRange('actions', true);       
            
            trial.dataManager.setRange('actions', -[0.05 0.05], [0.05 0.05]);                  
            trial.dataManager.setRange('states', -100*ones(1,dimState), 100*ones(1,dimState));  
            trial.dataManager.setRange('nextStates', -100*ones(1,dimState), 100*ones(1,dimState));  
            trial.dataManager.setPeriodicity('states',zeros(1,dimState));
            trial.dataManager.setPeriodicity('nextStates',zeros(1,dimState));
            obj.setupRewardFunction(trial);
                          
        
            
        end         

        

        
        

    end
end


