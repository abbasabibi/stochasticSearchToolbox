classdef TrajectoryBasedLearningSetup < Experiments.Configurator
    
    properties
        numJoints
        
    end
    
    methods
        function obj = TrajectoryBasedLearningSetup()
            obj = obj@Experiments.Configurator('TrajectoryBased');                      
        end
         
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.Configurator(trial);
                        
            trial.setprop('trajectoryPhase', []);            
            trial.setprop('trajectoryBasis', []);                        
            trial.setprop('trajectoryGenerator', @TrajectoryGenerators.DynamicMovementPrimitives.createFromTrial);            
            trial.setprop('trajectoryTracker', @TrajectoryGenerators.TrajectoryTracker.LinearTrajectoryTracker.createFromTrial);            
                      
        end                                            
        
        function postConfigureTrial(obj, trial)
            obj.setupTrajectoryGenerator(trial);
            obj.postConfigureTrial@Experiments.Configurator(trial);                       
        end
               
        
        function [] = setupTrajectoryGenerator(obj, trial)
            if (~isempty(trial.trajectoryPhase))
                trial.trajectoryPhase = trial.trajectoryPhase(trial.dataManager);
            end
            
            if (~isempty(trial.trajectoryBasis))
                trial.trajectoryBasis = trial.trajectoryBasis(trial.dataManager, trial.trajectoryPhase);
            end
            
            trial.setprop('numJoints', trial.dataManager.getNumDimensions('actions'));
            trial.trajectoryGenerator = trial.trajectoryGenerator(trial);
            trial.trajectoryTracker = trial.trajectoryTracker(trial);
            
            if (trial.isProperty('actionPolicy'))
                trial.actionPolicy = trial.trajectoryTracker;
            end
        end
        
        function [] = setupScenarioForLearners(obj, trial)  
            obj.setupScenarioForLearners@Experiments.Configurator(trial);
            
            trial.scenario.addInitObject(trial.trajectoryPhase);
            trial.scenario.addInitObject(trial.trajectoryBasis); 
            trial.scenario.addInitObject(trial.trajectoryGenerator);
            trial.scenario.addInitObject(trial.trajectoryTracker);             
        end
        
        function registerSamplers(obj, trial)
            obj.registerSamplers@Experiments.Configurator(trial);
            
            if (~isempty(trial.trajectoryGenerator))
                trial.sampler.addSamplerFunctionToPool('ParameterPolicy', 'getReferenceTrajectory', trial.trajectoryGenerator);
            end
        end
    end
    
end
