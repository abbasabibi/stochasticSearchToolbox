classdef FeatureMapped < Experiments.Features.FeatureConfigurator
    
    properties
        
    end
    
    methods
        function obj = FeatureMapped()
            obj = obj@Experiments.Features.FeatureConfigurator('Mapped');
        end
        
       
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.Features.FeatureConfigurator(trial);
            
            trial.setprop('stateFeatures', ...
                 @(trial) FeatureGenerators.MappedFeatures( ...
                    trial.dataManager, 'states'));
            
            trial.setprop('nextStateFeatures', ...
                 @(trial) FeatureGenerators.MappedFeatures( ...
                    trial.dataManager, 'nextStates'));
        end
        
    end    
end
