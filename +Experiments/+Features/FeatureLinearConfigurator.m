classdef FeatureLinearConfigurator < Experiments.Features.FeatureConfigurator
    
    properties
        
    end
    
    methods
        function obj = FeatureLinearConfigurator (varargin) %varargin is featureInputName and featureIdentifier
            obj = obj@Experiments.Features.FeatureConfigurator('LinearFeatures', varargin{:});
        end
                
        
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.Configurator(trial);
            
            trial.setprop(obj.featureOutputName, @(trial_) FeatureGenerators.LinearFeatures(trial_.dataManager, ...
                obj.featureInputName, ':', 0, ['~', obj.featureOutputName]));     
            
            trial.setprop(obj.nextFeatureOutputName, @(trial_) FeatureGenerators.LinearFeatures(trial_.dataManager, ...
                obj.nextFeatureInputName, ':', 0, ['~', obj.nextFeatureOutputName]));
        end
                
    end    
end
