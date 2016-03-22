classdef FeatureLinearTransform < Experiments.Features.FeatureConfigurator
    %FEATURELINEARTRANSFORM Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function obj = FeatureLinearTransform()
            obj = obj@Experiments.Features.FeatureConfigurator('LinearTransform');
        end
        
       
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.Features.FeatureConfigurator(trial);
            
            trial.setprop('stateFeaturesVariables');
            trial.setprop('stateFeaturesName');
            trial.setprop('stateIndices',':');
            trial.setprop('stateNumFeatures');
            
            
        end
        
        function postConfigureTrial(obj, trial)
            trial.setprop('stateFeatures', ...
                @(trial) FeatureGenerators.LinearTransformFeatures( ...
                    trial.dataManager, trial.stateFeaturesVariables, ...
                    trial.stateFeaturesName, trial.stateIndices, trial.stateNumFeatures));
                
            obj.postConfigureTrial@Experiments.Features.FeatureConfigurator(trial);
        end
    end
    
end

