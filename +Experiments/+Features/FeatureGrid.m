classdef FeatureGrid < Experiments.Features.FeatureConfigurator
    
    properties
        dim
    end
    
    methods
        function obj = FeatureGrid(dim)
            obj = obj@Experiments.Features.FeatureConfigurator('Grid');
            obj.dim = dim;
        end
        
       
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.Features.FeatureConfigurator(trial);
            
            trial.setprop('stateFeatures', ...
                 @(trial) FeatureGenerators.GridFeatures( ...
                    trial.dataManager, 'states', obj.dim));
            
            trial.setprop('nextStateFeatures', ...
                 @(trial) FeatureGenerators.GridFeatures( ...
                    trial.dataManager, 'nextStates',obj.dim));
        end
        
    end    
end
