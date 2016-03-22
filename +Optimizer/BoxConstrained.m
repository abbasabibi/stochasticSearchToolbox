classdef BoxConstrained < Optimizer.Unconstrained;
    % Optimizer.Unconstrained is the interface for every box constrained
    % optimizer.
    %
    % In addition to the functions if the unconstrained optimizer this class
    % also handles the two vectors <tt>lowerBound</tt> and <tt>upperBound</tt>
    % which should contain the box constraints used in the optimizer. 
    %
    % The main function of this class is to maintain the interchangeability 
    % of different optimizer. The abstract function  <tt>optimizeInternal()</tt>
    % in the base class <tt>Optimizer.Unconstrained</tt>
    % with the following parameters: 
    % 
    % Input:
    %  - func: the anonymous objective function f(x)
    %  - params: parameter depending on the optimizer used
    % 
    % Output:
    %  - params: parameter depending on the optimizer used
    %  - val: Optimal Point determined by the optimizer
    %  - numIterations: Number of Iterations used by optimizer
    
    properties
        lowerBound;
        upperBound;
    end
    
    methods
        function obj = BoxConstrained(numParams, lowerBound, upperBound, optimizationName)
            obj = obj@Optimizer.Unconstrained(numParams, optimizationName);
            if (isempty(lowerBound))
                lowerBound = -inf(1, numParams);
            end
            if (isempty(upperBound))
                upperBound = inf(1, numParams);
            end
                            
            obj.setBounds(lowerBound,upperBound)
        end
        
        function setBounds(obj, lowerBound, upperBound)
            obj.setLowerBound(lowerBound);
            obj.setUpperBound(upperBound);
        end
        
        function setLowerBound(obj, lowerBound)
            if(isempty(lowerBound) || all(size(lowerBound) == [1, obj.numParams]))
                obj.lowerBound = lowerBound;
            else
                error('Invalid boundary size.');
            end
        end
        
        function setUpperBound(obj, upperBound)
            if(isempty(upperBound) || all(size(upperBound) == [1, obj.numParams]))
                obj.upperBound = upperBound;
            else
                error('Invalid boundary size.');
            end
        end
        
        function [upperBound] = getUpperBoundTransformed(obj)
            upperBound = obj.unTransformParameters(obj.upperBound);
        end
        
        function [lowerBound] = getLowerBoundTransformed(obj)
            lowerBound = obj.unTransformParameters(obj.lowerBound);            
        end
        
    end
    
    
    
end

