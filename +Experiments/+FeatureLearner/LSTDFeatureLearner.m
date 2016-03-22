classdef LSTDFeatureLearner < Experiments.FeatureLearner.FeatureLearner
    
    properties
        featureInputName;
    end
    
    methods
        function obj = LSTDFeatureLearner(featureName)
            obj = obj@Experiments.FeatureLearner.FeatureLearner(featureName);
            obj.featureInputName = featureName;
            
            if (strcmp(obj.featureInputName(end - 5 : end), 'Kernel') == 1)
                obj.featureInputName = obj.featureInputName(1:end - 6);
            end
        end
                
        
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.FeatureLearner.FeatureLearner(trial);
            
            trial.setprop(obj.featureLearnerName, @(trial_, featureName_) ...
                PolicyEvaluation.FeatureLearner.LSTDFeatureLearnerMSPBE.CreateFromTrial(trial_, obj.featureInputName));     
        end                
    end    
end
