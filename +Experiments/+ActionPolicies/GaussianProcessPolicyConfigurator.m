classdef GaussianProcessPolicyConfigurator < Experiments.ActionPolicies.ActionPolicyConfigurator
    
    properties
        
    end
    
    methods
        function obj = GaussianProcessPolicyConfigurator()
            obj = obj@Experiments.ActionPolicies.ActionPolicyConfigurator('GPPolicy');
        end
        
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.ActionPolicies.ActionPolicyConfigurator(trial);
            trial.setprop('maxNumberKernelSamples', 1000);
            
            trial.setprop('actionPolicy',@(trial, inputfeatures) Distributions.NonParametric.GaussianProcessPolicy(trial.dataManager, trial.policyFeatures,inputfeatures));
            trial.setprop('policyLearner',@(dm, pol) Learner.SupervisedLearner.GaussianProcessPolicyLearner(dm,pol,'sampleWeights', 'states', 'actions'));
            
            trial.setprop('policyKernel', ...
                @(trial) FeatureGenerators.Kernel.ExponentialQuadraticKernel( ...
                trial.dataManager, {{'states'}}, ':', trial.maxNumberKernelSamples,  'PolicyKern'));
            trial.setprop('policyFeatures', ...
                @(trial) FeatureGenerators.KernelBasedFeature(trial.dataManager,trial.policyKernel,trial.maxNumberKernelSamples ));
            trial.setprop('policyInputVariables', 'states');
        end
        
        function setupPolicyFeatures(~,trial)
            trial.policyKernel = trial.policyKernel(trial);
            trial.policyFeatures = trial.policyFeatures(trial);
        end
        
        function setupActionPolicy(obj, trial)
            
            obj.setupPolicyFeatures(trial);
            
            obj.setupActionPolicy@Experiments.ActionPolicies.ActionPolicyConfigurator(trial);
        end
        
        function [policy] = createPolicy(~, trial,  inputFeatures)
            policy = trial.actionPolicy(trial, inputFeatures);
        end
        
        function [policyLearner] = createPolicyLearner(~, trial)
            policyLearner = trial.policyLearner(trial.dataManager, trial.actionPolicy);
        end
        
        function [] = setupScenarioForLearners(obj, trial)
            obj.setupScenarioForLearners@Experiments.ActionPolicies.ActionPolicyConfigurator(trial);
            trial.scenario.addLearner(trial.policyFeatures);
            trial.scenario.addInitObject(trial.policyFeatures);
        end
    end
end
