classdef FeaturePicture < Experiments.Features.FeatureConfigurator
    %FEATURELINEARTRANSFORM Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function obj = FeaturePicture()
            obj = obj@Experiments.Features.FeatureConfigurator('FeaturePicture');
        end
        
       
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.Features.FeatureConfigurator(trial);
            
            trial.setprop('pictureFeatureVariable');
            trial.setprop('pictureFeatureIndices',':');
            trial.setprop('pictureFeatureSize');
            
        end
        
        function postConfigureTrial(obj, trial)
            trial.setprop('pictureFeatureGenerator', ...
                FeatureGenerators.PendulumPictureSingleFrame(trial.dataManager, trial.pictureFeatureVariable, ...
                    trial.pictureFeatureIndices, trial.pictureFeatureSize));
        end
    end
    
end

