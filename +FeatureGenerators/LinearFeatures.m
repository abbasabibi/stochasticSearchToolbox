classdef LinearFeatures < FeatureGenerators.FeatureGenerator
    properties
        useOffset = false;
    end
    
    methods
        function [obj] = LinearFeatures(dataManager, featureVariables, stateIndices, useOffset, featureName)
            if (~exist('stateIndices', 'var') || isempty(stateIndices) )
                stateIndices = ':';
            end
            
            if (~exist('useOffset', 'var'))
                useOffset = false;
            end
            
            if (~exist('featureName','var'))
                featureName = 'Linear';
            end
            
            if (numel(featureVariables) > 1)
                featureVariables = {featureVariables};
            end
            
            obj = obj@FeatureGenerators.FeatureGenerator(dataManager, featureVariables, featureName, stateIndices);
            
            obj.useOffset = useOffset;
            obj.registerFeatureInData();
            
        end
        
        function [features] = getFeaturesInternal(obj, numElements, inputMatrix)
            
            if (nargin == 3 && ~isempty(inputMatrix))
                features = zeros(size(inputMatrix,1), obj.getNumFeatures);
                index = 0;
                if (obj.useOffset)
                    features(:,1) = 1;
                    index = 1;
                end
                features(:,index+1:end) = inputMatrix;
            else
                features = zeros(numElements, 0);
            end
            
        end
        
        function [numFeatures] = getNumFeatures(obj)
            numFeatures = length(obj.stateIndices);
            
            if (obj.useOffset)
                numFeatures = numFeatures + 1;
            end
        end
        
    end
    
end


