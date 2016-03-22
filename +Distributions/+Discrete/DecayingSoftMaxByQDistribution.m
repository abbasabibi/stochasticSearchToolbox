classdef DecayingSoftMaxByQDistribution < Distributions.Discrete.DiscreteDistribution
    
    properties (SetObservable, AbortSet)
        params;
        tau = 10;
        decay = 0.1;
    end
    
    methods (Static)
        function [obj] = createPolicy(dataManager, stateFeatureName)
            obj = Distributions.Discrete.DecayingSoftMaxByQDistribution(dataManager, 'actions', stateFeatureName, 'softMaxPolicy');
            obj.addDataFunctionAlias('sampleAction', 'sampleFromDistribution');
        end
        
        function [obj] = createDiscretizedActionPolicy(dataManager, stateFeatureName, discreteActionInterpreter)
            obj = Distributions.Discrete.DecayingSoftMaxByQDistribution(dataManager, discreteActionInterpreter.discreteActionName, stateFeatureName, 'softMaxPolicy');
            obj.addDataFunctionAlias('sampleAction', 'sampleFromDistribution');
            obj.setDiscreteActionInterpreter(discreteActionInterpreter);
        end
    end
    
    methods
        
        function obj = DecayingSoftMaxByQDistribution(dataManager, outputVariable, inputVariables, functionName, varargin)
            superargs = {};
            if (nargin >= 1)
                superargs = {dataManager, outputVariable, inputVariables, functionName, varargin{:}};
            end
            
            obj = obj@Distributions.Discrete.DiscreteDistribution(superargs{:});
            
            obj.linkProperty('tau','softMaxTemperature');
            obj.linkProperty('decay','softMaxDecay');
        end
        
        function [] = initObject(obj)
            obj.initObject@Distributions.Discrete.DiscreteDistribution();
            obj.params = ones(obj.dimInput*obj.numItems+1,1);
        end
        
        function [probabilities] = getItemProbabilities(obj, numElements, inputFeatures)
            beta = reshape(obj.params(2:end),obj.dimInput,obj.numItems);
            bias = obj.params(1);
            qV = (inputFeatures * beta + bias);
            qV = bsxfun(@minus,qV,max(qV,[],2));
            qV = exp(bsxfun(@rdivide,qV,obj.tau)); 
            probabilities = bsxfun(@rdivide, qV, sum(qV,2));
        end
        
        function [] = setParameterVector(obj, vector) 
            obj.params = vector;
            obj.tau = obj.tau*(1-obj.decay);
            fprintf('Temperature is now %1.3f\n', obj.tau)
        end
    end
end
