classdef FeatureRBFKernelActionsProdNew < Experiments.Features.ActionFeatureConfigurator
    
    properties
        setupStateKernel = false;
    end
    
    methods
        function obj = FeatureRBFKernelActionsProdNew()
            obj = obj@Experiments.Features.ActionFeatureConfigurator('RBFProd');
            obj.name = [obj.name, 'Actions'];
        end
        
        
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.Features.ActionFeatureConfigurator(trial);
            
            assert(isprop(trial, 'stateFeatures'), 'State Features must be configured before!');
            
            trial.setprop('actionKernel', @(trial_) Kernels.ExponentialQuadraticKernel(trial_.dataManager, trial_.dataManager.getNumDimensions('actions'), 'Actions'));
            
            trial.setprop('stateActionKernel');
            trial.setprop('stateActionKernelReferenceSetLearner', @Kernels.Learner.RandomKernelReferenceSetLearner.CreateFromTrial);
            
            if(~isprop(trial,'stateKernel'))
                trial.setprop('stateKernel', @(trial_) Kernels.Kernel.createKernelSQEPeriodic(trial_.dataManager, 'states','~stateKernel'));
                trial.setprop('stateKernelReferenceSetLearner', @Kernels.Learner.KernelReferenceSetLearner.CreateFromTrial);
                trial.setprop('stateKernelLearner');
                
                trial.setprop('stateFeaturesForActions', @(trial_) Kernels.KernelBasedFeatureGenerator(trial_.dataManager, trial_.stateKernel, 'states','~stateFeaturesForActions'));
                trial.setprop('nextStateFeaturesForActions', @(trial_) Kernels.KernelBasedFeatureGenerator(trial_.dataManager, trial_.stateKernel, 'nextStates','~nextStateFeaturesForActions'));
                
                obj.setupStateKernel = true;
                
                trial.setprop('nextStateActionInputVariables','nextStateFeatures'); 
            end
        end
        
        function setupActionFeatures(obj, trial)
            trial.actionKernel = trial.actionKernel(trial);
            if obj.setupStateKernel
                trial.stateKernel = trial.stateKernel(trial);
                
                trial.stateFeaturesForActions = trial.stateFeaturesForActions(trial);
                trial.nextStateFeaturesForActions = trial.nextStateFeaturesForActions(trial);
                
                trial.stateKernelReferenceSetLearner = trial.stateKernelReferenceSetLearner(trial, 'stateFeaturesForActions', 'states');
                trial.nextStateFeaturesForActions.setExternalReferenceSet(trial.stateFeaturesForActions);
            end
            numStates = trial.dataManager.getNumDimensions('states');
            numActions = trial.dataManager.getNumDimensions('actions');
            
            trial.stateActionKernel =  Kernels.ProductKernel(trial.dataManager, numStates + numActions, {trial.stateKernel, trial.actionKernel}, ...
                {1:numStates, (numStates + 1):(numStates + numActions)}, 'StateActions');
            
            trial.stateActionFeatures = Kernels.KernelBasedFeatureGenerator(trial.dataManager, trial.stateActionKernel, {'states', 'actions'}, '~stateActionFeatures');
            
            trial.stateActionKernelReferenceSetLearner = trial.stateActionKernelReferenceSetLearner(trial, 'stateActionFeatures', {'states', 'actions'});
            
        end
        
        
        function [] = setupScenarioForLearners(obj, trial)
            
            if obj.setupStateKernel
                if (isempty(trial.stateKernelLearner))
                    trial.scenario.addLearner(trial.stateKernelReferenceSetLearner);
                else
                    trial.scenario.addLearner(trial.stateKernelLearner);
                end
            end
            
            if (~isprop(trial, 'stateActionKernelLearner') || isempty(trial.stateActionKernelLearner))
                trial.scenario.addLearner(trial.stateActionKernelReferenceSetLearner);
            else
                trial.scenario.addLearner(trial.stateActionKernelLearner);
            end
            
            obj.setupScenarioForLearners@Experiments.Features.ActionFeatureConfigurator(trial);
            
            if obj.setupStateKernel
                trial.scenario.addInitObject(trial.stateKernelReferenceSetLearner);
            end
            
            %trial.scenario.addInitObject(trial.actionFeatures);
            trial.scenario.addInitObject(trial.stateActionFeatures);
            trial.scenario.addInitObject(trial.stateActionKernelReferenceSetLearner);
        end
        
    end
end
