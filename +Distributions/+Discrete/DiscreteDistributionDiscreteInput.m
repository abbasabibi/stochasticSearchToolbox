classdef DiscreteDistributionDiscreteInput < Distributions.Discrete.DiscreteDistribution
    properties (SetAccess=protected)
        itemProb = [];
    end
    
    properties (SetObservable, AbortSet)
        
    end
    
    
    
    methods
        
        function obj = DiscreteDistributionDiscreteInput(dataManager, outputVariable, inputVariable, functionName, varargin)
            superargs = {};
            if (nargin >= 1)
                superargs = {dataManager, outputVariable, inputVariable, functionName, varargin{:}};
            end
            
            obj = obj@Distributions.Discrete.DiscreteDistribution(superargs{:});
            
        end
        
        
        function [] = initObject(obj)
            
            obj.initObject@Distributions.Discrete.DiscreteDistribution();
            inputRange = obj.dataManager.getMaxRange(obj.inputVariables) - obj.dataManager.getMinRange(obj.inputVariables) +1;
            
            obj.itemProb = ones(inputRange, obj.numItems)/obj.numItems;
        end
        
        
        function [probabilities] = getItemProbabilities(obj, numElements, varargin)
            state = varargin{1} - obj.dataManager.getMinRange(obj.inputVariables) + 1;
            
            probabilities = repmat(obj.itemProb, numElements,1);
            probabilities = probabilities(state,:);
        end
        
        function [] = setItemProb(obj, itemProb)
            obj.itemProb = itemProb;
            obj.itemProb = obj.itemProb / sum(obj.itemProb);
            
            assert(all(obj.itemProb >= 0));
            
            obj.numItems = size(itemProb,2);
            
            if( size(itemProb, 1) > size(itemProb, 2) )
                warning('itemProb in ConstantDiscreteDistribution is transposed\n');
            end
        end
        
    end
    
    
end
