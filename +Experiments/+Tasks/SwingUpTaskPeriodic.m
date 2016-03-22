classdef SwingUpTaskPeriodic < Experiments.Tasks.StepBasedTask
    
    properties
        
    end
    
    methods
        function obj = SwingUpTaskPeriodic(isInfiniteHorizon)
            obj = obj@Experiments.Tasks.StepBasedTask('SwingUp', isInfiniteHorizon);
        end
        
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.Tasks.StepBasedTask(trial);
                        
            Common.SettingsManager.activateDebugMode();
            
            %trial.setprop('actionCost',0.001);
            Common.Settings().setProperty('actionCost',0.001);
            trial.setprop('stateCost',[10 0; 0 0.1]);

            

            trial.setprop('numDimensions',1);
            trial.setprop('numSamples',10);
            trial.setprop('maxFeat',3000);
            Common.Settings().setProperty('initSigmaActions',0.5);
            Common.Settings().setProperty('numInitialSamplesEpisodes',30);
            Common.Settings().setProperty('Noise_std',1);
            Common.Settings().setProperty('resetProbTimeSteps',0.02);
            Common.Settings().setProperty('maxSamples',30);
            

            Common.Settings().setProperty('regularizationRegression',10^-2);

            Common.Settings().setProperty('modelLambda',1e-2); 

            
            trial.setprop('stateDim',2);
            trial.setprop('actionDim',1);
            trial.setprop('restrictToRange',true);
        end
                
        
        function setupRewardFunction(obj, trial)
            rfc = RewardFunctions.QuadraticRewardFunction(trial.dataManager);
            rfc.setStateActionCosts(trial.stateCost, Common.Settings().getProperty('actionCost'));
            trial.rewardFunction = rfc;
            %trial.rewardFunction = RewardFunctions.test.TimeDependentRewardTest(trial.settings, trial.sampler);
        end
        
        function setupEnvironment(obj, trial)
            trial.sampler.numSamples = trial.numSamples;      

            trial.transitionFunction = Environments.DynamicalSystems.PendulumPeriodic(trial.sampler);
            trial.transitionFunction.initObject;
            trial.dataManager.addDataEntry('contexts', 2, [0.8*pi, 0], [1.2*pi, 0]);
            %rangeInitial = repmat([0.01, 0.05], 1, trial.numDimensions);
            %trial.dataManager.addDataEntry('contexts', trial.numDimensions * 2, -rangeInitial, rangeInitial);            
            
            if (~trial.restrictToRange)
                trial.dataManager.setRestrictToRange('actions', false);
            end
    
            obj.setupRewardFunction(trial);

        end                
    end
    
end

