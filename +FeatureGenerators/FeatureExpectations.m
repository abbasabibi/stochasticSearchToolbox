classdef FeatureExpectations < FeatureGenerators.FeatureGenerator
    
    properties (SetObservable)
        gamma
        useBias = false;
    end
    
    methods
        function obj =  FeatureExpectations(dataManager,featureVariables)
            size = dataManager.getNumDimensions(featureVariables)+1;
            obj = obj@FeatureGenerators.FeatureGenerator(dataManager,featureVariables, 'featureExpectations', ':', size, true);
            
            obj.linkProperty('gamma', 'discountFactor');
            obj.linkProperty('useBias', 'useFEbias');
        end
        
        function [features] = getFeaturesInternal(obj, numElements, inputMatrix)
            if obj.useBias
                inputMatrix=[ones(size(inputMatrix,1),1),inputMatrix]; %Offset
            else
                inputMatrix=[zeros(size(inputMatrix,1),1),inputMatrix]; %Offset               
            end
            features = sum(bsxfun(@times,inputMatrix,transpose(obj.gamma.^((1:size(inputMatrix,1))-1))));
            %l1 norm
            %features = bsxfun(@rdivide, features, sum(abs(features),2));
        end
        
        function [isValid] = isValidFeatureTag(obj, featureTags)
            isValid = zeros(size(featureTags));
        end
    end
    
end

