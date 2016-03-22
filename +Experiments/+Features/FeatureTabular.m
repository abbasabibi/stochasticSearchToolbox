classdef FeatureTabular < Experiments.Features.FeatureConfigurator
    
    properties
        
    end
    
    methods
        function obj = FeatureTabular()
            obj = obj@Experiments.Features.FeatureConfigurator('Tabular');
        end
        
       
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.Features.FeatureConfigurator(trial);
            
            trial.setprop('stateFeatures', ...
                 @(trial) FeatureGenerators.TabularFeatures( ...
                    trial.dataManager, 'states'));
            
            trial.setprop('nextStateFeatures', ...
                 @(trial) FeatureGenerators.TabularFeatures( ...
                    trial.dataManager, 'nextStates'));
        end
        
    end    
end
