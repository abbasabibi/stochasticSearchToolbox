classdef UniformDistribution < Distributions.Discrete.DiscreteDistribution
    
    properties
        
    end
    
    properties (SetObservable, AbortSet)
    end
    
    methods (Static)
        function [obj] = createPolicy(dataManager, stateFeatureName)
            obj = Distributions.Discrete.UniformDistribution(dataManager, 'actions', [], 'uniformPolicy');
            obj.addDataFunctionAlias('sampleAction', 'sampleFromDistribution');
        end
    end
    
    methods
        
        function obj = UniformDistribution(dataManager, outputVariable, inputVariables, functionName, varargin)
            superargs = {};
            if (nargin >= 1)
                superargs = {dataManager, outputVariable, inputVariables, functionName, varargin{:}};
            end
            
            obj = obj@Distributions.Discrete.DiscreteDistribution(superargs{:});
            
            obj.registerMappingInterfaceDistribution();            
        end
        
        function [] = initObject(obj)
            
            obj.initObject@Distributions.Discrete.DiscreteDistribution();                        
            
        end
        
        function [probabilities] = getItemProbabilities(obj, numElements, varargin)
            probabilities = ones(numElements, obj.numItems) / obj.numItems;
        end                            
        
    end
end
