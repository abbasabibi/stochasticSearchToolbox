classdef WeightedLinearFeatures < FeatureGenerators.LinearFeatures

    properties
        weights;
    end
    
    methods
        function [obj] = WeightedLinearFeatures(dataManager, featureVariables, stateIndices,weights)
            if (~exist('stateIndices', 'var'))
                stateIndices = ':';
            end
            obj = obj@FeatureGenerators.LinearFeatures(dataManager, featureVariables, stateIndices);

            if(iscell(obj.stateIndices))
                obj.weights = eye(prod(cellfun(@(x) numel(x), obj.stateIndices)));
            else
                obj.weights = eye(numel(obj.stateIndices));
            end
            if(exist('weights', 'var'))
                obj.setWeights(weights);
            end
        end
        
        function setWeights(obj, weights)
            if(isscalar(weights))
                obj.weights = eye(size(obj.weights))*weights;
            elseif(isvector(weights))
                obj.weights = diag(weights);
            else
                obj.weights = weights;
            end
        end
        
        function [features] = getFeaturesInternal(obj, numElements, inputMatrix)
            
            rawfeatures = getFeaturesInternal@FeatureGenerators.LinearFeatures(obj,numElements, inputMatrix);
            features = obj.weights * rawfeatures;
        end
        

        
    end
    
end


