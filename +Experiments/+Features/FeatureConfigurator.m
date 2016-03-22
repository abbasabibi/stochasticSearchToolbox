classdef FeatureConfigurator < Experiments.Configurator
    
    properties
        featureInputName        = 'states'
        nextFeatureInputName    = 'nextStates'
        
        featureOutputName       = 'stateFeatures'
        nextFeatureOutputName   = 'nextStateFeatures'
        useOffset               = false;
     
    end
    
    methods
        function obj = FeatureConfigurator(featureName, featureInputName, featureIdentifier, useOffset)
            obj = obj@Experiments.Configurator(featureName);
            
            if(exist('featureInputName', 'var'))
                obj.featureInputName = featureInputName;
                obj.featureOutputName = [obj.featureInputName(1:end-1), 'Features'];
                
                obj.nextFeatureInputName = ['next', upper(obj.featureInputName(1)), obj.featureInputName(2:end)];
                obj.nextFeatureOutputName = [obj.nextFeatureInputName(1:end-1), 'Features'];
                                                
            end
            
            if(exist('featureIdentifier', 'var'))
                obj.featureOutputName = [obj.featureOutputName, featureIdentifier];
                obj.nextFeatureOutputName = [obj.nextFeatureOutputName, featureIdentifier];
            end
            
            if(exist('useOffset', 'var'))
                obj.useOffset = useOffset;
            end
            
           
            
        end
                
        
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.Configurator(trial);
            
            trial.setprop(obj.featureOutputName);     
            trial.setprop(obj.nextFeatureOutputName);
        end
        
        function postConfigureTrial(obj, trial)
            obj.setupFeatures(trial);                                  
            obj.postConfigureTrial@Experiments.Configurator(trial);                                 
        end
           
        function setupFeatures(obj, trial)
            
            if (~isempty(trial.(obj.nextFeatureOutputName)))
                trial.(obj.nextFeatureOutputName) = trial.(obj.nextFeatureOutputName)(trial);                                   
            end
            
            if (~isempty(trial.(obj.featureOutputName)))
                trial.(obj.featureOutputName) = trial.(obj.featureOutputName)(trial);                                   
            end
                                
        end
        
    end    
end
