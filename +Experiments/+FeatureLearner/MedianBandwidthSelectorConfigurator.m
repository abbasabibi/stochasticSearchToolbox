classdef MedianBandwidthSelectorConfigurator < Experiments.FeatureLearner.FeatureLearner
    
    properties
        
    end
    
    methods
        function obj = MedianBandwidthSelectorConfigurator(featureName)
            obj = obj@Experiments.FeatureLearner.FeatureLearner(featureName);
        end
                
        
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.FeatureLearner.FeatureLearner(trial);
            
            trial.setprop(obj.featureLearnerName, @FeatureGenerators.FeatureLearner.MedianBandwidthSelector.CreateFromTrial);     
        end                
    end    
end
