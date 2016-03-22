classdef UcSolve < Optimizer.Unconstrained
    %Unconstrained optimization with simple bounds on the parameters.
    %  Implements Newton, quasi-Newton and conjugate-gradient methods.
    % 
    % Full documentation in the tomlap manual Page 180
    %
    % NOT WORKING
    
    properties
    end
    
    methods
        
        function obj = UcSolve(numParams)
            obj = obj@Optimizer.Unconstrained(numParams, varargin{:});
            obj.prob = struct;           
        end
        
        function setProb(newProb)
            obj.prop = newProb;
        end
        
        function [params, val, numIterations] = optimizeInternal(obj, func, params)
            % Set the new prob Struct
            obj.setProb(params);
            % Name of m-file computing the objective function f(x)
            obj.prop.FUNCS.f = func;
            
            % run tomlap function
            result = ucSolve(Prob, varargin);
            
            %translate Output variabels          
            val = result.x_k;
            numIterations = result.Iter;
        
        end
    end
    
end

