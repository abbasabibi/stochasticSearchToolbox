classdef FMinCon < Optimizer.BoxConstrained;
    
    properties
        options;
        hessianFun = [];
        algorithm = 'interior-point';
        outputFun = {}
        
        useHessianFMinCon
    end
    
    methods
        function obj = FMinCon(numParams,  lowerBound, upperBound, optimizationName)                        
            
            obj = obj@Optimizer.BoxConstrained(numParams, lowerBound, upperBound, optimizationName);
        end
        
                
        
        function setOptions(obj)

            if (obj.useHessian && ~obj.isInitialized)
                warning('Function supports Hessian but no Hessians are supported by the toolboxs fmincon implementation\n');
            end
%             val = obj.useHessian;
%             if(iscell(val))
%                 obj.hessianFun = val{2};
%                 val = val{1};
%             end
%                 
%             if((islogical(val) && val == false) || strcmpi(val,'off'))
%                 obj.hessianFun = [];
%                 obj.algorithm = 'interior-point';
%             elseif(strcmpi(val,'user-supplied'))
%                 if(isempty(obj.hessianFun))
%                     obj.algorithm = 'trust-region-reflective';
%                 else
%                     obj.algorithm = 'interior-point';
%                 end
%             else
%                 error('Unknown option value');
%             end

            obj.options = optimset('fminunc');
            if (obj.useDisplay)
                useDisplayLocal = 'iter';
            else
                useDisplayLocal = 'off';
            end
            
            useGradientLocal = 'on';
            if (~obj.useGradient)
                useGradientLocal = 'off';
            end
            
            
            useHessianLocal = 'off';
%             if (~obj.useHessian)
%                 useHessianLocal = 'off';
%             end

            obj.options = optimset(obj.options,'GradObj',useGradientLocal, 'Hessian', useHessianLocal, 'HessFcn', obj.hessianFun ,  'Display',useDisplayLocal,'MaxFunEvals', obj.maxNumOptiIterations * 5,...
                'Algorithm', obj.algorithm, 'TolX', obj.OptiAbsxTol, 'TolFun', obj.OptiAbsfTol, 'MaxIter', obj.maxNumOptiIterations, 'OutputFcn',obj.outputFun);
        end
        
        function [params, val, numIterations] = optimizeInternal(obj, func, params)
            objective = @(params_) obj.objectiveFunction(func, params_);
            [params, val, ~, output] = fmincon(objective, params, [], [], [], [], obj.lowerBound, obj.upperBound, [], obj.options);
            numIterations = output.iterations;
        end
    end
        
end

