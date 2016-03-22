classdef SoftMaxPolicyConfigurator < Experiments.ActionPolicies.ActionPolicyConfigurator
    
    properties
        
    end
    
    methods
        function obj = SoftMaxPolicyConfigurator()
            obj = obj@Experiments.ActionPolicies.ActionPolicyConfigurator('SoftMaxPolicy');
        end
        
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.ActionPolicies.ActionPolicyConfigurator(trial);
            
            
            trial.setprop('actionPolicy', @Distributions.Discrete.SoftMaxDistribution.createPolicy);
            trial.setprop('policyLearner', @Learner.ClassificationLearner.MultiClassLogisticRegressionLearner);
            
            trial.setprop('policyInputVariables', 'useStateFeatures');
        end
        
        function [policy] = createPolicy(obj, trial,  inputFeatures)
            
            policy = trial.actionPolicy(trial.dataManager, inputFeatures, trial.discActionName);
            
            if (isprop(trial, 'discreteActionInterpreter') && ~isempty(trial.discreteActionInterpreter))
                policy.setDiscreteActionInterpreter(trial.discreteActionInterpreter);
            end
        end
        
    end
end
