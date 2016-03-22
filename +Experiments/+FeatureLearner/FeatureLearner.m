classdef FeatureLearner < Experiments.Configurator
    
    properties
       featureName
       featureLearnerName
    end
    
    methods
        function obj = FeatureLearner(featureName)
            obj = obj@Experiments.Configurator(featureName);
            
            obj.featureName = featureName;
            obj.featureLearnerName = [obj.featureName, 'Learner'];
        end
                
        
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.Configurator(trial);
            
            trial.setprop(obj.featureLearnerName);     
            trial.setprop([obj.featureLearnerName, 'DataName'], 'data');     
            
        end
        
        function postConfigureTrial(obj, trial)
            obj.setupFeatureLearner(trial);                                  
            obj.postConfigureTrial@Experiments.Configurator(trial);                                 
        end
           
        function setupFeatureLearner(obj, trial)
            
            if (~isempty(trial.(obj.featureLearnerName)))
                trial.(obj.featureLearnerName) = trial.(obj.featureLearnerName)(trial, obj.featureName);  
                trial.(obj.featureLearnerName).setDataNameLearner(trial.([obj.featureLearnerName, 'DataName']));
            end                        
                                
        end
        
        function [] = setupScenarioForLearners(obj, trial)
            % should be added by the feature configurator (required order)
            %trial.scenario.addLearner(trial.(obj.featureLearnerName));  
            trial.scenario.addDataPreprocessor(trial.(obj.featureLearnerName));
            
            obj.setupScenarioForLearners@Experiments.Configurator(trial);
        end
        
    end    
end
