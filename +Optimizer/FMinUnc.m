classdef FMinUnc < Optimizer.Unconstrained;
    % This class implements Matlabs FMinUnc optimizer into the structure of
    % the policysearchtoolbox.
    
    properties (SetAccess = protected)
        options = [];
        outputFun = {}
                   
    
    end
    
    methods
        function obj = FMinUnc(numParams, useGradient, useHessian, varargin)
            obj = obj@Optimizer.Unconstrained(numParams, varargin{:});
                                    
            obj.useGradient = useGradient;
            obj.useHessian = useHessian;                 
        end
        
        function setUseHessian(obj, useHessian)
            obj.useHessian = useHessian;
        end
        
        function setUseGradient(obj, useGradient)
            obj.useGradient = useGradient;
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
            
            if (obj.useDisplay)
                useDisplayLocal = 'iter';
            else
                useDisplayLocal = 'off';
            end

               
            obj.options = optimset(obj.options, 'GradObj',useGradientTemp,'Hessian',useHessianTemp, 'Display', useDisplayLocal, 'MaxFunEvals', obj.maxNumOptiIterations * 10,...
                'LargeScale', 'on', 'TolX', obj.OptiAbsxTol, 'TolFun', obj.OptiAbsfTol, 'MaxIter', obj.maxNumOptiIterations, 'OutputFcn',obj.outputFun);
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
            objective = @(params_) obj.objectiveFunction(func, params_);
            [params, val, ~, output] = fminunc(objective,params,obj.options);
            numIterations = output.iterations;
        end
        

    end
    
    
end

