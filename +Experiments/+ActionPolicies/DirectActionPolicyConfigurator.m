classdef DirectActionPolicyConfigurator < Experiments.Configurator
    
    properties
        
    end
    
    methods
        function obj = DirectActionPolicyConfigurator(policyName)
            obj = obj@Experiments.Configurator(policyName);
        end
                
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.Configurator(trial);
            
            trial.setprop('policyInputVariables','useStateFeatures');         
            trial.setprop('resetInitialData',1);            
            trial.setprop('policyLearner', @Learner.DirectDistribution.CreateFromTrial);
        end
       
        
        function [] = setupScenarioForLearners(obj, trial)
            if (~isempty(trial.policyLearner))
                trial.scenario.addLearner(trial.policyLearner);
                trial.scenario.addInitObject(trial.policyLearner);                        
            end   
            obj.setupScenarioForLearners@Experiments.Configurator(trial); 
        end
    end
end
