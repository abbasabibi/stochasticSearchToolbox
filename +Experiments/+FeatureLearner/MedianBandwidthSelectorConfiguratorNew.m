classdef MedianBandwidthSelectorConfiguratorNew < Experiments.FeatureLearner.FeatureLearner
    
    properties
        
    end
    
    methods
        function obj = MedianBandwidthSelectorConfiguratorNew(featureName)
            obj = obj@Experiments.FeatureLearner.FeatureLearner(featureName);
        end
                
        
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.FeatureLearner.FeatureLearner(trial);
            
            trial.setprop(obj.featureLearnerName, @Kernels.Learner.MedianBandwidthSelector.CreateFromTrial);     
        end                
    end    
end
