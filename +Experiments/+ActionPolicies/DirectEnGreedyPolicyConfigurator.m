classdef DirectEnGreedyPolicyConfigurator < Experiments.ActionPolicies.ActionPolicyConfigurator
    
    properties
        
    end
    
    methods
        function obj = DirectEnGreedyPolicyConfigurator()
            obj = obj@Experiments.ActionPolicies.ActionPolicyConfigurator('EnGreedyPolicy');
        end
        
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.ActionPolicies.ActionPolicyConfigurator(trial);
            
            trial.setprop('actionPolicy', @Distributions.Discrete.EnGreedyByQDistribution.createPolicy);
            
            trial.setprop('policyInputVariables', 'useStateFeatures');
        end
        
        function [policyLearner] = createPolicyLearner(obj, trial)
            policyLearner = trial.policyLearner(trial);
        end      
    end
end
