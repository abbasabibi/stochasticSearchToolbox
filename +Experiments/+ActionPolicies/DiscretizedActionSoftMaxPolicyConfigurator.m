classdef DiscretizedActionSoftMaxPolicyConfigurator < Experiments.ActionPolicies.ActionPolicyConfigurator
    
    properties
        discreteActionMap = [];
    end
    
    methods
        function obj = DiscretizedActionSoftMaxPolicyConfigurator (discreteActionMap)
            obj = obj@Experiments.ActionPolicies.ActionPolicyConfigurator('DiscretizedSoftMaxPolicy');
            if (exist('discreteActionMap', 'var'))
                obj.discreteActionMap = discreteActionMap;
            end
        end
        
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.ActionPolicies.ActionPolicyConfigurator(trial);
            
            trial.setprop('actionName', 'discreteActions');
            if ~isempty(obj.discreteActionMap)
                trial.setprop('discreteActionMap', obj.discreteActionMap);            
            end
            trial.setprop('actionPolicy', @Distributions.Discrete.SoftMaxDistribution.createDiscretizedActionPolicy);            
            trial.setprop('policyLearner', @Learner.ClassificationLearner.MultiClassLogisticRegressionLearner);
                                    
            trial.setprop('policyInputVariables', 'useStateFeatures');
        end
        
        function [policy] = createPolicy(obj, trial,  inputFeatures)
            trial.setprop('discreteActionInterpreter',  Distributions.Discrete.DiscreteActionInterpreter(trial.dataManager, trial.discreteActionMap));
            policy = trial.actionPolicy(trial.dataManager, inputFeatures, trial.discreteActionInterpreter);
        end
                
    end
end
