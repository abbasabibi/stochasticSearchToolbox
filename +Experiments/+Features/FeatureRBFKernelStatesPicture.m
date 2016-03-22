classdef FeatureRBFKernelStatesPicture < Experiments.Features.FeatureConfigurator
    
    properties
        
    end
    
    methods
        function obj = FeatureRBFKernelStatesPicture()
            obj = obj@Experiments.Features.FeatureConfigurator('RBFStatesPicture');
        end
        
        
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.Features.FeatureConfigurator(trial);
                      
            trial.setprop('stateKernel1',...
                 @(trial) Kernels.ExponentialQuadraticKernel( ...
                trial.dataManager, 400, 'ExpQuadKernel1', false, false));
            trial.setprop('stateKernel2',...
                @(trial) Kernels.ExponentialQuadraticKernel( ...
                trial.dataManager, 400, 'ExpQuadKernel2', false, false));
            trial.setprop('stateKernel', ...
                @(trial) Kernels.ProductKernel( ...
                trial.dataManager, 800, ...
                {trial.stateKernel1, trial.stateKernel2 }, {1:400, 401:800}, 'ProductKernel'));  
            % vvv to do vvv %%%
            trial.setprop('nextStateKernel1',...    
                @(trial) FeatureGenerators.Kernel.ExponentialQuadraticKernel( ...
                trial.dataManager, {{'nextStatesPicture'}}, 1:400, trial.maxNumberKernelSamples,...
                'ExpQuadKernel', false, false));
            trial.setprop('nextStateKernel2',...
                @(trial) FeatureGenerators.Kernel.ExponentialQuadraticKernel( ...
                trial.dataManager, {{'nextStatesPicture'}}, 401:800, trial.maxNumberKernelSamples,...
                'ExpQuadKernel', false, false));
  
            trial.setprop('nextStateKernel', ...
                @(trial) FeatureGenerators.Kernel.ProductKernel( ...
                trial.dataManager, trial.maxNumberKernelSamples, ...
                {trial.nextStateKernel1, trial.nextStateKernel2 }));  
            
            trial.setprop('stateFeatures',...
                @(trial) FeatureGenerators.KernelBasedFeature(trial.dataManager, trial.stateKernel, trial.maxNumberKernelSamples,{{'statesPicture'}} ));
            
            trial.setprop('nextStateFeatures',...
                @(trial) FeatureGenerators.KernelBasedFeature(trial.dataManager, trial.nextStateKernel,trial.maxNumberKernelSamples,{{'statesPicture'}} ));
            trial.setprop('pictureStates',...
                @(dm) FeatureGenerators.PendulumPicture4(dm, 'states', ':')...
            );
            trial.setprop('pictureNextStates',...
                @(dm) FeatureGenerators.PendulumPicture4(dm, 'nextStates', ':')...
            );
        end
        
        function setupFeatures(obj, trial)
            trial.pictureStates = trial.pictureStates(trial.dataManager);
            trial.pictureNextStates = trial.pictureNextStates(trial.dataManager); 
            

            trial.stateKernel1 = trial.stateKernel1(trial);    
            trial.stateKernel2 = trial.stateKernel2(trial);    
            trial.stateKernel = trial.stateKernel(trial);  
            %trial.stateFeatures = trial.stateFeatures(trial);     
            
            trial.nextStateKernel1 = trial.nextStateKernel1(trial);    
            trial.nextStateKernel2 = trial.nextStateKernel2(trial); 
            trial.nextStateKernel = trial.nextStateKernel(trial); 
            %trial.nextStateFeatures = trial.nextStateFeatures(trial); 
            obj.setupFeatures@Experiments.Features.FeatureConfigurator(trial);

        end
        
        function [] = setupScenarioForLearners(obj, trial)
            trial.scenario.addLearner(trial.stateFeatures);
            trial.scenario.addLearner(trial.nextStateFeatures);
            
            obj.setupScenarioForLearners@Experiments.Features.FeatureConfigurator(trial);
            
            trial.scenario.addInitObject(trial.stateFeatures);
            trial.scenario.addInitObject(trial.nextStateFeatures);
            trial.scenario.addInitObject(trial.pictureStates);
            trial.scenario.addInitObject(trial.pictureNextStates);
        end
        
        
    end
end
