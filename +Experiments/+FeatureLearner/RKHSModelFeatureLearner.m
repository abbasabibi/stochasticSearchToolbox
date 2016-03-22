classdef RKHSModelFeatureLearner < Experiments.FeatureLearner.FeatureLearner
    
    properties
        
    end
    
    methods
        function obj = RKHSModelFeatureLearner(featureName)
            obj = obj@Experiments.FeatureLearner.FeatureLearner(featureName);
        end
                
        
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.FeatureLearner.FeatureLearner(trial);
            
            trial.setprop(obj.featureLearnerName, @(trial_, featureName_) Learner.ModelLearner.RKHSModelLearner(trial_.dataManager, ...
                ':', trial_.stateFeatures,...
                trial_.nextStateFeatures,trial_.stateActionFeatures));     
        end                
    end    
end
