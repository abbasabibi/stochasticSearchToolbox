classdef DiscreteActionStateFeatureGenerator < FeatureGenerators.FeatureGenerator
    
    properties
        numActions
    end
    
    % Class methods
    methods
        function obj = DiscreteActionStateFeatureGenerator(dataManager, stateFeatures, actionName)
            
            if (~exist('actionName', 'var'))
                actionName = 'actions';
            end
            
            numFeatures = dataManager.getNumDimensions(stateFeatures);
            numActions = dataManager.getMaxRange(actionName);
            
            obj = obj@FeatureGenerators.FeatureGenerator(dataManager, {stateFeatures, actionName}, 'DiscreteActions', ':', numFeatures * numActions);
            obj.setIsSparse(dataManager.isSparse(stateFeatures));
            obj.numActions = numActions;
        end
        
        function [stateFeaturesActions] = getFeaturesInternal(obj, numElements, inputMatrix, actions)
            if (~exist('actions', 'var'))
                stateFeatures = inputMatrix(:,1:end-1);
                actions = inputMatrix(:,end:end);
            else
                stateFeatures = inputMatrix;
            end
            stateFeaturesActions = spalloc(size(stateFeatures,1), obj.numActions * size(stateFeatures,2), size(stateFeatures,1));
            numFeatures = size(stateFeatures,2);
            for i = 1:size(stateFeatures,1)
                stateFeaturesActions(i, (actions(i) - 1) * numFeatures + (1:numFeatures)) = stateFeatures(i,:);
            end
        end
        
        function [isValid] = isValidFeatureTag(obj, featureTags)
            isValid = zeros(size(featureTags));
        end
    end
end
