classdef SquaredActionPeriodicStateKernel  < Experiments.Configurator
    
    properties
        
    end
    
    methods
        function obj = SquaredActionPeriodicStateKernel()
            obj = obj@Experiments.Configurator('SquaredProdKernel');
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
            

            
            

            
            trial.setprop('kernel_a',@(trial) FeatureGenerators.Kernel.LinearKernel( ...
                trial.dataManager, {'actionsLinear'}, ':'));  
            
            %trial.setprop('kernel_a',@(trial) FeatureGenerators.Kernel.LinearKernel( ...
            %    trial.dataManager, {'actions'}, ':'));  
            
            
            
            trial.setprop('r_kernel', @(trial, kernel_s, kernel_a) ...
                FeatureGenerators.Kernel.SquaredKernel( ...
                trial.dataManager, FeatureGenerators.Kernel.SumKernel( ...
                    trial.dataManager, {kernel_s, kernel_a})));
            
            trial.setprop('next_s_kernel', @(trial, kernel_s, kernel_a) ...
                FeatureGenerators.Kernel.SquaredKernel( ...
                trial.dataManager, FeatureGenerators.Kernel.SumKernel( ...
                    trial.dataManager, {kernel_s, kernel_a})));
            
            trial.setprop('actionScaling', @(trial) 1./max(abs(trial.dataManager.getMaxRange('actions')), ...
                    abs(trial.dataManager.getMinRange('actions')))); 
            trial.setprop('actionfeatures', @(trial) ...
                FeatureGenerators.WeightedLinearFeatures(...
                trial.dataManager, 'actions', ':', ...
                trial.actionScaling));
        end
        
        function postConfigureTrial(obj, trial)
            trial.actionScaling = trial.actionScaling(trial);
            trial.actionfeatures = trial.actionfeatures(trial);
            
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
            
            trial.r_kernel = trial.r_kernel(trial, trial.kernel_s.copy, trial.kernel_a.copy);
            
            trial.next_s_kernel = trial.next_s_kernel(trial, trial.kernel_s.copy, trial.kernel_a.copy);            obj.postConfigureTrial@Experiments.Configurator(trial);                                 
            
            
        end
        
        
        function [] = setupScenarioForLearners(obj, trial)
            %add learners?
            %trial.scenario.addLearner();

            
            obj.setupScenarioForLearners@Experiments.Configurator(trial);
            %init features and learners
            trial.scenario.addInitObject(trial.actionfeatures);
        end
        
        
    end
end
