classdef FeatureSquaredContextConfigurator < Experiments.Features.FeatureContextConfigurator
    
    properties
        
    end
    
    methods
        function obj = FeatureSquaredContextConfigurator()
            obj = obj@Experiments.Features.FeatureContextConfigurator('SquaredContextFeatures');
        end
        
        
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.Features.FeatureContextConfigurator(trial);
            
            trial.setprop('contextFeatures', @FeatureGenerators.SquaredFeatures.CreateContextFeaturesFromTrial);     
        end
               
    end    
end
