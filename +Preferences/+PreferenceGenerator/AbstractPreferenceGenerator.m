classdef AbstractPreferenceGenerator < FeatureGenerators.FeatureGenerator
    
    properties (SetObservable)
        numSamples;
    end
    
    properties
        globalCalc = false;
        prefCount = 0;
    end
    
    methods
        function obj =  AbstractPreferenceGenerator(dataManager,calculateGlobal,rankVariable, featureExpectations)
            obj = obj@FeatureGenerators.FeatureGenerator(dataManager,{rankVariable,'contexts','iterationNumber', featureExpectations}, 'preferences',  ':', Common.Settings().getProperty('maxSamples'));
            obj.linkProperty('numSamples', 'maxSamples');
            if (exist('calculateGlobal', 'var'))
                obj.globalCalc = calculateGlobal';
            end
        end
                
        function [features] = getFeaturesInternal(obj, numElements, inputMatrix, context, iterationNumber, featureExpectations)
            if obj.globalCalc
                obj.prefCount = 0;
                tmpFeatures = obj.createPairwisePreferences(inputMatrix, iterationNumber, featureExpectations);
                features = [tmpFeatures,ones(size(tmpFeatures,1),obj.numSamples-size(tmpFeatures,2))];
            else
                features = [];
                for i = min(iterationNumber):max(iterationNumber)
                    tmpMatrix = inputMatrix(iterationNumber==i);
                    tmpFeatures = obj.createPairwisePreferences(tmpMatrix,iterationNumber(iterationNumber==i), featureExpectations(iterationNumber==i));
                    dim = sum(iterationNumber==i);
                    tmpFeatures = [ones(size(tmpFeatures,1),max(0,dim*(i-min(iterationNumber)))),tmpFeatures];
                    tmpFeatures = [tmpFeatures,ones(size(tmpFeatures,1),obj.numSamples-size(tmpFeatures,2))];
                    features = [features ; tmpFeatures];
                end
            end
        end
        
        function [isValid] = isValidFeatureTag(obj, featureTags)
            isValid = zeros(size(featureTags));
        end
    end
    
    methods (Abstract)
        %This function must return an 2xNxM array, with 2 as the preference
        %pairs, N the featureExpectations and M the amount of pairs
        createPairwisePreferences(obj,ranking, iterationNumber, featureExpectations)
    end
end

