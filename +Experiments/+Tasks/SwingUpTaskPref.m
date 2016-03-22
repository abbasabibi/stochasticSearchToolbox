classdef SwingUpTaskPref < Experiments.Tasks.StepBasedTask
    
    properties
        
    end
    
    methods
        function obj = SwingUpTaskPref(isInfiniteHorizon)
            obj = obj@Experiments.Tasks.StepBasedTask('SwingUp', isInfiniteHorizon);
        end
        
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.Tasks.StepBasedTask(trial);
                        
            Common.SettingsManager.activateDebugMode();
            
           
            trial.setprop('stateCost',[10 0; 0 0]);

            

            trial.setprop('numDimensions',1);
            %trial.setprop('numSamples',10);
            trial.setprop('maxFeat',3000);
            trial.setprop('isPeriodic',false);
                        
            trial.setprop('InitialConfigurationRange', [-0.2 0.2] +  pi);
            trial.setprop('stateDim',2);
            trial.setprop('actionDim',1);
            trial.setprop('restrictToRange',0);
            
            trial.setprop('rewardFunction');
        end
                
        
        function setupRewardFunction(obj, trial)
            
            trial.setprop('viaPoint');
            trial.viaPoint.times   = [41:60]; 
            trial.viaPoint.factors = repmat([1e4, 1e3], length(trial.viaPoint.times), 1);
            for i = 1:length(trial.viaPoint.factors)
                trial.viaPoint.points{i}  = [0.0, 0.0];
            end
               
            trial.viaPoint.uFactor = 10^-3;
            
            %trial.rewardFunction = RewardFunctions.TimeDependent.ViaPointRewardFunction(trial.dataManager, trial.viaPoint.times,trial.viaPoint.points,trial.viaPoint.factors,trial.viaPoint.uFactor);
          
            trial.rewardFunction = RewardFunctions.TimeDependent.QuadraticRewardFunctionSwingUpFiniteHorizon(trial.dataManager);
        end
        
        function setupEnvironment(obj, trial)
            %trial.sampler.numSamples = trial.numSamples;      

            trial.transitionFunction = Environments.DynamicalSystems.PendulumNew(trial.sampler, trial.isPeriodic);
            trial.transitionFunction.initObject;
            trial.transitionFunction.friction = 0.0;
            
            trial.dataManager.addDataEntry('contexts', 2, [trial.InitialConfigurationRange(1), 0], [trial.InitialConfigurationRange(2), 0]);
             
            if (~trial.restrictToRange)
                trial.dataManager.setRestrictToRange('actions', false);
            end
    
            obj.setupRewardFunction(trial);

        end                
    end
    
end

