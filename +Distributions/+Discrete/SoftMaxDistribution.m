classdef SoftMaxDistribution < Distributions.Discrete.DiscreteDistribution
    
    properties (SetAccess=protected)
        thetaAllItems
    end
    
    properties (SetObservable, AbortSet)
    end
    
    methods (Static)
        
        function [obj] = createPolicy(dataManager, stateFeatureName, actionName)
            if (~exist('actionName', 'var'))
                actionName = 'actions';
            end
            obj = Distributions.Discrete.SoftMaxDistribution(dataManager, actionName, stateFeatureName, 'softMaxPolicy');
            obj.addDataFunctionAlias('sampleAction', 'sampleFromDistribution');
        end
        
        function [obj] = createDiscretizedActionPolicy(dataManager, stateFeatureName, discreteActionInterpreter)
            obj = Distributions.Discrete.SoftMaxDistribution(dataManager, discreteActionInterpreter.discreteActionName, stateFeatureName, 'softMaxPolicy');
            obj.addDataFunctionAlias('sampleAction', 'sampleFromDistribution');
            obj.setDiscreteActionInterpreter(discreteActionInterpreter);
        end
    end
    
    methods
        
        function obj = SoftMaxDistribution(dataManager, outputVariable, inputVariables, functionName, varargin)
            superargs = {};
            if (nargin >= 1)
                superargs = {dataManager, outputVariable, inputVariables, functionName, varargin{:}};
            end
            
            obj = obj@Distributions.Discrete.DiscreteDistribution(superargs{:});
        end
        
        function [] = initObject(obj)
            
            obj.initObject@Distributions.Discrete.DiscreteDistribution();
            
            obj.thetaAllItems = zeros(obj.numItems, obj.dimInput);
        end
        
        function [probabilities] = getItemProbabilities(obj, numElements, inputFeatures, varargin)
            logProb = inputFeatures * obj.thetaAllItems';
            logProb = bsxfun(@minus, logProb, max(logProb, [], 2)) ;
            probabilities = exp(logProb);
            probabilities = bsxfun(@rdivide, probabilities, sum(probabilities,2));
            
        end
        
        function [] = setThetaAllItems(obj, thetaAllItems)
          obj.thetaAllItems = thetaAllItems;
        end
        
    end
end
