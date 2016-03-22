classdef DeterministicMaxDistribution < Distributions.Discrete.DiscreteDistribution
    
    properties (SetAccess=protected)
        qValues
        seen
    end
    
    properties (SetObservable, AbortSet)
    end
    
    methods (Static)
        function [obj] = createPolicy(dataManager, stateFeatureName)
            obj = Distributions.Discrete.DiscreteDistribution(dataManager, 'actions', stateFeatureName, 'deterministicMaxPolicy');
            obj.addDataFunctionAlias('sampleAction', 'sampleFromDistribution');
        end
    end
    
    methods
        
        function obj = DeterministicMaxDistribution(dataManager, outputVariable, inputVariables, functionName, varargin)
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
        
        function [probabilities] = getItemProbabilities(obj, numElements, inputFeatures)
            value = inputFeatures * obj.qValues';
            value(inputFeatures * obj.seen' == 0) = -Inf;
            value = bsxfun(@minus, value, max(value, [], 2)) ;
            value(value==0)=1;
            value(value~=1)=0;
            probabilities = bsxfun(@rdivide, value, sum(value,2));          
        end
        
        function [] = setValues(obj,seen,values)
          obj.qValues = vec2mat(values'*seen,obj.dimInput);
          obj.seen = vec2mat(sum(seen,1),obj.dimInput);
          %obj.qValues
        end
        
    end
end
