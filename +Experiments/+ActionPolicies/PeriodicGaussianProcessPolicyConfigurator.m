classdef PeriodicGaussianProcessPolicyConfigurator < Experiments.ActionPolicies.GaussianProcessPolicyConfigurator
    
    properties
        
    end
    
    methods
        function obj = PeriodicGaussianProcessPolicyConfigurator()
            obj = obj@Experiments.ActionPolicies.GaussianProcessPolicyConfigurator();
        end
        
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.ActionPolicies.GaussianProcessPolicyConfigurator(trial);
                 
            trial.setprop('policyKernel1', ...
                @(trial) FeatureGenerators.Kernel.PeriodicKernel( ...
                trial.dataManager, {'states'}, trial.dataManager.getPeriodicity('states'), trial.maxNumberKernelSamples,'PolicyPeriodicKernel',2*pi));
            trial.setprop('policyKernel2', ...
                @(trial) FeatureGenerators.Kernel.ExponentialQuadraticKernel( ...
                trial.dataManager, {'states'}, ~trial.dataManager.getPeriodicity('states'), trial.maxNumberKernelSamples,{'states'},'PolicySquaredExpKernel'));
            trial.setprop('policyKernel', ...
                @(trial) FeatureGenerators.Kernel.ProductKernel( ...
                trial.dataManager, trial.maxNumberKernelSamples, {trial.policyKernel1, trial.policyKernel2 },'PolicyProdKernel'));
        end
        
        function setupPolicyFeatures(obj,trial)
            trial.policyKernel1 = trial.policyKernel1(trial);
            trial.policyKernel2 = trial.policyKernel2(trial);
            obj.setupPolicyFeatures@Experiments.ActionPolicies.GaussianProcessPolicyConfigurator(trial);
        end
        function [] = setupScenarioForLearners(obj, trial)
            obj.setupScenarioForLearners@Experiments.ActionPolicies.GaussianProcessPolicyConfigurator(trial);
            %trial.scenario.addLearner(trial.policyFeatures);
            %trial.scenario.addInitObject(trial.policyFeatures);
        end
    end
end
