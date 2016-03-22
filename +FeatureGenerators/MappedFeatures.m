classdef MappedFeatures < FeatureGenerators.FeatureGenerator
    
    methods
        function obj =  MappedFeatures(dataManager, featureVariables, stateIndices, featureName)
            if (~exist('stateIndices', 'var'))
                stateIndices = ':';
            end
            if (~exist('featureName', 'var'))
                featureName = 'Mapped';
            end
            cnt = dataManager.getNumDimensions(featureVariables);
            
            obj = obj@FeatureGenerators.FeatureGenerator(dataManager, featureVariables, featureName, stateIndices, cnt);
        end
        
        function [features] = getFeaturesInternal(obj, numElements, inputMatrix)
            features = inputMatrix;
        end
    end
    
end

