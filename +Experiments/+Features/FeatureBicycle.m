classdef FeatureBicycle < Experiments.Features.FeatureConfigurator
    
    properties
        
    end
    
    methods
        function obj = FeatureBicycle()
            obj = obj@Experiments.Features.FeatureConfigurator('BicycleFeatures');
        end
        
       
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.Features.FeatureConfigurator(trial);
            
            trial.setprop('stateFeatures', ...
                 @(trial) Environments.BicycleBalance.BicycleBalanceFeatures( ...
                    trial.dataManager, 'states'));
            
            trial.setprop('nextStateFeatures', ...
                 @(trial) Environments.BicycleBalance.BicycleBalanceFeatures( ...
                    trial.dataManager, 'nextStates'));

            %trial.setprop('stateFeatures', ...
            %     @(trial) Environments.BicycleBalance.BicycleBalanceDiscrete( ...
            %        trial.dataManager, 'states'));
            
            %trial.setprop('nextStateFeatures', ...
            %     @(trial) Environments.BicycleBalance.BicycleBalanceDiscrete( ...
            %        trial.dataManager, 'nextStates'));
        end
        
    end    
end
