classdef TrajectoryImportance < FeatureGenerators.FeatureGenerator
        
    methods
        function obj =  TrajectoryImportance(dataManager)
            obj = obj@FeatureGenerators.FeatureGenerator(dataManager,'importanceWeights', 'Trajectory', ':', 1, true);
        end
        
        function [features] = getFeaturesInternal(obj, numElements, inputMatrix)
            features = sum(log(inputMatrix));
        end
        
        function [isValid] = isValidFeatureTag(obj, featureTags)
            isValid = zeros(size(featureTags));
        end
    end
    
end

