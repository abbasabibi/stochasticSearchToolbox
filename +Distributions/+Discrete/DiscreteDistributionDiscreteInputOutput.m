classdef DiscreteDistributionDiscreteInputOutput < Distributions.Discrete.DiscreteDistribution
    properties (SetAccess=protected)
        itemProb = [];
    end
    
    properties (SetObservable, AbortSet)
        
    end
    
    
    methods (Static)
        
        function [obj] = createPolicy(dataManager, stateFeatureName, actionName)
            if (~exist('actionName', 'var'))
                actionName = 'actions';
            end
            obj = Distributions.Discrete.DiscreteDistributionDiscreteInputOutput(dataManager, actionName, stateFeatureName, 'DiscreteInputPolicy');
            obj.addDataFunctionAlias('sampleAction', 'sampleFromDistribution');
        end
        
    end
    
    methods
        
        function obj = DiscreteDistributionDiscreteInputOutput(dataManager, outputVariable, inputVariable, functionName, varargin)
            superargs = {};
            if (nargin >= 1)
                superargs = {dataManager, outputVariable, inputVariable, functionName, varargin{:}};
            end
            
            obj = obj@Distributions.Discrete.DiscreteDistribution(superargs{:});
            
        end
        
        
        function [] = initObject(obj)
            
            obj.initObject@Distributions.Discrete.DiscreteDistribution();
            inputRange = obj.dataManager.getMaxRange(obj.inputVariables) - obj.dataManager.getMinRange(obj.inputVariables) +1;
            
            obj.itemProb = ones(obj.dimInput, obj.numItems)/obj.numItems;
        end
        
        
        function [probabilities] = getItemProbabilities(obj, numElements, varargin)
            probabilities = varargin{1} * obj.itemProb;
        end
        
        function [] = setItemProb(obj, itemProb)
            obj.itemProb = itemProb;
        end
        
        function [itemProb] = getItemProb(obj)
            itemProb = obj.itemProb;
        end
        
    end
    
    
end
