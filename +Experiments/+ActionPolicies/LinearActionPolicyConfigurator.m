classdef LinearActionPolicyConfigurator < Experiments.ActionPolicies.ActionPolicyConfigurator
    
    properties
        
    end
    
    methods
        function obj = LinearActionPolicyConfigurator()
            obj = obj@Experiments.ActionPolicies.ActionPolicyConfigurator('LinearPolicy');
        end
        
        function addDefaultCriteria(obj, trial, evaluationCriterion)            
            obj.addDefaultCriteria@ Experiments.Configurator(trial, evaluationCriterion);
        end
        
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.ActionPolicies.ActionPolicyConfigurator(trial);
            
            trial.setprop('actionPolicy', @Distributions.Gaussian.GaussianActionPolicy);
            trial.setprop('policyLearner', @Learner.SupervisedLearner.LinearGaussianMLLearner);
                        
            %trial.setprop('policyInputVariables', 'states');
            trial.setprop('policyInputVariables', 'useStateFeatures');
        end
               
        
    end    
end
