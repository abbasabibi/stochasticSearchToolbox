classdef CMAOptimizer < Optimizer.BoxConstrained;
    
    properties
        
        p_sigma = 0;
        p_c = 0;
        sigma = 0;
        
        mu = 0;
        w = [];
        ueff = 0;
        cc = 0;
        ccov = 0;
        
        chi_n = 0;
        
        c_sigma = 0;
        d_sigma = 0;
        
        numSamplesCMA;
        
        meanParam;
        covParam;
        
        perfCurve
    end
    
    properties (SetObservable, AbortSet)
       CMAOptimizerInitialRange = 0.0001;    
       CMANumRestarts = 1;
       
       CMAUsePlot = false;
    end
    
    methods
        function obj = CMAOptimizer(numParams, lowerBound, upperBound, varargin)
            
            
            obj = obj@Optimizer.BoxConstrained(numParams, lowerBound, upperBound, varargin{:});
            %obj.lambda      = round(4 + 3 * log(numParams));

            obj.linkProperty('CMAOptimizerInitialRange', ['CMAOptimizerInitialRange', obj.optimizationName]);
            obj.linkProperty('CMANumRestarts', ['CMANumRestarts', obj.optimizationName]);
            obj.linkProperty('CMAUsePlot', ['CMAUsePlot', obj.optimizationName]);
            
            assert(~any(isinf(lowerBound)) && ~any(isinf(upperBound)));

            obj.linkProperty('lambda');

            obj.initOptimization();
        end
        
        function [] = initOptimization(obj)
            dimParam = obj.numParams;
            
            obj.p_sigma     = zeros(1, dimParam);
            obj.p_c         = zeros(1, dimParam);
            
            
            obj.mu          = round(obj.lambda / 2);
            obj.w = zeros(obj.mu,1);
            for l = 1:obj.mu
                obj.w(l) = log(obj.mu + 1) - log(l);
            end
            
            obj.w       = obj.w / sum(obj.w);
            obj.ueff    = sum(obj.w.^2)^-1;
            obj.cc      = 4 / (dimParam + 4);
            obj.ccov    = 2 / (dimParam + sqrt(2))^2;
            
            obj.chi_n   = sqrt(2) * exp(gammaln((dimParam + 1) /2) - gammaln(dimParam/2));
            
            obj.c_sigma = (obj.ueff + 2) / (dimParam + obj.ueff  + 3);
            obj.d_sigma = 1 + 2 * max([0, sqrt((obj.ueff - 1)/(dimParam-1))]) + obj.c_sigma;
            
            obj.sigma = 1;
            
            obj.numSamplesCMA = obj.lambda;
            
            upperBoundTr = obj.getUpperBoundTransformed();
            lowerBoundTr = obj.getLowerBoundTransformed();
            
            obj.meanParam = (lowerBoundTr + upperBoundTr) / 2;
            obj.covParam = (diag((upperBoundTr - lowerBoundTr)) .* obj.CMAOptimizerInitialRange).^2;
            
            assert(~any(isinf(obj.meanParam)) && ~any(isinf(obj.covParam(:))));
        end
        
        function [muCMA, nextCovMat] = computeNewMeanAndVariance(obj, MuA, SigmaA, rewards, parameters)
            [~, sortInd] = sort(rewards, 'ascend');
            
            if (size(MuA,2) > 1)
                MuA = MuA';
            end
            
            muCMA = zeros(1, size(MuA,1));
            for l = 1:obj.mu
                index = sortInd(l);
                muCMA = muCMA + obj.w(l) * parameters(index, :);
            end
            
            obj.p_c     = (1 - obj.cc) * obj.p_c + sqrt(obj.cc * (2-obj.cc) * obj.ueff) *(muCMA - MuA') / obj.sigma;
            
            currCovMat = SigmaA /  obj.sigma^2;
            nextCovMat = (1 - obj.ccov) * currCovMat + obj.ccov * (1 / obj.ueff * obj.p_c' * obj.p_c);
            
            sigma2 = obj.sigma^2;
            
            
            actionDev = bsxfun(@minus, parameters(sortInd(1:obj.mu), :), MuA');
            actionDevW =  bsxfun(@times, actionDev, obj.ccov * (1 - 1 / obj.ueff) * obj.w(1:obj.mu) / sigma2);
            nextCovMat = nextCovMat + actionDevW' * actionDev;
            nextCovMat = (nextCovMat + nextCovMat') / 2;
            
            [B,D] = eig(currCovMat);
            
            obj.p_sigma = (1 - obj.c_sigma) * obj.p_sigma + (sqrt(obj.c_sigma * (2 - obj.c_sigma) * obj.ueff) *(B * diag(diag(D) .^ (-0.5)) * B') * (muCMA - MuA')' / obj.sigma)';
            obj.sigma   = obj.sigma * exp(obj.c_sigma/obj.d_sigma * (norm(obj.p_sigma) / obj.chi_n - 1));
            
            nextCovMat = obj.sigma^2 * nextCovMat;
        end
        
        function [] = setOptions(obj)
            obj.initOptimization();
        end
              
        
        function [optimParams, val, numIterations] = optimizeInternal(obj, func, params)
            initParams = params;
            
            optimVal = inf;
            optimParams = initParams;
            for i = 1:obj.CMANumRestarts
                obj.initOptimization();
                objective = @(params_) obj.objectiveFunction(func, params_);
                [params, val, numIterations] = obj.continueOptimization(objective, initParams);
                
                if (val < optimVal)
                    optimParams = params;
                end
            end
        end
        
        function [params, val, numIterations] = continueOptimization(obj, func, params)
            if (obj.maxNumOptiIterations == 0)
                numIterations = 0;
                val = func(params);
                return;
            end

            if (size(params,2) == 1)
                params = params';
            end
            
            if (obj.CMAUsePlot)
                figure(123);
                clf;
            end
            
            obj.meanParam = params;
            obj.perfCurve = zeros(obj.maxNumOptiIterations, 1);
            performance = zeros(obj.numSamplesCMA, 1);
            minPerf = inf;
            for i = 1:obj.maxNumOptiIterations
                parameters = bsxfun(@plus, obj.meanParam, randn(obj.numSamplesCMA, size(obj.meanParam,2)) * chol(obj.covParam));
                for j = 1:obj.numSamplesCMA
                    performance(j) = func(parameters(j,:));
                    if (obj.CMAUsePlot)
                        nParam = size(parameters,2);
                        rows = .75 * sqrt(nParam);
                        cols = ceil(16/9 * rows);
                        rows = ceil(rows);
                        for pi = 1:size(parameters,2)
                            subplot(rows,cols,pi);
                            hold on;
    %                         if log(performance(j)) < 0
                                plot(parameters(j,pi),performance(j) * log(abs(performance(j))),'*');
    %                         else
    %                             plot(parameters(j,pi),0,'*r');
    %                         end
                        end
                    end
                end
                
                obj.perfCurve(i) = mean(performance);
                
                if (obj.useDisplay)
                    fprintf('CMA-ES Iteration %d: %f\n', i, obj.perfCurve(i));
                    drawnow
                end
                
%                 [min_perf, min_ind] = min(performance);
%                 if min_perf < min_performance
%                     min_performance = min_perf;
%                     min_parameters = parameters(min_ind, :);
%                 end
                
                [obj.meanParam, obj.covParam] = obj.computeNewMeanAndVariance(obj.meanParam, obj.covParam, performance, parameters);
                % check for f-tolerance
                if (i > 20 && obj.OptiAbsfTol >= 0)
                    minPerf20 = min(obj.perfCurve(1:i - 20));
                    minPerfNow = min(obj.perfCurve(i - 19:i));
                    if (minPerfNow > minPerf20 - obj.OptiAbsfTol)
                        % no significant progress for the last 10
                        if (obj.useDisplay)
                            fprintf('no significant progress for the last 10 iteration, quitting optimization\n');
                        end
                        break;
                    end                    
                end
            end
%             obj.perfCurve(end + 1) = mean(performance);
            obj.perfCurve(end + 1) = func(obj.meanParam);
            val = obj.perfCurve(end);
            numIterations = obj.maxNumOptiIterations;
            
            params = obj.meanParam;
            
%             [val, ind] = min(performance);
%             params = min_parameters;
%             val = min_performance;

        end    
    end    
end

