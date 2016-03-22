classdef NStepIterator < Optimizer.Unconstrained
    
    properties(SetAccess=protected)
        optimizer = Optimizer.Unconstrained.empty();
        optimizerIndices;
    end
    
    methods
        
        function obj = NStepIterator(options,varargin)
            numArg = numel(varargin);
            if(numArg)
                error('Odd number of arguments! Each optimizer needs an index-vector.');
            end
            
            obj = obj@Optimizer.Unconstrained(options);
            
            obj.optimizer = [varargin{1:2:numArg}];
            obj.optimizerIndices = varargin(2:2:numArg);
        end
        
        function [params, val, numIterations] = optimize(obj, getFunc,  params)
            optiStep = 1;
            while((optiStep <= obj.options.maxSteps) && ((valProgress > obj.options.minValProgress) || (optiStep <= obj.options.minSteps)) )
                
                for optiIdx = 1:numel(obj.optimizer)
                
                    func = getFunc(optiIdx,params);
                    
                    [params(obj.optimizerIndices{optiIdx}), val(optiIdx,optiStep), numIterations(optiIdx,optiStep)] = obj.optimizer(optiIdx).optimize(func, params(obj.optimizerIndices{optiIdx}));
                
                end
                
                optiStep = optiStep+1;
            end
        end
        
    end
    
    methods(Static)
        function options = getDefaultOptions()
            options = [];
        end
    end
    
end

