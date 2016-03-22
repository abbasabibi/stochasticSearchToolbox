classdef SoftMaxByQDistribution < Distributions.Discrete.DiscreteDistribution
        
    properties (SetObservable, AbortSet)
        qFunction
        tau = 1;
    end
    
    methods (Static)
        function [obj] = createPolicy(dataManager, stateFeatureName, qFunction)
            obj = Distributions.Discrete.SoftMaxByQDistribution(dataManager, 'actions', stateFeatureName, 'softMaxPolicy', qFunction);
            obj.addDataFunctionAlias('sampleAction', 'sampleFromDistribution');
        end
        
        function [obj] = createDiscretizedActionPolicy(dataManager, stateFeatureName, qFunction, discreteActionInterpreter)
            obj = Distributions.Discrete.SoftMaxByQDistribution(dataManager, discreteActionInterpreter.discreteActionName, stateFeatureName, 'softMaxPolicy', qFunction);
            obj.addDataFunctionAlias('sampleAction', 'sampleFromDistribution');
            obj.setDiscreteActionInterpreter(discreteActionInterpreter);
        end
    end
    
    methods
        
        function obj = SoftMaxByQDistribution(dataManager, outputVariable, inputVariables, functionName, qFunction, varargin)
            superargs = {};
            if (nargin >= 1)
                superargs = {dataManager, outputVariable, inputVariables, functionName, varargin{:}};
            end
            
            obj = obj@Distributions.Discrete.DiscreteDistribution(superargs{:});
            
            obj.qFunction = qFunction;
            
            obj.linkProperty('tau','softMaxTemperature');
        end
        
        function [] = initObject(obj)
            obj.initObject@Distributions.Discrete.DiscreteDistribution();
        end
        
        function [probabilities] = getItemProbabilities(obj, numElements, inputFeatures)
            params = obj.qFunction.getParameterVector;
            beta = reshape(params(2:end),obj.dimInput,obj.numItems);
            bias = params(1);
            qValues = (inputFeatures * beta + bias);
            qValues = bsxfun(@minus, qValues,  max(qValues, [], 2));
            stdQVal = std(qValues, [], 2);
            stdQVal(stdQVal == 0) = 1;
            qValues = bsxfun(@rdivide, qValues,  stdQVal);
            qV = exp(qValues/obj.tau);
            probabilities = bsxfun(@rdivide, qV, sum(qV,2));            
        end        
    end
end
