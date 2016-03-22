classdef DirectEGreedyPolicyConfigurator < Experiments.ActionPolicies.ActionPolicyConfigurator
    
    properties
        
    end
    
    methods
        function obj = DirectEGreedyPolicyConfigurator()
            obj = obj@Experiments.ActionPolicies.ActionPolicyConfigurator('EGreedyPolicy');
        end
        
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.ActionPolicies.ActionPolicyConfigurator(trial);
            
            trial.setprop('actionPolicy', @Distributions.Discrete.EgreedyByQDistribution.createPolicy);
            
            trial.setprop('policyInputVariables', 'useStateFeatures');
        end
        
        function [policyLearner] = createPolicyLearner(obj, trial)
            policyLearner = trial.policyLearner(trial);
        end
    end
end
