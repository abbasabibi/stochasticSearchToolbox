classdef FeatureQuadraticGaussianTimeAction < Experiments.Features.ActionFeatureConfigurator
    
    properties
        
    end
    
    methods
        function obj = FeatureQuadraticGaussianTimeAction()
            obj = obj@Experiments.Features.ActionFeatureConfigurator('SquaredGaussTime');
            obj.name = [obj.name, 'Actions'];
        end
        
        
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.Features.ActionFeatureConfigurator(trial);
            
            trial.setprop('phaseGenerator',@(trial_) TrajectoryGenerators.PhaseGenerators.PhaseGenerator(trial_.dataManager, '~phase'));
            trial.setprop('basisGenerator',@(trial_) TrajectoryGenerators.BasisFunctions.NormalizedGaussianBasisGenerator(trial_.dataManager,trial_.phaseGenerator));
            
            %assert(isprop(trial, 'stateFeatures'), 'State Features must be configured before!');
            
            trial.setprop('squaredStateActionFeatures',@(trial_) FeatureGenerators.SquaredFeatures(trial_.dataManager, {'states','actions'}, ':', true,'~squaredStateActionFeatures'));
            trial.setprop('stateActionFeatures');
            trial.setprop('nextStateActionFeatures');
            
            trial.setprop('nextStateActionFeaturesInternal');
            
            trial.setprop('nextStateActionInputVariables','nextStates');            
        end
        
        function setupActionFeatures(obj, trial)
            trial.squaredStateActionFeatures = trial.squaredStateActionFeatures(trial);
            trial.stateActionFeatures = FeatureGenerators.BasisFunctionsFeatures(trial.dataManager, trial.squaredStateActionFeatures,'basis',':','~stateActionFeatures');
            trial.nextStateActionFeaturesInternal = FeatureGenerators.BasisFunctionsFeatures(trial.dataManager, trial.squaredStateActionFeatures,'basisNext');
        end
        
        function [] = setupScenarioForLearners(obj, trial)
            
            trial.scenario.addLearner(trial.nextStateActionFeaturesInternal);
            trial.scenario.addLearner(trial.stateActionFeatures);
            
            obj.setupScenarioForLearners@Experiments.Features.ActionFeatureConfigurator(trial);
            
        end
        
    end
end
