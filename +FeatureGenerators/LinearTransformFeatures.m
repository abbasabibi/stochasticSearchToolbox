classdef LinearTransformFeatures < FeatureGenerators.FeatureGenerator
    %PRIMARYCOMPONENTFEATURES Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (AbortSet, SetObservable)
    end
    
    properties (SetAccess=protected)
        M % linear transformation matrix
        featureTag = 0;
    end
    
    methods
        function obj = LinearTransformFeatures(varargin)
            obj = obj@FeatureGenerators.FeatureGenerator(varargin{:});
        end
        
        function [] = initObject(obj)
            obj.registerFeatureInData();
        end
        
        function setM(obj, M)
            obj.M = M;
            obj.featureTag = obj.featureTag + 1;
        end
        
        function [featureTag] = getFeatureTag(obj)
            featureTag = obj.featureTag;
        end
        
        function [isValid] = isValidFeatureTag(obj, featureTags)
            isValid = featureTags == obj.featureTag;
        end
        
        function [features] = getFeaturesInternal(obj, ~, inputMatrix)
            features = inputMatrix * obj.M;
        end
    end
    
end

