classdef FeatureContextConfigurator < Experiments.Configurator
    
    properties
        
    end
    
    methods
        function obj = FeatureContextConfigurator(featureName)
            obj = obj@Experiments.Configurator(featureName);
        end
        
        function addDefaultCriteria(obj, trial, evaluationCriterion)            
            obj.addDefaultCriteria@Experiments.Configurator(trial, evaluationCriterion);
        end
        
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.Configurator(trial);
            
            trial.setprop('contextFeatures');     

        end
        
        function postConfigureTrial(obj, trial)
            obj.setupFeaturesContext(trial);                                  
            obj.postConfigureTrial@Experiments.Configurator(trial);                                 
        end
           
        function setupFeaturesContext(obj, trial)                        
            if (~isempty(trial.contextFeatures))
                trial.contextFeatures = trial.contextFeatures(trial);                                   
            end
                                
        end
        
    end    
end
