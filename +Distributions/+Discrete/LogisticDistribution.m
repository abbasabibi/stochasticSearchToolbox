classdef LogisticDistribution < Distributions.Discrete.DiscreteDistribution
    
    properties (SetAccess=protected)
        theta
    end
    
    properties (SetObservable, AbortSet)
    end
    
    methods (Static)
        function [obj] = createPolicy(dataManager, stateFeatureName)
            obj = Distributions.Discrete.SoftMaxDistribution(dataManager, 'actions', stateFeatureName, 'logisticPolicy');
            obj.addDataFunctionAlias('sampleAction', 'sampleFromDistribution');
        end
    end
    
    methods
        
        function obj = LogisticDistribution(dataManager, outputVariable, inputVariables, functionName, varargin)
            superargs = {};
            if (nargin >= 1)
                superargs = {dataManager, outputVariable, inputVariables, functionName, varargin{:}};
            end
            
            obj = obj@Distributions.Discrete.DiscreteDistribution(superargs{:});
        end
        
        function [] = initObject(obj)
            
            obj.initObject@Distributions.Discrete.DiscreteDistribution();
            
            obj.theta = zeros(1, obj.dimInput);
        end
        
        function [probabilities] = getItemProbabilities(obj, numElements, inputFeatures)
%             probabilities = 1 - log( 1+ exp(-inputFeatures * obj.thetaAllItems'));
              probabilities = 1 ./( 1+ exp(-inputFeatures * obj.theta'));
              probabilities = [probabilities , 1- probabilities];
        end
        
        function [] = setTheta(obj, theta)
          obj.theta = theta;
        end
        
    end
end
