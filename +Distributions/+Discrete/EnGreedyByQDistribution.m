classdef EnGreedyByQDistribution < Distributions.Discrete.EgreedyByQDistribution
    
    properties (SetObservable, AbortSet)
        epsC=0.9;
        epsD=2;
        iteration=1;
    end
    
    methods (Static)
        function [obj] = createPolicy(dataManager, stateFeatureName)
            obj = Distributions.Discrete.EnGreedyByQDistribution(dataManager, 'actions', stateFeatureName, 'EnGreedyPolicy');
            obj.addDataFunctionAlias('sampleAction', 'sampleFromDistribution');
        end
        
        function [obj] = createDiscretizedActionPolicy(dataManager, stateFeatureName, discreteActionInterpreter)
            obj = Distributions.Discrete.EnGreedyByQDistribution(dataManager, discreteActionInterpreter.discreteActionName, stateFeatureName, 'EnGreedyPolicy');
            obj.addDataFunctionAlias('sampleAction', 'sampleFromDistribution');
            obj.setDiscreteActionInterpreter(discreteActionInterpreter);
        end
    end
    
    methods
        
        function obj = EnGreedyByQDistribution(dataManager, outputVariable, inputVariables, functionName, varargin)
            superargs = {};
            if (nargin >= 1)
                superargs = {dataManager, outputVariable, inputVariables, functionName, varargin{:}};
            end
            
            obj = obj@Distributions.Discrete.EgreedyByQDistribution(superargs{:});
            
            obj.linkProperty('epsC','greedyEpsilonC');
            obj.linkProperty('epsD','greedyEpsilonD');
        end
        
        function [] = initObject(obj)
            obj.initObject@Distributions.Discrete.DiscreteDistribution();
        end
        
        function [probabilities] = getItemProbabilities(obj, numElements, inputFeatures, iteration)
            epsilon = min(1,(obj.epsC*obj.numItems)./(obj.epsD^2*iteration));
            params = obj.qFunction.getParameterVector;
            beta = reshape(params(2:end),obj.dimInput,obj.numItems);
            bias = params(1);
            qV = inputFeatures * beta + bias;
            probabilities = bsxfun(@times,ones(size(qV)),epsilon/obj.numItems);
            maxPerRow = max(qV,[],2);
            cA = mat2cell(qV, ones(1, size(qV,1)), size(qV,2));
            cB = mat2cell(maxPerRow, ones(1, size(maxPerRow,1)), size(maxPerRow,2));
            maxIdx = cell2mat(cellfun(@ismember, cA, cB, 'UniformOutput',  false));
            probabilities = probabilities + bsxfun(@times,bsxfun(@rdivide,maxIdx,sum(maxIdx,2)),(1-epsilon));
        end
        
        function [] = setParameterVector(obj, vector)
            obj.params = vector;
            obj.epsilon = min(1,(obj.epsC*obj.numItems)./(obj.epsD^2*obj.iteration));
            fprintf('Epsilon is now %1.3f\n', obj.epsilon)
            obj.iteration = obj.iteration+1;
        end
    end
    
end
