classdef GridFeatures < FeatureGenerators.FeatureGenerator
    
    properties
        range
        numState
        min
        max
    end
    
    methods
        function obj =  GridFeatures(dataManager, featureVariables, gridDim, stateIndices)
            if (~exist('stateIndices', 'var'))
                stateIndices = ':';
            end
            cnt = prod(gridDim);

            obj = obj@FeatureGenerators.FeatureGenerator(dataManager, featureVariables, 'Grid', stateIndices, cnt);
            
            obj.min = dataManager.getMinRange(featureVariables);
            obj.max = dataManager.getMaxRange(featureVariables)+1e-12;
            obj.range = gridDim;
            obj.numState = cnt;
            obj.setIsSparse(true);
        end
        
        function [features] = getFeaturesInternal(obj, numElements, inputMatrix)
            discreteMatrix = obj.getDiscreteMatrix(inputMatrix);
            initialIndex = obj.getIndexByGrid(discreteMatrix);
            features = obj.getTabularByIndex(initialIndex);
        end
        
        function [discrete] = getDiscreteMatrix(obj,inputMatrix)
            matrix = bsxfun(@minus,inputMatrix,obj.min);
            discrete = floor(bsxfun(@rdivide, matrix, (obj.max-obj.min)./obj.range))+1;
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
            tabular = spalloc(size(index,1),obj.numState,size(index,1));
            for i=1:numel(index)
                tabular(i,index(i))=1;
            end
        end
        
        function [index] = getIndexByTabular(obj, tabular)
            [row,index] = find(tabular == 1);
        end
    end
    
end

