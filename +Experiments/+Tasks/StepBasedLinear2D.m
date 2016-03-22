classdef StepBasedLinear2D < Experiments.Tasks.StepBasedTask
    
    properties
        
    end
    
    methods
        function obj = StepBasedLinear2D(isInfiniteHorizon)
            obj = obj@Experiments.Tasks.StepBasedTask('StepBasedLinear', isInfiniteHorizon);
        end
        
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.Tasks.StepBasedTask(trial);
                        
            Common.SettingsManager.activateDebugMode();
            
            trial.setprop('actionCost',0.001);
            trial.setprop('stateCost',diag([10 0.1 10 0.1]));

            trial.setprop('numDimensions',2);
            trial.setprop('numSamples',10);
            trial.setprop('maxFeat',600);
            Common.Settings().setProperty('numInitialSamplesEpisodes',30);
            
            Common.Settings().setProperty('initSigmaActions',0.5);

            Common.Settings().setProperty('Noise_std',0.1);
            Common.Settings().setProperty('resetProbTimeSteps',0.1);
            Common.Settings().setProperty('maxSamples',30);
            Common.Settings().setProperty('maxNumOptiIterations',10);
            Common.Settings().setProperty('regularizationRegression',1e-2);
            Common.Settings().setProperty('tolSF',0.0001);% squared features:0.02
              
            trial.setprop('stateDim',trial.numDimensions*2);
            trial.setprop('actionDim',trial.numDimensions);
            Common.Settings().setProperty('modelLambda',1e-4); 
            
        end
                
        
        function setupRewardFunction(obj, trial)
            rfc = RewardFunctions.QuadraticRewardFunction(trial.dataManager);
            rfc.setStateActionCosts(trial.stateCost, trial.actionCost);
            trial.rewardFunction = rfc;
            
        end
        
        function setupEnvironment(obj, trial)
            trial.sampler.numSamples = trial.numSamples;           
            trial.transitionFunction = Environments.DynamicalSystems.LinearSystem(trial.sampler, trial.numDimensions);
            
            
            trial.dataManager.addDataEntry('contexts', trial.stateDim, -ones(1,trial.stateDim), ones(1,trial.stateDim));
            obj.setupRewardFunction(trial);

        end                
    end
    
end

