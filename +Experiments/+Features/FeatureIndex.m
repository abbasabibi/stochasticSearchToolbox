classdef FeatureIndex < Experiments.Features.FeatureConfigurator
    
    properties
        
    end
    
    methods
        function obj = FeatureIndex()
            obj = obj@Experiments.Features.FeatureConfigurator('Index');
        end
        
       
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.Features.FeatureConfigurator(trial);
            
            trial.setprop('stateFeatures', ...
                 @(trial) FeatureGenerators.IndexFeatures( ...
                    trial.dataManager, 'states'));
            
            trial.setprop('nextStateFeatures', ...
                 @(trial) FeatureGenerators.IndexFeatures( ...
                    trial.dataManager, 'nextStates'));
        end
        
    end    
end
