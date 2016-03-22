classdef ParameterPolicyConfigurator < Experiments.Configurator
    
    properties
        
    end
    
    methods
        function obj = ParameterPolicyConfigurator(policyName)
            obj = obj@Experiments.Configurator(policyName);
        end
        
        function addDefaultCriteria(obj, trial, evaluationCriterion)            
            obj.addDefaultCriteria@ Experiments.Configurator(trial, evaluationCriterion);
        end
        
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.Configurator(trial);
            
            trial.setprop('parameterPolicy');
            trial.setprop('parameterPolicyLearner');
                        
            trial.setprop('parameterPolicyInputVariables', 'contexts');
        end
        
        function postConfigureTrial(obj, trial)
            obj.setupParameterPolicy(trial);                                  
            obj.postConfigureTrial@Experiments.Configurator(trial);                                 
        end
        
       
        function [] = setupScenarioForLearners(~, trial)
            trial.scenario.addInitObject(trial.parameterPolicy);   
            if(~isempty(trial.parameterPolicyLearner))
                trial.scenario.addInitObject(trial.parameterPolicyLearner);     
            end
        end
    end
    methods (Abstract)
        [] = setupParameterPolicy(obj, trial)
    end
end
