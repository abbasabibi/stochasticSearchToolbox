classdef SwingTask < Experiments.Tasks.StepBasedTask
    
    properties
        
    end
    
    methods
        function obj = SwingTask(isInfiniteHorizon)
            obj = obj@Experiments.Tasks.StepBasedTask('Swing', isInfiniteHorizon);
        end
        
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.Tasks.StepBasedTask(trial);
                        
            Common.SettingsManager.activateDebugMode();
            
            trial.setprop('maxSamples',1e6);
            
            trial.setprop('actionCost',0.001);
            trial.setprop('stateCost',[10 0; 0 0]);
            
            trial.setprop('isPeriodic',false);
            
            trial.setprop('evaluationObservations');
            trial.setprop('evaluationGroundtruth');
            trial.setprop('evaluationValid');
            trial.setprop('evaluationObservationIndex');
        end
        
        function postConfigureTrial(obj, trial)
            obj.postConfigureTrial@Experiments.Tasks.StepBasedTask(trial);
            
            Common.Settings().setProperty('maxSamples',trial.maxSamples);
        end
                
        
        function setupRewardFunction(obj, trial)
            rfc = RewardFunctions.QuadraticRewardFunctionSwingUp(trial.dataManager);
            rfc.setStateActionCosts(trial.stateCost, trial.actionCost);
            trial.rewardFunction = rfc;
        end
        
        function setupEnvironment(obj, trial) 
            trial.transitionFunction = Environments.DynamicalSystems.Pendulum(trial.sampler, trial.isPeriodic);
            trial.transitionFunction.friction = 1;
            trial.transitionFunction.masses = 5;
            
            trial.dataManager.addDataEntry('contexts', 2, [.1*pi, -.5*pi], [.4*pi, .5*pi]);
            Common.Settings().setProperty('InitialContextDistributionType', 'Uniform');
            trial.sampler.setContextSampler(Sampler.InitialSampler.InitialContextSamplerStandard(trial.sampler));
            trial.sampler.setInitialStateSampler(trial.transitionFunction);
            trial.transitionFunction.initObject;   
    
            obj.setupRewardFunction(trial);

        end
        
        
        
        function addDefaultCriteria(obj, trial, evaluationCriterion)  
            obj.addDefaultCriteria@Experiments.Tasks.BanditTask(trial, evaluationCriterion);

            evaluationCriterion.addSaveDataEntry('filteredMu');
            evaluationCriterion.addSaveDataEntry('filteredVar');

        end
    end
    
end

