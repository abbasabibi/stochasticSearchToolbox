classdef DiscreteInputPolicyConfigurator < Experiments.ActionPolicies.ActionPolicyConfigurator
    
    properties
        
    end
    
    methods
        function obj = DiscreteInputPolicyConfigurator()
            obj = obj@Experiments.ActionPolicies.ActionPolicyConfigurator('DiscreteInputPolicy');
        end
        
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.ActionPolicies.ActionPolicyConfigurator(trial);
            
            
            trial.setprop('actionPolicy', @Distributions.Discrete.DiscreteDistributionDiscreteInputOutput.createPolicy);
            trial.setprop('policyLearner', @Learner.ClassificationLearner.TabularInputOutputDistributionLearner);
            
            trial.setprop('policyInputVariables', 'useStateFeatures');
        end
        
        function [policy] = createPolicy(obj, trial,  inputFeatures)
            
            policy = trial.actionPolicy(trial.dataManager, inputFeatures, trial.actionName);
            
            if (isprop(trial, 'discreteActionInterpreter') && ~isempty(trial.discreteActionInterpreter))
                policy.setDiscreteActionInterpreter(trial.discreteActionInterpreter);
            end
        end
        
    end
end
