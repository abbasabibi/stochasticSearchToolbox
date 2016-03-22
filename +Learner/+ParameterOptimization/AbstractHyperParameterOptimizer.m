classdef AbstractHyperParameterOptimizer < Learner.Learner
    %sets the bandwidth to a certain constant * the median of the distances
     properties
        initializedHyperParameters = false; 
        optimizer
        
        hyperParameterObject
        
        optimizationName;
        debugMessages = true;
        
        isMaximize = true;
        useGradient = false;
        initialHyperParameters = [];
    end
    
    properties(SetObservable,AbortSet)
        ReinitializeHyperParameters = true;
        HyperParametersMapToOptimize        
    end
        
    
    methods
        function obj = AbstractHyperParameterOptimizer(dataManager, hyperParameterObject, optimizationName, isMaximize)
            obj = obj@Learner.Learner();
            
            obj.hyperParameterObject = hyperParameterObject;            
            
            if (exist('isMaximize', 'var'))
                obj.isMaximize = isMaximize;
            end
            
            obj.linkProperty('ReinitializeHyperParameters', [optimizationName, 'ReinitializeHyperParameters',]);
 
            obj.optimizationName = optimizationName;
            obj.settings.setIfEmpty([obj.optimizationName, 'OptiAlgorithm'], 'NLOPT_LN_PRAXIS');

            obj.initializeOptimizer();
        end
        
        function [] = initObject(obj)
            %obj.initializeOptimizer();
        end
        
        
        function [] = initializeOptimizer(obj)
            obj.HyperParametersMapToOptimize = true(1, obj.hyperParameterObject.getNumHyperParameters());
            obj.linkProperty('HyperParametersMapToOptimize', ['ParameterMap', obj.optimizationName]);

            if (size(obj.HyperParametersMapToOptimize,2) > obj.hyperParameterObject.getNumHyperParameters())
                obj.HyperParametersMapToOptimize = obj.HyperParametersMapToOptimize(1:obj.hyperParameterObject.getNumHyperParameters());
            elseif  (size(obj.HyperParametersMapToOptimize,2) < obj.hyperParameterObject.getNumHyperParameters())                
                obj.HyperParametersMapToOptimize = [obj.HyperParametersMapToOptimize, true(obj.hyperParameterObject.getNumHyperParameters() - length(obj.HyperParametersMapToOptimize))];
            end
            
            paramMin = obj.getMinParameterRange();
            paramMax = obj.getMaxParameterRange();                         
                        
%             switch obj.HyperParametersOptimizer
%                 case 'CMAES'
%                     obj.optimizer = Optimizer.CMAOptimizer(obj.getNumParametersToOptimize(), paramMin, paramMax, obj.optimizationName);
%                 case 'ConstrainedCMAES'
%                     obj.optimizer = Optimizer.ConstrainedCMAOptimizer(obj.getNumParametersToOptimize(), paramMin, paramMax, obj.optimizationName);
%                 case 'FMINUNC'
%                     obj.optimizer = Optimizer.FMinUnc(obj.getNumParametersToOptimize(), false, false);
%                     
%                 otherwise
%                     assert(false, ['Unknown optimizer for GP Hyperparameters, ', obj.GPHyperParametersOptimizer]);
%             end
            obj.optimizer = Optimizer.OptimizerFactory.createOptimizer(obj.hyperParameterObject.getNumHyperParameters(),  obj.optimizationName, paramMin, paramMax);
            obj.optimizer.useGradient = obj.useGradient;
            
            expParameterTransformMap = obj.hyperParameterObject.getExpParameterTransformMap();
            assert(~isempty(expParameterTransformMap), 'HyperparameterObject not properly initialized. Did you use initHyperParams in the constructor?');
            expParameterTransformMap = expParameterTransformMap(obj.HyperParametersMapToOptimize);
            obj.optimizer.setExpParameterTransform(expParameterTransformMap);            
                
            obj.optimizer.setIsMaximize(obj.isMaximize);
            
            if (obj.debugMessages)
                obj.optimizer.setPrintIterations(true);
            end
        end                
        
        function obj = updateModel(obj, data)             
            obj.processTrainingData(data);
            if (~ obj.initializedHyperParameters || obj.ReinitializeHyperParameters)
                if not(isempty(obj.initialHyperParameters))
                    obj.hyperParameterObject.setHyperParameters(obj.initialHyperParameters);
                end
                obj.initializeParameters(data);
                obj.initialHyperParameters = obj.hyperParameterObject.getHyperParameters();
                obj.initializedHyperParameters  = true;
            end
            obj.optimizeHyperParameters(data);            
        end
        
        function obj = optimizeHyperParameters(obj, data)                 
           
           
            if (isempty(obj.optimizer))
                obj.initializeOptimizer();
            end
           
            obj.beforeOptimizationHook();
            parameters = obj.optimizer.optimize(@(params_) obj.objectiveFunctionWrapper(params_), obj.getParametersToOptimize());
            obj.afterOptimizationHook();
            
            obj.setParametersToOptimize(parameters);  
            obj.learnFinalModel(data);
        end 
        
        function varargout = objectiveFunctionWrapper(obj, params)
            allParams = obj.hyperParameterObject.getHyperParameters();
            allParams(obj.HyperParametersMapToOptimize) = params;
            
            [varargout{1:nargout}] = obj.objectiveFunction(allParams);
        end
        
        function [] = beforeOptimizationHook(obj)
        end
        
        function [] = afterOptimizationHook(obj)
        end
        
        
        function [] = setParametersToOptimize(obj, parameters)
            assert(all(isreal(parameters)));
            parametersAll = obj.hyperParameterObject.getHyperParameters();
            parametersAll(obj.HyperParametersMapToOptimize) = parameters;
            obj.hyperParameterObject.setHyperParameters(parametersAll);
        end
        
        function [params] = getMinParameterRange(obj)
            params = obj.hyperParameterObject.getMinHyperParameterRange();
            params = params(obj.HyperParametersMapToOptimize);
        end
        
        function [params] = getMaxParameterRange(obj)
            params = obj.hyperParameterObject.getMaxHyperParameterRange();
            params = params(obj.HyperParametersMapToOptimize);
        end
        
        function [parameters] = getParametersToOptimize(obj)
            parametersAll = obj.hyperParameterObject.getHyperParameters();
            parameters = parametersAll(obj.HyperParametersMapToOptimize);
        end

        
        function [numParams] = getNumParametersToOptimize(obj)
            numParams = sum(obj.HyperParametersMapToOptimize);
        end
            
    end
    
    methods (Abstract)
        [] = processTrainingData(obj, data);
        
        [] = initializeParameters(obj, data);      
      
        [funcVal, gradient] = objectiveFunction(obj, params);
        
        [] = learnFinalModel(obj);
    end
    
end

