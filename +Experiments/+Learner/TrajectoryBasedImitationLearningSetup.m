classdef TrajectoryBasedImitationLearningSetup < Experiments.Configurator
    
    properties
        demonstrationFile
    end
    
    methods
        function obj = TrajectoryBasedImitationLearningSetup(demonstrationFile)
            obj = obj@Experiments.Configurator('InitialImitation');
            if (exist('demonstrationFile', 'var'))
                obj.demonstrationFile = demonstrationFile;
            else
                obj.demonstrationFile = [];
            end
            
        end
        
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.Configurator(trial);
            
            Common.Settings().setProperty('addInitialSigmaToImitation', 1);
            trial.setprop('imitationLearnerTrajectory', @TrajectoryGenerators.ImitationLearning.DMPsImitationLearner);
            trial.setprop('imitationDistributionLearner', @Learner.SupervisedLearner.LinearGaussianMLLearner);
            trial.setprop('imitationLearner', @TrajectoryGenerators.ImitationLearning.ParameterDistributionImitationLearner);
            
            %1 stands for imitation learning only from initial
            %demonstrations
            if (isempty(obj.demonstrationFile))
                if (~isprop('demonstrationFile', trial) || isempty(trial.demonstrationFile))
                    trial.setprop('imitationLearningType', 0);
                else
                    trial.setprop('initialDataFileName', trial.demonstrationFile);
                    trial.setprop('imitationLearningType', 1);
                end
            else
                trial.setprop('initialDataFileName', obj.demonstrationFile);
                trial.setprop('imitationLearningType', 1);
            end
        end
        
        function setupImitationLearning(obj, trial)
            if (trial.imitationLearningType > 0)
                trial.imitationLearnerTrajectory = trial.imitationLearnerTrajectory(trial.dataManager, trial.trajectoryGenerator);
                trial.imitationDistributionLearner = trial.imitationDistributionLearner(trial.dataManager, trial.parameterPolicy);
                trial.imitationLearner = trial.imitationLearner(trial.dataManager, trial.imitationLearnerTrajectory, trial.imitationDistributionLearner, trial.trajectoryGenerator);
                trial.initialLeaner = trial.imitationLearner;
            end
        end
        
        
        function postConfigureTrial(obj, trial)
            obj.setupImitationLearning(trial);
            obj.postConfigureTrial@Experiments.Configurator(trial);
        end
        
        
        function [] = setupScenarioForLearners(obj, trial)
            obj.setupScenarioForLearners@Experiments.Configurator(trial);            
        end
        
        function registerSamplers(obj, trial)
            obj.registerSamplers@Experiments.Configurator(trial);
        end
    end
    
end
