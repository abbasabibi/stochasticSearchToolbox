classdef TabularFeatures < FeatureGenerators.FeatureGenerator
    
    properties
        range
        numState
    end
    
    methods
        function obj =  TabularFeatures(dataManager, featureVariables, stateIndices)
            if (~exist('stateIndices', 'var'))
                stateIndices = ':';
            end
            cnt = prod(dataManager.getRange(featureVariables));

            obj = obj@FeatureGenerators.FeatureGenerator(dataManager, featureVariables, 'Tabular', stateIndices, cnt);
            
            obj.range = dataManager.getRange(featureVariables);
            
            obj.numState = cnt;
        end
        
        function [features] = getFeaturesInternal(obj, numElements, inputMatrix)
            initialIndex = obj.getIndexByGrid(inputMatrix);
            features = obj.getTabularByIndex(initialIndex);
        end
        
        function [states] = getGridByIndex(obj,index)
            [x,y] = ind2sub(obj.range,index);
            states = [x,y];
        end
        
        function [index] = getIndexByGrid(obj, states)
            indexCell = num2cell(transpose(states),2);
            index = transpose(sub2ind(obj.range,indexCell{:}));
        end
        
        function [tabular] = getTabularByIndex(obj, index)
            tabular = zeros(size(index,1),obj.numState);
            for i=1:size(index)
                tabular(i,index(i))=1;
            end
        end
        
        function [index] = getIndexByTabular(obj, tabular)
            [row,index] = find(tabular == 1);
        end
    end
    
end

