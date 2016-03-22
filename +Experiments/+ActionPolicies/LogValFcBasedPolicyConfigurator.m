classdef LogValFcBasedPolicyConfigurator < Experiments.ActionPolicies.ActionPolicyConfigurator
    %LOGVALFCBASEDPOLICY Policies based on log value fc (psifunction)
    properties
        
    end
    
    methods
        function obj = LogValFcBasedPolicyConfigurator()
            obj = obj@Experiments.ActionPolicies.ActionPolicyConfigurator('LogValFcPolicy');
        end
        
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.ActionPolicies.ActionPolicyConfigurator(trial);

            trial.setprop('psifunction', @(trial) Functions.LogLinearFunction(trial.dataManager,'states', 'desirability'));
            trial.setprop('actionPolicy', @(trial) Functions.PathIntegralPolicy(trial.dataManager, trial.psifunction, trial.transitionFunction ));
             
            trial.setprop('policyInputVariables', 'states');
        end

        
        function setupActionPolicy(obj, trial)
            
            trial.psifunction = trial.psifunction(trial);
            
            obj.setupActionPolicy@Experiments.ActionPolicies.ActionPolicyConfigurator(trial);
        end
        
        function [policy] = createPolicy(obj, trial,  inputFeatures)
            
            policy = trial.actionPolicy(trial);
            %policy = trial.actionPolicy(trial, inputFeatures);
        end
        
        function [policyLearner] = createPolicyLearner(obj, trial)
            policyLearner = trial.policyLearner(trial.dataManager, trial.actionPolicy, trial.stateFeatures);
        end
        function [] = setupScenarioForLearners(obj, trial)
            obj.setupScenarioForLearners@Experiments.ActionPolicies.ActionPolicyConfigurator(trial);
        end
    end
    
end

