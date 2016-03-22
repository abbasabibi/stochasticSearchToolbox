classdef PlanarReachingInfHorizon < Experiments.Tasks.StepBasedTask
    
    properties
        
    end
    
    methods
        function obj = PlanarReachingInfHorizon()
            obj = obj@Experiments.Tasks.StepBasedTask('PlanarReaching', true);
        end
        
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.Tasks.StepBasedTask(trial);
                        
            Common.SettingsManager.activateDebugMode();
            
            
            Common.Settings().setProperty('resetProbTimeSteps',0.04);                                        
            Common.Settings().setProperty('dt', 0.03);                                        
            Common.Settings().setProperty('stateCost',1);
            Common.Settings().setProperty('actionCost',0.0001);
            trial.setprop('numJoints', 5);
            trial.setprop('planarKinematics');
            trial.setprop('desPos',zeros(2, 1)); % in task space
            %trial.setprop('stateCost', 1);
            %trial.setprop('actionCost', 0.0001);
            
        end
                
       
        function setupRewardFunction(obj, trial)
            rwf = RewardFunctions.TaskSpaceQuadraticRewardFunction(trial.dataManager, trial.planarKinematics) ;
            sc = Common.Settings().getProperty('stateCost');
            ac = Common.Settings().getProperty('actionCost');
            rwf.setStateActionCosts(sc, ac);
            rwf.setDesiredPosition(trial.desPos);
            trial.rewardFunction = rwf;
        end
        
        function setupEnvironment(obj, trial)
            trial.transitionFunction = Environments.DynamicalSystems.LinearSystem(trial.sampler, trial.numJoints);
            trial.planarKinematics = Environments.Misc.PlanarForwardKinematics(trial.dataManager, trial.numJoints);
          
            trial.dataManager.setRange('actions', -50 * ones(1, trial.numJoints), 50 * ones(1, trial.numJoints));                  
            trial.dataManager.setRange('states', -[10, pi, 10, pi], [10, pi, 10, pi]);  
            trial.initialStateSampler = Sampler.InitialSampler.InitialStateDynamicalSystem(trial.sampler);
            trial.dataManager.setPeriodicity('states',[1 0 1 0]);
            trial.transitionFunction.initObject;
            %obj.setupViaPoint(trial);            
            obj.setupRewardFunction(trial);
        end                
        
        function addDefaultCriteria(obj, trial, evaluationCriterion)  
            obj.addDefaultCriteria@Experiments.Tasks.StepBasedTask(trial, evaluationCriterion);

            evaluationCriterion.addSaveDataEntry('endEffPositions');
            evaluationCriterion.addSaveDataEntry('endEffPositionsTag');
            evaluationCriterion.addSaveDataEntry('endEffVelocities');
            evaluationCriterion.addSaveDataEntry('endEffVelocitiesTag');
            evaluationCriterion.addSaveDataEntry('Weights');
        end
    end
    
end

