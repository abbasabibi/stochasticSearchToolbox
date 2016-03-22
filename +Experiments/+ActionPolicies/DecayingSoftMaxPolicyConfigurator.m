classdef DecayingSoftMaxPolicyConfigurator < Experiments.ActionPolicies.ActionPolicyConfigurator
    
    properties
        
    end
    
    methods
        function obj = DecayingSoftMaxPolicyConfigurator()
            obj = obj@Experiments.ActionPolicies.ActionPolicyConfigurator('SoftMaxPolicy');
        end
        
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.ActionPolicies.ActionPolicyConfigurator(trial);
            
            trial.setprop('actionPolicy', @Distributions.Discrete.DecayingSoftMaxByQDistribution.createPolicy);
              
            trial.setprop('policyInputVariables', 'useStateFeatures');
        end
        
        function [policyLearner] = createPolicyLearner(obj, trial)
            policyLearner = trial.policyLearner(trial);
        end
    end
end
