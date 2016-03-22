classdef DirectSoftMaxPolicyConfigurator < Experiments.ActionPolicies.DirectActionPolicyConfigurator
    
    properties
        
    end
    
    methods
        function obj = DirectSoftMaxPolicyConfigurator()
            obj = obj@Experiments.ActionPolicies.DirectActionPolicyConfigurator('SoftMaxPolicy');
        end
        
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.ActionPolicies.DirectActionPolicyConfigurator(trial);
                                                         
            trial.setprop('policyInputVariables', 'useStateFeatures');
            trial.setprop('policyLearner',[]);
        end
        
        function [] = postConfigureTrial(obj, trial)
            
            
            if (isprop(trial, 'discreteActionInterpreter') && ~isempty(trial.discreteActionInterpreter))
                trial.actionPolicy = Distributions.Discrete.SoftMaxByQDistribution.createDiscretizedActionPolicy(trial.dataManager, ...
                    trial.stateFeatures.outputName, trial.policyEvaluationFunction, trial.discreteActionInterpreter);
                
            else
                trial.actionPolicy = Distributions.Discrete.SoftMaxByQDistribution.createPolicy(trial.dataManager, ...
                    trial.stateFeatures.outputName, trial.policyEvaluationFunction);
            end
            trial.policyLearner = [];
        end
        
                
    end
end
