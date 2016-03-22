classdef ModelFeatures  < Experiments.Configurator
    
    properties
        
    end
    
    methods
        function obj = ModelFeatures()
            obj = obj@Experiments.Configurator('ModelFeatures');
        end
        
        
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.Configurator(trial);
                   
            trial.setprop('modelKernel_s', @(trial_) Kernels.Kernel.createKernelSQEPeriodic(trial_.dataManager, 'states', 'ModelStates'));
            
            trial.setprop('modelKernel_a', @(trial_) Kernels.ExponentialQuadraticKernel(trial_.dataManager, trial_.dataManager.getNumDimensions('actions'), 'ModelActions'));
            
            
            trial.setprop('modelKernel');
        end
        
        function postConfigureTrial(obj, trial)
            %isanyperiodic = any(trial.dataManager.getPeriodicity('states'));
            %isanynonperiodic = any(~trial.dataManager.getPeriodicity('states'));
            
            %pos_kernels = {trial.kernel_s1; trial.kernel_s2; trial.kernel_s12};
            %select = [isanyperiodic & ~isanynonperiodic, ...
            %    ~isanyperiodic & isanynonperiodic, ...
            %    isanyperiodic & isanynonperiodic];
            %trial.setprop('kernel_s',  pos_kernels{select});
            %trial.kernel_s1 = trial.kernel_s1(trial);
            %trial.kernel_s2 = trial.kernel_s2(trial);
            trial.modelKernel_s = trial.modelKernel_s(trial);
            trial.modelKernel_a = trial.modelKernel_a(trial);
            
            numStates = trial.dataManager.getNumDimensions('states');
            numActions = trial.dataManager.getNumDimensions('actions');
            
            trial.modelKernel =  Kernels.ProductKernel(trial.dataManager, numStates + numActions, {trial.modelKernel_s, trial.modelKernel_a}, ...
                {1:numStates, (numStates + 1):(numStates + numActions)}, 'ModelKernel');
            
            obj.postConfigureTrial@Experiments.Configurator(trial);                                 
        end
        
        function [] = setupScenarioForLearners(obj, trial)
            % add any learners???
            %trial.scenario.addLearner();

            
            obj.setupScenarioForLearners@Experiments.Configurator(trial);
            
            % init learners and features ???
            %trial.scenario.addInitObject();

        end
        
        
    end
end
