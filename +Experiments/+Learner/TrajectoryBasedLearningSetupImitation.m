classdef TrajectoryBasedLearningSetup < Experiments.Learner.BanditLearningSetup
    
    properties
        numJoints
        demonstrationFile
    end
    
    methods
        function obj = TrajectoryBasedLearningSetup(learnerName)
            obj = obj@Experiments.Learner.BanditLearningSetup(learnerName);
        end
         
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.Learner.BanditLearningSetup(trial);
                        
            trial.setprop('trajectoryPhase', []);            
            trial.setprop('trajectoryBasis', []);                        
            trial.setprop('trajectoryGenerator', @TrajectoryGenerators.DynamicMovementPrimitives);            
            trial.setprop('trajectoryTracker', @TrajectoryGenerators.TrajectoryTracker.LinearTrajectoryTracker);            
            
            trial.setprop('imitationLearnerTrajectory', @TrajectoryGenerators.ImitationLearning.DMPsImitationLearner);
            trial.setprop('imitationDistribution', @Distributions.Gaussian.GaussianParameterPolicy);
            trial.setprop('imitationDistributionLearner', @Learner.SupervisedLearner.LinearGaussianMLLearner);            
            trial.setprop('imitationLearner', @TrajectoryGenerators.ImitationLearning.ParameterDistributionImitationLearner);
            
            %1 stands for imitation learning only from initial
            %demonstrations
            trial.setprop('imitationLearningType', 0);
            
        end
        
        function setupInitialLearner(obj, trial)
            if (obj.imitationLearningType == 1 && ~isempty(trial.imitationDistributionLearner))
                trial.initialLeaner = trial.imitationLearner;
            else
                obj.setupInitialLearner@Experiments.Learner.BanditLearningSetup(trial);
            end
        end
        
        function setupImitationLearning(obj, trial)
            if (obj.imitationLearningType > 0)
                trial.imitationLearnerTrajectory = trial.imitationLearnerTrajectory(trial.dataManager, trial.trajectoryGenerator);
                trial.imitationDistribution = trial.imitationDistribution(trial.dataManager);
                trial.imitationDistributionLearner = trial.imitationDistributionLearner(trial.dataManager, trial.imitationDistribution);
                trial.imitationLearner = trial.imitationLearner(trial.dataManager, trial.imitationLearnerTrajectory, trial.imitationDistributionLearner, trial.trajectoryGenerator);                
            end
        end
        
        
        function postConfigureTrial(obj, trial)
            obj.setupTrajectoryGenerator(trial); 
            obj.setupImitationLearning(trial);
            obj.postConfigureTrial@Experiments.Learner.BanditLearningSetup(trial);                       
        end
        
        function [] = setupTrajectoryGenerator(obj, trial)
            if (~isempty(trial.trajectoryPhase))
                trial.trajectoryPhase = trial.trajectoryPhase(trial.dataManager);
            end
            
            if (~isempty(trial.trajectoryBasis))
                trial.trajectoryBasis = trial.trajectoryBasis(trial.dataManager, trial.trajectoryPhase);
            end
            
            trial.trajectoryGenerator = trial.trajectoryGenerator(trial.dataManager, trial.transitionFunction.dimAction, trial.trajectoryPhase, trial.trajectoryBasis);
            trial.trajectoryTracker = trial.trajectoryTracker(trial.dataManager, trial.transitionFunction.dimAction);
            trial.actionPolicy = trial.trajectoryTracker;

        end
        
        function [] = setupScenarioForLearners(obj, trial)  
            obj.setupScenarioForLearners@Experiments.Learner.BanditLearningSetup(trial);
            
            trial.scenario.addInitObject(trial.trajectoryPhase);
            trial.scenario.addInitObject(trial.trajectoryBasis); 
            trial.scenario.addInitObject(trial.trajectoryGenerator);
            trial.scenario.addInitObject(trial.trajectoryTracker);             
        end
        
        function registerSamplers(obj, trial)
            obj.registerSamplers@Experiments.Learner.BanditLearningSetup(trial);
            
            if (~isempty(trial.trajectoryGenerator))
                trial.sampler.addParameterPolicy(trial.trajectoryGenerator,'getReferenceTrajectory');
            end
        end
    end
    
end
