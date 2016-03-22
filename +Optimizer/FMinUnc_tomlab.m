classdef FMinUnc_tomlab < Optimizer.Unconstrained;
    
    properties (SetAccess = protected)
        
        outputFun = {}
        
        useGradient;
        useHessian;
               
    end
    
    properties
        tomlabOptions;
        options = [];
    end

    methods
        function obj = FMinUnc_tomlab(numParams, useGradient, useHessian, tomlaboptions, varargin)
            obj = obj@Optimizer.Unconstrained(numParams, varargin{:});
                                    
            obj.useGradient = useGradient;
            obj.useHessian = useHessian;
            obj.useDisplay = 'off';%can be off, iter, final
            
            obj.tomlabOptions = tomlaboptions;

        end
        
        
        function set.outputFun(obj, val)
            obj.outputFun = val;
            obj.setOptions();
        end
        
        function setOptions(obj)
            obj.options = optimset('fminunc');
            
            if (obj.useGradient)
                useGradientTemp = 'on';
            else
                useGradientTemp = 'off';
            end
            
            if (obj.useHessian)
                useHessianTemp = 'on';
            else
                useHessianTemp = 'off';
            end             
            
            obj.options = optimset(obj.options, 'GradObj',useGradientTemp,'Hessian',useHessianTemp, 'Display', obj.useDisplay,...
                'LargeScale', 'on', 'OutputFcn',obj.outputFun,'Diagnostics','off','MaxIter', obj.maxNumOptiIterations);
            
            %obj.options = optimset(obj.options, 'GradObj',useGradientTemp,'Hessian',useHessianTemp, 'Display', obj.useDisplay,'MaxFunEvals', obj.maxNumOptiIterations * 10,...
            %    'LargeScale', 'on', 'TolX', obj.toleranceX, 'TolFun', obj.toleranceFunction, 'MaxIter', obj.maxNumOptiIterations, 'OutputFcn',obj.outputFun,'Diagnostics','off');
        end
              

        function [] = setPrintIterations(obj, useDisplay)
            if (useDisplay)
                obj.useDisplay = 'iter';
            else
                obj.useDisplay = 'off';
            end
        end
        

        function [params, val, numIterations] = optimizeInternal(obj, func, params)
            
            obj.setOptions();
            if(isempty(obj.tomlabOptions.HessPattern))
                obj.tomlabOptions.HessPattern = ones(numel(params));
            end
            %obj.tomlabOptions.varargin = func;
            objective = @(params_) obj.objectiveFunction(func, params_);
            [params, val, ~, output] = fminunc('Common.Helper.objective',params,obj.options, obj.tomlabOptions,objective);
            numIterations = output.iterations;
        end
        

    end
    
    
end

