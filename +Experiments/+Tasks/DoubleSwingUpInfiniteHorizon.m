classdef DoubleSwingUpInfiniteHorizon < Experiments.Tasks.StepBasedTask
    
    properties
        
    end
    
    methods
        function obj = DoubleSwingUpInfiniteHorizon()
            obj = obj@Experiments.Tasks.StepBasedTask('DoubleSwingUpInf', true);
        end
        
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.Tasks.StepBasedTask(trial);
                        
            Common.SettingsManager.activateDebugMode();
            
            %trial.setprop('actionCost',0.001);
            %Common.Settings().setProperty('actionCost',0.001);
            %trial.setprop('stateCost',[10 0; 0 0.1]);

            

            trial.setprop('numDimensions',2);
            
            trial.setprop('maxFeat',1500);
            %Common.Settings().setProperty('initSigmaActions',sqrt(1/12)); 
            %same initial variance as uniform distribution 
            % (marc uses uniform)
            Common.Settings().setProperty('initSigmaActions',0.5); 
            
            Common.Settings().setProperty('maxSamples',30);
            Common.Settings().setProperty('numInitialSamplesEpisodes',30);
            trial.setprop('numSamples',10);
            
            Common.Settings().setProperty('Noise_std',0.0001);
            Common.Settings().setProperty('dt', 0.1); 
            Common.Settings().setProperty('resetProbTimeSteps',0.04); 
            %expected horizon of 24 steps = 2.4 s, 
            %close to 2.55 in Marc's paper
            % need approx 1.5 seconds to maximum
            
              

            Common.Settings().setProperty('regularizationRegression',10^-2);
            Common.Settings().setProperty('modelLambda',1e-2); 
            
            trial.setprop('stateDim',4);
            trial.setprop('actionDim',2);
            
        end
                
        
        function setupRewardFunction(obj, trial)
            rfc = RewardFunctions.ExpQuadEuclidRewardFunction(trial.dataManager, trial.transitionFunction);
            rfc.setAFactor(0.5 );
            rfc.setDesiredStates([0 1.2]);
            trial.rewardFunction = rfc;
            %trial.rewardFunction = RewardFunctions.test.TimeDependentRewardTest(trial.settings, trial.sampler);
        end
        
        function setupEnvironment(obj, trial)
            trial.sampler.numSamples = trial.numSamples;      

            trial.transitionFunction = Environments.DynamicalSystems.DoubleLink(trial.sampler);
            trial.transitionFunction.lengths 	= [0.5 0.5]; %according to marcs code (not thesis)
		    trial.transitionFunction.masses 	= [0.5 0.5];
		    trial.transitionFunction.friction = [0.0, 0.0];
            trial.dataManager.setRange('actions', -[2, 2], [2, 2]);
            trial.transitionFunction.initObject;
            epsilon = 0.1;
            trial.dataManager.addDataEntry('contexts', 4, ...
                [pi-epsilon, -epsilon, -epsilon,  -epsilon], ...
                [pi+epsilon, epsilon, epsilon,  epsilon]);
            %rangeInitial = repmat([0.01, 0.05], 1, trial.numDimensions);
            %trial.dataManager.addDataEntry('contexts', trial.numDimensions * 2, -rangeInitial, rangeInitial);            
            
    
            obj.setupRewardFunction(trial);

        end                
    end
    
end

