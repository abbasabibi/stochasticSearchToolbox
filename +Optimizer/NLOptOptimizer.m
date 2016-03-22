classdef NLOptOptimizer  < Optimizer.BoxConstrained;
    %NLOPTOPTIMIZER Handels all NLopt Gradient Based Algorithms
    %   Overview of all NLopt_Algorithms
    %   http://ab-initio.mit.edu/wiki/index.php/NLopt_Algorithms#Local_gradient-based_optimizations
    
    properties 
        algorithmMap
    end
    
    properties (SetObservable, AbortSet)
        OptiAlgorithm = 'NLOPT_LD_LBFGS';
        fRelTol = 0.0001;
    end
    
    methods
        
        function obj = NLOptOptimizer(numParams, lowerBound, upperBound, name)
            
            obj = obj@Optimizer.BoxConstrained(numParams, lowerBound, upperBound, name);
            obj.linkProperty('OptiAlgorithm',[name,'OptiAlgorithm']);

            % derivativeFree Algorithms (global)
            obj.algorithmMap.NLOPT_GN_DIRECT_L.gradientFree = true;
            obj.algorithmMap.NLOPT_GN_DIRECT_L.global = true;
            obj.algorithmMap.NLOPT_GLOBAL_DIRECT_L_RAND.gradientFree = true;
            obj.algorithmMap.NLOPT_GLOBAL_DIRECT_L_RAND.global = true;
            obj.algorithmMap.NLOPT_GN_CRS2_LM.gradientFree = true;
            obj.algorithmMap.NLOPT_GN_CRS2_LM.global = true;
            obj.algorithmMap.NLOPT_G_MLSL_LDS.gradientFree = false;
            obj.algorithmMap.NLOPT_G_MLSL_LDS.global = true;
            obj.algorithmMap.NLOPT_G_MLSL.gradientFree = false;
            obj.algorithmMap.NLOPT_G_MLSL.global = true;
            obj.algorithmMap.NLOPT_GN_ISRES.gradientFree = true;
            obj.algorithmMap.NLOPT_GN_ISRES.global = true;
            obj.algorithmMap.NLOPT_GN_ESCH.gradientFree = true;
            obj.algorithmMap.NLOPT_GN_ESCH.global = true;
            
            % derivativeFree Algorithms (local)
            obj.algorithmMap.NLOPT_LN_COBYLA.gradientFree = true;
            obj.algorithmMap.NLOPT_LN_COBYLA.global = false;
            obj.algorithmMap.NLOPT_LN_BOBYQA.gradientFree = true;
            obj.algorithmMap.NLOPT_LN_BOBYQA.global = false;
            obj.algorithmMap.NLOPT_LN_NEWUOA.gradientFree = true;
            obj.algorithmMap.NLOPT_LN_NEWUOA.global = false;
            obj.algorithmMap.NLOPT_LN_NEWUOA_BOUND.gradientFree = true;
            obj.algorithmMap.NLOPT_LN_NEWUOA_BOUND.global = false;
            obj.algorithmMap.NLOPT_LN_PRAXIS.gradientFree = true;
            obj.algorithmMap.NLOPT_LN_PRAXIS.global = false;
            obj.algorithmMap.NLOPT_LN_NELDERMEAD.gradientFree = true;
            obj.algorithmMap.NLOPT_LN_NELDERMEAD.global = false;
            obj.algorithmMap.NLOPT_LN_SBPLX.gradientFree = true;
            obj.algorithmMap.NLOPT_LN_SBPLX.global = false;
             
             % gradient-based Algorithms (local)
            obj.algorithmMap.NLOPT_LD_MMA.gradientFree = false;
            obj.algorithmMap.NLOPT_LD_MMA.global = false;
            obj.algorithmMap.NLOPT_LD_SLSQP.gradientFree = false;
            obj.algorithmMap.NLOPT_LD_SLSQP.global = false;
            obj.algorithmMap.NLOPT_LD_LBFGS.gradientFree = false;
            obj.algorithmMap.NLOPT_LD_LBFGS.global = false;
            obj.algorithmMap.NLOPT_LD_TNEWTON_PRECOND_RESTART.gradientFree = false;
            obj.algorithmMap.NLOPT_LD_TNEWTON_PRECOND_RESTART.global = false;
            obj.algorithmMap.NLOPT_LD_TNEWTON_PRECOND.gradientFree = false;
            obj.algorithmMap.NLOPT_LD_TNEWTON_PRECOND.global = false;
            obj.algorithmMap.NLOPT_LD_TNEWTON.gradientFree = false;
            obj.algorithmMap.NLOPT_LD_TNEWTON.global = false;
            obj.algorithmMap.NLOPT_LD_VAR2.gradientFree = false;
            obj.algorithmMap.NLOPT_LD_VAR2.global = false;
            obj.algorithmMap.NLOPT_LD_VAR1.gradientFree = false;
            obj.algorithmMap.NLOPT_LD_VAR1.global = false;
            
            obj.linkProperty('fRelTol', [obj.optimizationName, 'OptiRelfTol']);
            obj.requiresRowGradient = true;
            addpath('./NLopt');
             
        end
        
        function [params, val, data] = optimizeInternal(obj, func, x0)
            
            if (isfield(obj.algorithmMap, obj.OptiAlgorithm))
                try
                    opt.algorithm = eval(obj.OptiAlgorithm);
                catch
                    addpath('./NLopt');
                    opt.algorithm = eval(obj.OptiAlgorithm);
                end
            else
                error('unknown NL-opt algorithm: %s',obj.OptiAlgorithm);
            end
            
            if (~obj.algorithmMap.(obj.OptiAlgorithm).gradientFree && ~obj.useGradient)
                %error('Error: no gradient specified but NL-Opt Algorithm %s requires gradients', obj.OptiAlgorithm);
            end
            
            % reshape starting vector
            % remember size
            paramsize = size(x0);
            x0 = reshape(x0,1,[]);
            
            % transform x to expected size
            t = @(params_) obj.objectiveFunction(func, params_);
           
            opt.min_objective = t;
            % set parameter
            % print
            opt.verbose = 0;%obj.useDisplay;
            
            %upper Bound
            opt.upper_bounds = obj.getUpperBoundTransformed()';
            
            % lower Bound
            opt.lower_bounds = obj.getLowerBoundTransformed()';
            
            
            % ftol
            if~(isempty(obj.OptiAbsfTol))
                opt.ftol_abs = obj.OptiAbsfTol;
            end
            
            if~(isempty(obj.fRelTol))
                opt.ftol_rel = obj.fRelTol;
            end
            
            
            % xtol
            if~(isempty(obj.OptiAbsxTol))
                opt.xtol_abs = obj.OptiAbsxTol * ones(obj.numParams, 1);
            end
            
            % MaxIter
            if~(isempty(obj.maxNumOptiIterations))
                opt.maxeval = obj.maxNumOptiIterations;
            end
            
            % OptiMaxTime
            if~(isempty(obj.OptiMaxTime))
                opt.maxtime = obj.OptiMaxTime;
            end
            
            % OptiStopVal
            if~(isempty(obj.OptiStopVal))
                opt.stopval = obj.OptiStopVal;
            end
            
            if (obj.useDisplay)
                opt.verbose = 1;
            end
            % call optimizer
            % here data= 0 if failure
            if (opt.maxeval > 0)
            
                x0(x0 < opt.lower_bounds') = opt.lower_bounds(x0 < opt.lower_bounds');
                x0(x0 > opt.upper_bounds') = opt.upper_bounds(x0 > opt.upper_bounds');
                

                if ispc
                    [params, val, data] = NLopt_optimize(opt, x0');
                else
                    [params, val, data] = nlopt_optimize(opt, x0');
                end
                if data<0
                    if data==-2
                        error(strcat(obj.optimizationName,' called with invalid arguments'));
                    else
                        warning(strcat(obj.optimizationName,' returned ',int2str(data)));
                    end
                end
            else
                params = x0';
                val = [];
                data = [];
            end
            obj.returnCode = data;
            % reshape params
            params = reshape(params,paramsize);
            
        end
        
        
    end
    
end

