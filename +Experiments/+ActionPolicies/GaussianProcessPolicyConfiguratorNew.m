classdef GaussianProcessPolicyConfiguratorNew < Experiments.ActionPolicies.ActionPolicyConfigurator
    
    properties
        
    end
    
    methods
        function obj = GaussianProcessPolicyConfiguratorNew()
            obj = obj@Experiments.ActionPolicies.ActionPolicyConfigurator('GP');
        end
        
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.ActionPolicies.ActionPolicyConfigurator(trial);
            trial.setprop('maxNumberKernelSamples', 1000);
            
            trial.setprop('GPInitializer', @Kernels.GPs.GaussianProcess.CreateSquaredExponentialGP);            
            trial.setprop('GPLearnerInitializer', @Kernels.Learner.MedianBandwidthSelectorAndGPVariance.CreateWithStandardReferenceSet);            
            trial.setprop('policyInputVariables', {'states'});
        end
        
        function setupActionPolicy(obj, trial)
            
            trial.actionPolicy = Kernels.GPs.CompositeOutputModel(trial.dataManager, 'actions', trial.policyInputVariables, trial.GPInitializer);
            trial.actionPolicy.addDataFunctionAlias('sampleAction', 'sampleFromDistribution');
            
            trial.policyLearner = Kernels.GPs.CompositeOutputModelLearner(trial.dataManager, trial.actionPolicy, trial.GPLearnerInitializer);           
        end
                
        function [] = setupScenarioForLearners(obj, trial)
            obj.setupScenarioForLearners@Experiments.ActionPolicies.ActionPolicyConfigurator(trial);
            
            if ismethod(trial.actionPolicy,'initObject' )
                trial.scenario.addInitObject(trial.actionPolicy);
            end
        end
    end
end
