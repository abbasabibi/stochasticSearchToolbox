classdef PicturesGaussianProcessPolicyConfigurator < Experiments.ActionPolicies.ActionPolicyConfigurator
    
    properties
        
    end
    
    methods
        function obj = PicturesGaussianProcessPolicyConfigurator()
            obj = obj@Experiments.ActionPolicies.ActionPolicyConfigurator('GPPolicy');
        end
        
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.ActionPolicies.ActionPolicyConfigurator(trial);
            trial.setprop('maxNumberKernelSamples', 3000);
            
            trial.setprop('actionPolicy',@(trial, inputfeatures) Distributions.NonParametric.GaussianProcessPolicy(trial.dataManagter, trial.policyFeatures,inputfeatures));
            trial.setprop('policyLearner',@(dm, pol) Learner.SupervisedLearner.GaussianProcessPolicyLearner(dm,pol,'sampleWeights', 'states', 'actions'));
            
            trial.setprop('policyFeatures1',...
                @(trial) Kernels.ExponentialQuadraticKernel( ...
                     trial.dataManager, 400,...
                     'ExpQuadKernel1policy', false, false));
            trial.setprop('policyFeatures2',...
                 @(trial) Kernel.ExponentialQuadraticKernel( ...
                     trial.dataManager, 400, ...
                     'ExpQuadKernel2policy', false, false));
            trial.setprop('policyFeatures',...
                @(trial) Kernels.ProductKernel( ...
                    trial.dataManager, 800,...
                    {trial.policyFeatures1(trial), trial.policyFeatures2(trial) },...
                    {1:400,1:800}, 'PolicyKern'));
                    
            trial.setprop('policyInputVariables', 'usePolicyFeatures');
        end
        
        function setupPolicyFeatures(obj,trial)
            trial.policyFeatures = trial.policyFeatures(trial);
        end
        
        function setupActionPolicy(obj, trial)
            
            obj.setupPolicyFeatures(trial)
            
            obj.setupActionPolicy@Experiments.ActionPolicies.ActionPolicyConfigurator(trial);
        end
        
        function [policy] = createPolicy(obj, trial,  inputFeatures)
            policy = trial.actionPolicy(trial, inputFeatures);
        end
        
        function [policyLearner] = createPolicyLearner(obj, trial)
            policyLearner = trial.policyLearner(trial.dataManager, trial.actionPolicy, trial.stateFeatures);
        end
        function [] = setupScenarioForLearners(obj, trial)
            obj.setupScenarioForLearners@Experiments.ActionPolicies.ActionPolicyConfigurator(trial);
            trial.scenario.addLearner(trial.policyFeatures);
            trial.scenario.addInitObject(trial.policyFeatures);
        end
    end
end
