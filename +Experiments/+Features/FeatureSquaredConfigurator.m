classdef FeatureSquaredConfigurator < Experiments.Features.FeatureConfigurator
    
    properties
        
    end
    
    methods
        function obj = FeatureSquaredConfigurator(varargin) %varargin is featureInputName and featureIdentifier
            obj = obj@Experiments.Features.FeatureConfigurator('SquaredFeatures', varargin{:});
        end
                
        
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.Configurator(trial);
            
            trial.setprop(obj.featureOutputName, @(trial_) FeatureGenerators.SquaredFeatures(trial_.dataManager, ...
                obj.featureInputName, ':', obj.useOffset, ['~', obj.featureOutputName]));     
            
            trial.setprop(obj.nextFeatureOutputName, @(trial_) FeatureGenerators.SquaredFeatures(trial_.dataManager, ...
                obj.nextFeatureInputName, ':', obj.useOffset, ['~', obj.nextFeatureOutputName]));
        end
                
    end    
end
