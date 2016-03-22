classdef EgreedyByQDistribution < Distributions.Discrete.DiscreteDistribution
    
    properties (SetObservable, AbortSet)
        params
        epsilon = 0.1;
    end
    
    methods (Static)
        function [obj] = createPolicy(dataManager, stateFeatureName)
            obj = Distributions.Discrete.EgreedyByQDistribution(dataManager, 'actions', stateFeatureName, 'eGreedyPolicy');
            obj.addDataFunctionAlias('sampleAction', 'sampleFromDistribution');
        end
        
        function [obj] = createDiscretizedActionPolicy(dataManager, stateFeatureName, discreteActionInterpreter)
            obj = Distributions.Discrete.EgreedyByQDistribution(dataManager, discreteActionInterpreter.discreteActionName, stateFeatureName, 'eGreedyPolicy');
            obj.addDataFunctionAlias('sampleAction', 'sampleFromDistribution');
            obj.setDiscreteActionInterpreter(discreteActionInterpreter);
        end
    end
    
    methods
        
        function obj = EgreedyByQDistribution(dataManager, outputVariable, inputVariables, functionName, varargin)
            superargs = {};
            if (nargin >= 1)
                superargs = {dataManager, outputVariable, inputVariables, functionName, varargin{:}};
            end
            
            obj = obj@Distributions.Discrete.DiscreteDistribution(superargs{:});
            
            obj.linkProperty('epsilon','greedyEpsilon');
        end
        
        function [] = initObject(obj)
            obj.initObject@Distributions.Discrete.DiscreteDistribution();
            obj.params = ones(obj.dimInput*obj.numItems+1,1);
        end
        
        function [probabilities] = getItemProbabilities(obj, numElements, inputFeatures)
            beta = reshape(obj.params(2:end),obj.dimInput,obj.numItems);
            bias = obj.params(1);
            qV = inputFeatures * beta + bias;
            probabilities = ones(size(qV))*(obj.epsilon/obj.numItems);
            maxPerRow = max(qV,[],2);
            cA = mat2cell(qV, ones(1, size(qV,1)), size(qV,2));
            cB = mat2cell(maxPerRow, ones(1, size(maxPerRow,1)), size(maxPerRow,2));
            maxIdx = cell2mat(cellfun(@ismember, cA, cB, 'UniformOutput',  false));
            probabilities = probabilities + bsxfun(@rdivide,maxIdx,sum(maxIdx,2)) * (1-obj.epsilon);
        end
        
        function [] = setParameterVector(obj, vector)
            obj.params = vector;
        end
    end
end
