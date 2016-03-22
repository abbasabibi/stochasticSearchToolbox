classdef PlanarHoleReaching < Experiments.Tasks.StepBasedTask
    
    properties
        
    end
    
    methods
        function obj = PlanarHoleReaching()
            obj = obj@Experiments.Tasks.StepBasedTask('PlanarHoleReaching', false);
        end
        
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.Tasks.StepBasedTask(trial);
            
            Common.SettingsManager.activateDebugMode();
            
            
            Common.Settings().setProperty('numTimeSteps', 100);
            Common.Settings().setProperty('dt', 0.03);
            Common.Settings().setProperty('InitialContextDistributionType', 'Uniform');
            
            trial.setprop('numJoints', 5)
            trial.setprop('planarKinematics')
            
        end
        
        function setupViaPoint(obj,trial)
            trial.setprop('viaPoint');
            if(isempty(trial.viaPoint))
                trial.viaPoint.times   = 100;
                trial.viaPoint.factors = repmat([1e5, 1e5, 0, 0], length(trial.viaPoint.times), 1);
                wallPos = 2;
                trial.viaPoint.reachingStateOnWall{1} = [wallPos,0, 0.0, 0.0 ];
                trial.viaPoint.holeRadius = 0.15;
                %trial.viaPoint.points{1}  = [1.0, 1.0, 0.0, 0.0];
                %trial.viaPoint.points{2}  = [trial.numJoints, 0.0, 0.0, 0.0];
                trial.viaPoint.uFactor = 1 * 10^1;
                
                %trial.viaPoint.times   = [30, 100];
                %trial.viaPoint.factors = repmat([1e4, 1e1], length(trial.viaPoint.times), trial.numJoints);
                %trial.viaPoint.points{1}  = repmat([3.0, 0.0], 1, trial.numJoints);
                %trial.viaPoint.points{2}  = repmat([0.0, 0.0], 1, trial.numJoints);
                %trial.viaPoint.uFactor = 0.5 * 10^-1;
                Common.Settings().setProperty('GoalPos', [pi / 2, 0, 0, 0, 0]);
            end
        end
        
        function setupRewardFunction(obj, trial)
            
            trial.rewardFunction = RewardFunctions.TimeDependent.TaskSpaceWallHoleRewardFunction(trial.dataManager,trial.planarKinematics, trial.viaPoint.times...
                ,trial.viaPoint.holeRadius,trial.viaPoint.reachingStateOnWall,trial.viaPoint.factors,trial.viaPoint.uFactor);
            %trial.rewardFunction = RewardFunctions.TimeDependent.TaskSpaceViaPointRewardFunction(trial.dataManager, trial.planarKinematics, trial.viaPoint.times,trial.viaPoint.points,trial.viaPoint.factors,trial.viaPoint.uFactor);
            %trial.rewardFunction = RewardFunctions.TimeDependent.ViaPointRewardFunction(trial.dataManager, trial.viaPoint.times,trial.viaPoint.points,trial.viaPoint.factors,trial.viaPoint.uFactor);
        end
        
        function setupEnvironment(obj, trial)
            trial.transitionFunction = Environments.DynamicalSystems.LinearSystem(trial.sampler, trial.numJoints);
            trial.planarKinematics = Environments.Misc.PlanarForwardKinematics(trial.dataManager, trial.numJoints);
            %            rangeInitialMin = zeros(1, obj.numJoints * 2);
            %            rangeInitialMax = zeros(1, obj.numJoints * 2);
            trial.dataManager.setRange('actions', -200 * ones(1, trial.numJoints), 200 * ones(1, trial.numJoints));
            trial.initialStateSampler = Sampler.InitialSampler.InitialStateDynamicalSystem(trial.sampler);
            trial.contextSampler =  Sampler.InitialSampler.InitialDuplicatorContextSampler(trial.sampler);
            obj.setupViaPoint(trial);
            obj.setupRewardFunction(trial);
        end
        
        function addDefaultCriteria(obj, trial, evaluationCriterion)
            obj.addDefaultCriteria@Experiments.Tasks.StepBasedTask(trial, evaluationCriterion);
            
            evaluationCriterion.addSaveDataEntry('endEffPositions');
            evaluationCriterion.addSaveDataEntry('endEffPositionsTag');
            evaluationCriterion.addSaveDataEntry('endEffVelocities');
            evaluationCriterion.addSaveDataEntry('endEffVelocitiesTag');
            evaluationCriterion.addSaveDataEntry('Weights');
            evaluationCriterion.addSaveDataEntry('ViaPointContext');

        end
    end
    
end

