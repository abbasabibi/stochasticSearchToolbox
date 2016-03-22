classdef FeatureRBFGridActions < Experiments.Features.ActionFeatureConfigurator
    
    properties
        
    end
    
    methods
        function obj = FeatureRBFGridActions()
            obj = obj@Experiments.Features.ActionFeatureConfigurator('RBFGridActions');
            obj.name = [obj.name, 'Actions'];
        end
        
        
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.Features.ActionFeatureConfigurator(trial);
         
            assert(isprop(trial, 'stateFeatures'), 'State Features must be configured before!');
            
            
            actionKernel = ...
                @(trial) FeatureGenerators.Kernel.ExponentialQuadraticKernel( ...
                trial.dataManager, {'actions'}, ':', trial.maxNumberKernelSamples);  
            
            %trial.setprop('actionFeatures', ...
            %    @(trial) FeatureGenerators.RadialBasisFeatures(trial.dataManager, {{'actions'}}, actionKernel(trial) ));

            prodkern= @(trial) FeatureGenerators.Kernel.ProductKernel( ...
                trial.dataManager, trial.maxNumberKernelSamples, ...
                {trial.stateFeatures.kernel, actionKernel(trial) }); 
            
            trial.setprop('stateActionFeatures', ...
                @(trial) FeatureGenerators.RadialBasisFeatures(trial.dataManager, {{'states','actions'}}, prodkern(trial) ));

                        
            
        end
        

        
        
    end
end
