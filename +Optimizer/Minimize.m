classdef Minimize < Optimizer.Unconstrained;
    
    properties
        options = [];
    end
    
    methods
        function obj = Minimize(numParams, varargin)
            obj = obj@Optimizer.Unconstrained(numParams, varargin{:});
        end
        
        function setOptions(obj)
        end
        
        function [params, val, numIterations] = optimizeInternal(obj, func, params)
            p.length = obj.maxNumOptiIterations;
            p.method = 'BFGS';
            p.verbosity = 0;
            p.mem = 100;
            objective = @(params_) obj.objectiveFunction(func, params_);
            [params, val, numIterations] = Optimizer.rasmussen.minimize(params,objective,p);
            val = val(end);
        end
    end
    
    
end

