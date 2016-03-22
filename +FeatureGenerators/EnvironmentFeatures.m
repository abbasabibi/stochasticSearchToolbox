classdef EnvironmentFeatures < FeatureGenerators.FeatureGenerator
    
    properties
        environment
    end
    
    methods
        function obj =  EnvironmentFeatures(dataManager, featureVariables, stateIndices, environment)
            if (~exist('stateIndices', 'var'))
                stateIndices = ':';
            end

            obj = obj@FeatureGenerators.FeatureGenerator(dataManager, featureVariables, 'EnvSymbols', stateIndices, environment.getFeatureDim());

            obj.environment = environment;
        end
        
        function [features] = getFeaturesInternal(obj, numElements, inputMatrix)
            features = obj.environment.getFeatures(numElements, inputMatrix);
        end
        
    end
    
end

