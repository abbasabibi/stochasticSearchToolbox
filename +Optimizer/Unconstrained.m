classdef Unconstrained < Common.IASObject;
    % Optimizer.Unconstrained is the interface for every unconstrained
    % optimizer.
    %
    % The main function of this class is to maintain the interchangeability 
    % of different optimizer. The abstract function <tt>optimizeInternal()</tt>
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
        numParams; % number of parameters  to optimize 
        
        isMaximize % flag true if looking for maximum
        expParameterTransform % flag vector, true for each parameter you want to transformed (x->exp(x)) in the optimizer.
        
        optimizationName % name of the optimizer
        
        useDisplay;
%        isInitialized = false;

        useGradient = true;
        useHessian = false;

        requiresRowGradient = false;

	    returnCode;
    end
    
    properties (SetObservable, AbortSet)
        maxNumOptiIterations = 100;
        lambda;

        
        % algorithm can be changed via the Settings Class
        OptibPrint = false; % print output flag           
        
        % stopping criteria
        OptiStopVal = []; % Stop after Value is found
        OptiAbsfTol = 10^-12; % Stop after absolute function tolerance reached
        OptiAbsxTol = 10^-12; % Stop after absolute output tolerance reached
        OptiMaxTime = 5 * 60 * 60; % Stop after a number of seconds
    end
    
    methods
        
        function obj = Unconstrained(numParams, optimizationName)
            obj = obj@Common.IASObject();
            
            if (~exist('optimizationName', 'var'))
                optimizationName = '';
            end
            obj.optimizationName = optimizationName;
            obj.numParams = numParams;
            obj.lambda = round(4 + 3 * log(numParams));
            obj.linkProperty('lambda');
            obj.linkProperty('maxNumOptiIterations',  [optimizationName, 'NumIterations']);

                                                
            obj.linkProperty('OptiStopVal',[optimizationName,'OptiStopVal']);
            obj.linkProperty('OptiAbsfTol',[optimizationName,'OptiAbsfTol']);
            obj.linkProperty('OptiAbsxTol',[optimizationName,'OptiAbsxTol']);
            obj.linkProperty('OptiMaxTime',[optimizationName,'OptiMaxTime']);

            
            obj.expParameterTransform = false(numParams,1);
            obj.isMaximize = false;
            
            obj.useDisplay = false;                        
            
     
            
       
        end
        
        function [] = setPrintIterations(obj, useDisplay)
            obj.useDisplay = useDisplay;            
        end
        
        function [parameters] = transformParameters(obj, parameters)
            parameters(obj.expParameterTransform) = exp(parameters(obj.expParameterTransform));
        end
        
        function [parameters] = unTransformParameters(obj, parameters)
            parameters(obj.expParameterTransform) = log(parameters(obj.expParameterTransform));
        end
        
        
        function set.maxNumOptiIterations(obj, val)
            obj.maxNumOptiIterations = val;
            obj.setOptions();
        end
        
        function [] = setIsMaximize(obj, isMaximize)
            obj.isMaximize = isMaximize;
        end
        
        function [] = setExpParameterTransform(obj, expParameterTransform)
            obj.expParameterTransform = expParameterTransform;
        end
        
        function [value, gradient, hessian] = objectiveFunction(obj, func, parametersOrig, varargin)
            
            if (size(parametersOrig,1) == 1)
                parametersOrig = parametersOrig';
            end
            parameters = obj.transformParameters(parametersOrig);
            
            if (nargout <= 1)
                value = func(parameters, varargin{:});
                if (obj.isMaximize)
                    value = - value;
                end
            elseif (nargout == 2)
                if obj.useGradient 
                    [value, gradient] = func(parameters, varargin{:});
                    if (obj.isMaximize)
                        value = - value;
                        gradient = -gradient;
                    end
                    if(any(obj.expParameterTransform))         
                        gradient(obj.expParameterTransform) = gradient(obj.expParameterTransform) .* parameters(obj.expParameterTransform);
                    end
                else
                    value = func(parameters, varargin{:});
                    epsilon = 10^-6;
                    gradient = zeros(obj.numParams, 1);
                    for i = 1:obj.numParams
                        parametersTemp = parametersOrig;
                        parametersTemp(i) = parametersOrig(i) + epsilon;
                        valueTemp1 = obj.objectiveFunction(func, parametersTemp, varargin{:});
                        
                        parametersTemp(i) = parametersOrig(i) - epsilon;                        
                        valueTemp2 = obj.objectiveFunction(func, parametersTemp, varargin{:});
                       
                       
                        gradient(i) = (valueTemp1 - valueTemp2) / (2 * epsilon);
                    end
                    if (obj.isMaximize)
                        value = - value;
                        gradient = -gradient;
                    end
                end
            else
                [value, gradient,hessian] = func(parameters, varargin{:});
                if (obj.isMaximize)
                    value = - value;
                    gradient = -gradient;
                    hessian = - hessian;
                end
                
                if(any(obj.expParameterTransform))
                    gradient(obj.expParameterTransform) = gradient(obj.expParameterTransform) .* parameters(obj.expParameterTransform);
                    assert(false, 'exp transform not implemented yet for hessian')
                end
            end    
            if (nargout > 1 && size(gradient,2) == 1 && obj.requiresRowGradient)
                gradient = gradient';
            end
        end
        
        function [] = initializeOptimizer(obj, f, x0)
            obj.setOptions();
                                 
            obj.isInitialized = true;
            
        end
        
        
        function [optimParameters, val, numIterations] = optimize(obj, func, transformedParameters)
            
            parameters = obj.unTransformParameters(transformedParameters);
            if (~obj.isInitialized)
                obj.initializeOptimizer(func, parameters);
            end

            [optimParameters, val, numIterations] = obj.optimizeInternal(func, parameters);
            optimParameters = obj.transformParameters(optimParameters);
        end
        
        function [] = setOptions(obj)
        end

    end
    
    methods(Abstract)
                
        % Input:
        %  - func: the anonymous objective function f(x)
        %  - params: parameter depending on the optimizer used
        % 
        % Output:
        %  - params: parameter depending on the optimizer used
        %  - val: Optimal Point determined by the optimizer
        %  - numIterations: Number of Iterations used by optimizer
        [params, val, numIterations] = optimizeInternal(obj, func, params);
        
        
    end
    
end

