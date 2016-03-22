classdef ConstantDiscreteDistribution < Distributions.Discrete.DiscreteDistribution
    properties (SetAccess=protected)
        itemProb = [];
    end
    
    properties (SetObservable, AbortSet)
        
    end
    
    
    
    methods
        
        function obj = ConstantDiscreteDistribution(dataManager, outputVariable, functionName, varargin)
            superargs = {};
            if (nargin >= 1)
                superargs = {dataManager, outputVariable, {}, functionName, varargin{:}};
            end
            
            obj = obj@Distributions.Discrete.DiscreteDistribution(superargs{:});
            
        end
        
        
        function [] = initObject(obj)
            
            obj.initObject@Distributions.Discrete.DiscreteDistribution();
            
            obj.itemProb = ones(1,obj.numItems)/obj.numItems;
        end
        
        
        function [probabilities] = getItemProbabilities(obj, numElements)
            if (~exist('numElements', 'var'))
                numElements = 1;
            end
            probabilities = repmat(obj.itemProb, numElements,1);
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
