classdef DiscreteDistribution < Distributions.Distribution & Functions.Mapping
    
    properties
        numItems
    end
    
    properties (SetAccess=protected)        
        discreteActionInterpreter
    end
    
    properties (SetObservable, AbortSet)
        
    end
    
    methods
        
        function obj = DiscreteDistribution(dataManager, outputVariable, inputVariables, functionName, varargin)
            superargs = {};
            if (nargin >= 1)
                superargs = {dataManager, outputVariable, inputVariables, functionName, varargin{:}};
            end
            
            obj = obj@Distributions.Distribution();
            obj = obj@Functions.Mapping(superargs{:});
            
            obj.numItems = dataManager.getMaxRange(outputVariable) - dataManager.getMinRange(outputVariable)+1;
            
            obj.registerMappingInterfaceDistribution();
            obj.addMappingFunction('getItemProbabilities', 'Probabilities');
        end
        
        function [index] = sampleFromDistribution(obj, numElements, varargin)
            [probabilities] = getItemProbabilities(obj, numElements, varargin{:});
            z = rand(numElements, 1);
            probabilities = cumsum(probabilities, 2);
            greaterThan = bsxfun(@gt, probabilities, z);
            index = size(probabilities,2) + 1 - sum(greaterThan,2);
        end
        
        function [qAs] = getDataProbabilities(obj, inputVariables, outputVariables, varargin)
            itemProbabilities = obj.getItemProbabilities(size(outputVariables, 1), inputVariables, varargin{:});
            qAs = zeros(size(outputVariables));
            for i=1:numel(qAs)
                qAs(i) = itemProbabilities(i,outputVariables(i));
            end
            qAs = log(qAs);
        end
        
        function [] = setDiscreteActionInterpreter(obj, discreteActionInterpreter)
            if (~isempty(obj.discreteActionInterpreter))
                warning('pst:discrete action interpreter should not be set twice!\n');
            end
            obj.discreteActionInterpreter = discreteActionInterpreter;
            obj.addDataFunctionAlias('sampleAction', 'mapDiscreteAction', discreteActionInterpreter);
        end
        
    end
    
    methods (Abstract)
        [probabilities] = getItemProbabilities(obj, numElements, varargin);
    end
end
