classdef FeatureRBFKernelStatesPeriodicNew < Experiments.Features.FeatureConfigurator
    
    properties
        kernelName = 'stateKernel';
    end
    
    methods
        function obj = FeatureRBFKernelStatesPeriodicNew(varargin)
            obj = obj@Experiments.Features.FeatureConfigurator('RBFStates',varargin{:});
            if(numel(varargin)>1)
                obj.kernelName = [varargin{2},'Kernel'];
            end
        end
        
        
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.Features.FeatureConfigurator(trial);
                        
            trial.setprop('maxNumberKernelSamples', 100);

            trial.setprop(obj.kernelName, @(trial_) Kernels.Kernel.createKernelSQEPeriodic(trial_.dataManager, obj.featureInputName,['~',obj.kernelName]));            
            trial.setprop([obj.kernelName,'ReferenceSetLearner'], @Kernels.Learner.KernelReferenceSetLearner.CreateFromTrial);
            trial.setprop([obj.kernelName,'Learner']);
            
            trial.setprop(obj.featureOutputName, @(trial_) Kernels.KernelBasedFeatureGenerator(trial_.dataManager, trial_.(obj.kernelName), obj.featureInputName,['~',obj.featureOutputName]));            
            trial.setprop(obj.nextFeatureOutputName, @(trial_) Kernels.KernelBasedFeatureGenerator(trial_.dataManager, trial_.(obj.kernelName), obj.nextFeatureInputName,['~',obj.nextFeatureOutputName]));
            
        end
        
        function setupFeatures(obj, trial)
            trial.(obj.kernelName) = trial.(obj.kernelName)(trial);    

            obj.setupFeatures@Experiments.Features.FeatureConfigurator(trial);
            trial.([obj.kernelName,'ReferenceSetLearner']) = trial.([obj.kernelName,'ReferenceSetLearner'])(trial, obj.featureOutputName, obj.featureInputName);                        
            trial.(obj.nextFeatureOutputName).setExternalReferenceSet(trial.(obj.featureOutputName));
            
        end
        
        function [] = setupScenarioForLearners(obj, trial)
            if (isempty(trial.([obj.kernelName,'Learner'])))
                trial.scenario.addLearner(trial.([obj.kernelName,'ReferenceSetLearner']));
            else
                trial.scenario.addLearner(trial.([obj.kernelName,'Learner']));
            end
            
            obj.setupScenarioForLearners@Experiments.Features.FeatureConfigurator(trial);
            
            trial.scenario.addInitObject(trial.([obj.kernelName,'ReferenceSetLearner']));
        end
        
        
    end
end
