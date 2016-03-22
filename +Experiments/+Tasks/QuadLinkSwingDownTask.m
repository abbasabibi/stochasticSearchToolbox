classdef QuadLinkSwingDownTask < Experiments.Tasks.StepBasedTask
    
    properties
        
    end
    
    methods
        function obj = QuadLinkSwingDownTask(isInfiniteHorizon)
            obj = obj@Experiments.Tasks.StepBasedTask('QuadLinkSwingDown', isInfiniteHorizon);
        end
        
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.Tasks.StepBasedTask(trial);
                        
            Common.SettingsManager.activateDebugMode();
            
            trial.setprop('maxSamples',1e6);
            
            trial.setprop('actionCost',0.001);
            trial.setprop('stateCost',[10 0 0 0; 0 0 0 0]);
            
            trial.setprop('isPeriodic',false);
            
            trial.setprop('evaluationObservations');
            trial.setprop('evaluationGroundtruth');
            trial.setprop('evaluationValid');
            trial.setprop('evaluationObservationIndex');
            trial.setprop('evaluationMetric','mse');
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
            trial.transitionFunction = Environments.DynamicalSystems.QuadLink(trial.sampler);
            trial.transitionFunction.friction = ones(4,1) * 0.5;
            %trial.transitionFunction.masses = 1;
            
            trial.setprop('featureEndEffector', Environments.Misc.PlanarKinematicsEndEffPositionFeature(trial.dataManager, trial.transitionFunction));
            
            
            trial.dataManager.addDataEntry('contexts', 8, [-.55*pi, 0, 0, 0, 0, 0, -.5 * pi, 0], [-.45*pi, 0, 0, 0, 0, 0, .5 * pi, 0]);
%             trial.dataManager.addDataEntry('contexts', 8, [-.25*pi, -0.5*pi, -.25 * pi, -0.5*pi, -.25*  pi, -0.5*pi, -.25* pi, -0.5*pi], [.25*pi, 0.5*pi, .25*pi, 0.5*pi, .25* pi, 0.5*pi, .25 * pi, 0.5*pi]);
            Common.Settings().setProperty('InitialContextDistributionType', 'Uniform');
            trial.sampler.setContextSampler(Sampler.InitialSampler.InitialContextSamplerStandard(trial.sampler));
            trial.sampler.setInitialStateSampler(trial.transitionFunction);
            trial.sampler.setParallelSampling(true);
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

