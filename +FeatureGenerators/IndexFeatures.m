classdef IndexFeatures < FeatureGenerators.FeatureGenerator
    
    properties
        range
    end
    
    methods
        function obj =  IndexFeatures(dataManager, featureVariables, stateIndices)
            if (~exist('stateIndices', 'var'))
                stateIndices = ':';
            end
            
            obj = obj@FeatureGenerators.FeatureGenerator(dataManager, featureVariables, 'Index', stateIndices, 1);
            
            max = prod(dataManager.getRange(featureVariables));
            dataManager.setRange(obj.outputName,1,max)
            
            obj.range = dataManager.getRange(featureVariables);
        end
        
        function [features] = getFeaturesInternal(obj, numElements, inputMatrix)
            features = obj.getIndexByGrid(inputMatrix);
        end
        
        function [index] = getIndexByGrid(obj, states)
            indexCell = num2cell(transpose(states),2);
            index = transpose(sub2ind(obj.range,indexCell{:}));
        end
        
    end
    
end

