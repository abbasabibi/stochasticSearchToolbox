classdef SwingUpTaskPrefNoTD < Experiments.Tasks.StepBasedTask
    
    properties
        
    end
    
    methods
        function obj = SwingUpTaskPrefNoTD(isInfiniteHorizon)
            obj = obj@Experiments.Tasks.StepBasedTask('SwingUp', isInfiniteHorizon);
        end
        
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.Tasks.StepBasedTask(trial);
                        
            Common.SettingsManager.activateDebugMode();
            
            trial.setprop('actionCost',0.000);
            trial.setprop('stateCost',[10 0; 0 0]);

            

            trial.setprop('numDimensions',1);
            %trial.setprop('numSamples',10);
            trial.setprop('maxFeat',3000);
            trial.setprop('isPeriodic',true);
            
            Common.Settings().setProperty('initSigmaActions',0.5);
            Common.Settings().setProperty('numInitialSamplesEpisodes',40);
            Common.Settings().setProperty('Noise_std',1);
            Common.Settings().setProperty('resetProbTimeSteps',0.02);
            Common.Settings().setProperty('maxSamples',40);
            Common.Settings().setProperty('tolSF',0.01);
            Common.Settings().setProperty('maxNumOptiIterations',10);
            %Common.Settings().setProperty('maxOptiSteps',10);
            Common.Settings().setProperty('regularizationRegression',10^-2);

            Common.Settings().setProperty('modelLambda',1e-2); 
            Common.Settings().setProperty('stateParams',[1, 1.4,6.9]); 
            Common.Settings().setProperty('actionParams',[1 22]);
            
            trial.setprop('InitialConfigurationRange', [0.625 * pi, 0.875*pi]);
            trial.setprop('stateDim',2);
            trial.setprop('actionDim',1);
            trial.setprop('restrictToRange',1);
            
            trial.setprop('rewardFunction', @RewardFunctions.QuadraticPeriodicRewardFunction);
        end
                
        
        function setupRewardFunction(obj, trial)
            rfc = trial.rewardFunction(trial.dataManager);
            rfc.setStateActionCosts(trial.stateCost, trial.actionCost);
            trial.rewardFunction = rfc;
            %trial.rewardFunction = RewardFunctions.test.TimeDependentRewardTest(trial.settings, trial.sampler);
        end
        
        function setupEnvironment(obj, trial)
            %trial.sampler.numSamples = trial.numSamples;      

            trial.transitionFunction = Environments.DynamicalSystems.Pendulum(trial.sampler, trial.isPeriodic);
            trial.transitionFunction.initObject;
            %trial.dataManager.addDataEntry('contexts', 2, [trial.InitialConfigurationRange(1), 0], [trial.InitialConfigurationRange(2), 0]);
            %rangeInitial = repmat([0.01, 0.05], 1, trial.numDimensions);
            %trial.dataManager.addDataEntry('contexts', trial.numDimensions * 2, -rangeInitial, rangeInitial);            
            
            if (~trial.restrictToRange)
                trial.dataManager.setRestrictToRange('actions', false);
            end
    
            obj.setupRewardFunction(trial);

        end                
    end
    
end

