classdef FeatureLinearGaussianTime < Experiments.Features.FeatureConfigurator
    
    properties
        
    end
    
    methods
        function obj = FeatureLinearGaussianTime()
            obj = obj@Experiments.Features.FeatureConfigurator('LinGaussTime');
        end
        
        
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.Features.FeatureConfigurator(trial);
            
            trial.setprop('phaseGenerator',@(trial_) TrajectoryGenerators.PhaseGenerators.PhaseGenerator(trial_.dataManager,'~phase',-1));
            trial.setprop('basisGenerator',@(trial_) TrajectoryGenerators.BasisFunctions.NormalizedGaussianBasisGenerator(trial_.dataManager,trial_.phaseGenerator));
            
            trial.setprop('phaseGeneratorNext',@(trial_) TrajectoryGenerators.PhaseGenerators.PhaseGenerator(trial_.dataManager,'~nextPhase',1));
            trial.setprop('basisGeneratorNext',@(trial_) TrajectoryGenerators.BasisFunctions.NormalizedGaussianBasisGenerator(trial_.dataManager,trial_.phaseGeneratorNext,'basisNext'));
            
            trial.setprop('linearStates',@(trial_) FeatureGenerators.LinearFeatures(trial_.dataManager, 'states',':',true));
            trial.setprop('linearNextStates',@(trial_) FeatureGenerators.LinearFeatures(trial_.dataManager, 'nextStates',':',true));
            
            trial.setprop('stateFeatures');
            trial.setprop('nextStateFeatures');
            
            
        end
        
        function setupFeatures(obj, trial)
            if(~isobject(trial.basisGenerator))
                trial.phaseGenerator = trial.phaseGenerator(trial);
                trial.basisGenerator = trial.basisGenerator(trial);
                trial.sampler.addSamplerFunctionToPool('InitEpisode', 'generatePhase', trial.phaseGenerator, -1 );
                trial.sampler.addSamplerFunctionToPool('InitEpisode', 'generateBasis', trial.basisGenerator, -1 );
                
                trial.phaseGeneratorNext = trial.phaseGeneratorNext(trial);
                trial.basisGeneratorNext = trial.basisGeneratorNext(trial);
                trial.sampler.addSamplerFunctionToPool('InitEpisode', 'generatePhase', trial.phaseGeneratorNext, -1 );
                trial.sampler.addSamplerFunctionToPool('InitEpisode', 'generateBasis', trial.basisGeneratorNext, -1 );                

            end
            
            trial.linearStates = trial.linearStates(trial);
            trial.linearNextStates = trial.linearNextStates(trial);
            
            trial.stateFeatures = FeatureGenerators.BasisFunctionsFeatures(trial.dataManager, trial.linearStates,'basis',':','~stateFeatures');
            trial.nextStateFeatures = FeatureGenerators.BasisFunctionsFeatures(trial.dataManager, trial.linearNextStates,'basisNext',':','~nextStateFeatures');
            %trial.stateKernel = trial.stateKernel(trial);
            
            %obj.setupFeatures@Experiments.Features.FeatureConfigurator(trial);
            %trial.stateKernelReferenceSetLearner = trial.stateKernelReferenceSetLearner(trial, 'stateFeatures', 'states');
            %trial.nextStateFeatures.setExternalReferenceSet(trial.stateFeatures);
            
        end
        
        function [] = setupScenarioForLearners(obj, trial)
            trial.scenario.addLearner(trial.stateFeatures);
            trial.scenario.addLearner(trial.nextStateFeatures);
            obj.setupScenarioForLearners@Experiments.Features.FeatureConfigurator(trial);
        end
        
        
    end
end
