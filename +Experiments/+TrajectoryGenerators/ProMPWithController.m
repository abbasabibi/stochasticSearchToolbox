classdef ProMPWithController < Experiments.TrajectoryGenerators.TrajectoryBasedLearningSetup
    
    properties
    end
    
    methods
        function obj = ProMPWithController()
            obj = obj@Experiments.TrajectoryGenerators.TrajectoryBasedLearningSetup();                      
        end
         
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.TrajectoryGenerators.TrajectoryBasedLearningSetup(trial);
                        
            trial.setprop('trajectoryPhase', []);            
            trial.setprop('trajectoryBasis', []);                        
            trial.setprop('trajectoryGenerator', @TrajectoryGenerators.ProMPs.createFromTrial);            
            trial.setprop('trajectoryTracker', @TrajectoryGenerators.ProMPsCtl.createFromTrial);            
                      
        end                                            
        
        function registerSamplers(obj, trial)
            obj.registerSamplers@Experiments.TrajectoryGenerators.TrajectoryBasedLearningSetup(trial);
            
            trial.sampler.addSamplerFunctionToPool('ParameterPolicy','generatePhaseD', trial.trajectoryGenerator.phaseGenerator);
            trial.sampler.addSamplerFunctionToPool('ParameterPolicy','generatePhaseDD', trial.trajectoryGenerator.phaseGenerator);
            trial.sampler.addSamplerFunctionToPool('ParameterPolicy','generateBasisD', trial.trajectoryGenerator.basisGenerator);
            trial.sampler.addSamplerFunctionToPool('ParameterPolicy','generateBasisDD', trial.trajectoryGenerator.basisGenerator);

            trial.sampler.addSamplerFunctionToPool('ParameterPolicy', 'updateModel', trial.actionPolicy.gainProvider);
            
        end
    end
    
end
