classdef ActionFeatureConfigurator < Experiments.Configurator
    
    properties
        
    end
    
    methods
        function obj = ActionFeatureConfigurator(featureName)
            obj = obj@Experiments.Configurator(featureName);
        end
                
        
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.Configurator(trial);
            
            trial.setprop('actionFeatures');     
            trial.setprop('stateActionFeatures');
        end
        
        function postConfigureTrial(obj, trial)
            obj.setupActionFeatures(trial);                                  
            obj.postConfigureTrial@Experiments.Configurator(trial);                                 
        end
           
        function setupActionFeatures(obj, trial)            
            if (~isempty(trial.actionFeatures))
                trial.actionFeatures = trial.actionFeatures(trial);                                   
            end
            
            if (~isempty(trial.stateActionFeatures))
                trial.stateActionFeatures = trial.stateActionFeatures(trial);                                   
            end                                
        end
        
    end    
end
