classdef GaussianActionPeriodicStateKernel  < Experiments.Configurator
    
    properties
        
    end
    
    methods
        function obj = GaussianActionPeriodicStateKernel()
            obj = obj@Experiments.Configurator('GaussianProdKernel');
        end
        
        
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.Configurator(trial);
                   
            %statedim = @(trial) trial.dataManager.getNumDimensions('states');
            %actiondim = @(trial) trial.dataManager.getNumDimensions('actions');

            
            trial.setprop('kernel_s1', @(trial) FeatureGenerators.Kernel.PeriodicKernel( ...
                trial.dataManager, {{'states'}}, trial.dataManager.getPeriodicity('states'), ...
                trial.maxNumberKernelSamples,'PeriodicKernel',2*pi));
            trial.setprop('kernel_s2', @(trial) FeatureGenerators.Kernel.ExponentialQuadraticKernel( ...
                trial.dataManager, {{'states'}}, ~trial.dataManager.getPeriodicity('states'), ...
                trial.maxNumberKernelSamples));
            trial.setprop('kernel_s12', @(trial) FeatureGenerators.Kernel.ProductKernel( ...
                trial.dataManager, trial.maxNumberKernelSamples, {trial.kernel_s1, trial.kernel_s2 }));
            

            
            

            
            trial.setprop('kernel_a',@(trial) FeatureGenerators.Kernel.ExponentialQuadraticKernel( ...
                trial.dataManager, {'actions'}, ':', trial.maxNumberKernelSamples));  
            
            
            %trial.setprop('r_kernel', @(trial, kernel_s, kernel_a) ...
            %    FeatureGenerators.Kernel.SquaredKernel( ...
            %    trial.dataManager, FeatureGenerators.Kernel.SumKernel( ...
            %        trial.dataManager, {kernel_s, kernel_a})));
            
            trial.setprop('next_s_kernel', @(trial, kernel_s, kernel_a) ...
                FeatureGenerators.Kernel.ProductKernel( ...
                trial.dataManager, trial.maxNumberKernelSamples, {kernel_s, kernel_a}));
        end
        
        function postConfigureTrial(obj, trial)
            isanyperiodic = any(trial.dataManager.getPeriodicity('states'));
            isanynonperiodic = any(~trial.dataManager.getPeriodicity('states'));
            
            pos_kernels = {trial.kernel_s1; trial.kernel_s2; trial.kernel_s12};
            select = [isanyperiodic & ~isanynonperiodic, ...
                ~isanyperiodic & isanynonperiodic, ...
                isanyperiodic & isanynonperiodic];
            trial.setprop('kernel_s',  pos_kernels{select});
            trial.kernel_s1 = trial.kernel_s1(trial);
            trial.kernel_s2 = trial.kernel_s2(trial);
            trial.kernel_s = trial.kernel_s(trial);
            trial.kernel_a = trial.kernel_a(trial);
            
            %trial.r_kernel = trial.r_kernel(trial, trial.kernel_s, trial.kernel_a);
            
            trial.next_s_kernel = trial.next_s_kernel(trial, trial.kernel_s, trial.kernel_a);
            obj.postConfigureTrial@Experiments.Configurator(trial);                                 
        end
        
        function [] = setupScenarioForLearners(obj, trial)
            % add any learners???
            %trial.scenario.addLearner();

            
            obj.setupScenarioForLearners@Experiments.Features.FeatureConfigurator(trial);
            
            % init learners and features ???
            %trial.scenario.addInitObject();

        end
        
        
    end
end
