classdef BayesPreferenceSolverCompact
    %BAYESPREFERENCESOLVER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        shapeM = 1;
        cholPrior;
        sampleCount = 100000;
        use01LL = true;
    end
    
    methods
        function obj = BayesPreferenceSolverCompact(cholPrior,sampleCount,shapeM,use01LL)
            obj.cholPrior = cholPrior;
            obj.shapeM = shapeM;
            obj.sampleCount = sampleCount;
            obj.use01LL=use01LL;
        end
        
        function p = dataLogLL(obj,theta,dif,trajs,importance)
            realTheta = theta*trajs;
            difValues = realTheta*(dif)';
            if sum(difValues~=0) > 0
                difValues = difValues ./max(abs(difValues));
            end
            
            sigmoidDif = 1 ./ (1+exp(-obj.shapeM*difValues));
            zeroOneDif = difValues>0;
            prefs = size(dif,1)+1;
            

            %importance = arrayfun(@(idx) norm(dif(idx,:),1),1:size(dif,1));
            if obj.use01LL
                p = sum(importance' .* log(zeroOneDif*((prefs-1)/prefs)+sigmoidDif*(1/prefs)));
            else
                p = sum(importance' .* sigmoidDif);
            end
        end
        
        function logL = getLogLL(obj,theta,pref,dom,importance)                                    
            importance = importance ./ (norm(importance,1));
            
            dif = pref-dom;
            logL = dataLogLL(obj,theta,dif,importance);
        end
        
        function [theta, logL] = solve(obj,thetaI,pref,dom,trajs,importance)                                    
            theta = zeros(obj.sampleCount,size(obj.cholPrior,1));
            logL = zeros(obj.sampleCount,1);

            logLI = [];

            importance = importance ./ (norm(importance,1));
            
            dif = pref-dom;
            
            %dif = dif./max(max(abs(dif)*size(obj.cholPrior,1)));
            
            for i=1:obj.sampleCount
                [thetaI, logLI] = obj.elliptical_slice(thetaI, obj.cholPrior, @obj.dataLogLL, logLI, [], dif, trajs, importance);
                theta(i,:) = thetaI;
                logL(i,:) = logLI;
            end
        end
        
        function [xx, cur_log_like] = elliptical_slice(obj, xx, prior, log_like_fn, cur_log_like, angle_range, varargin)
            %ELLIPTICAL_SLICE Markov chain update for a distribution with a Gaussian "prior" factored out
            %
            %     [xx, cur_log_like] = elliptical_slice(xx, chol_Sigma, log_like_fn);
            % OR
            %     [xx, cur_log_like] = elliptical_slice(xx, prior_sample, log_like_fn);
            %
            % Optional additional arguments: cur_log_like, angle_range, varargin (see below).
            %
            % A Markov chain update is applied to the D-element array xx leaving a
            % "posterior" distribution
            %     P(xx) \propto N(xx;0,Sigma) L(xx)
            % invariant. Where N(0,Sigma) is a zero-mean Gaussian distribution with
            % covariance Sigma. Often L is a likelihood function in an inference problem.
            %
            % Inputs:
            %              xx Dx1 initial vector (can be any array with D elements)
            %
            %      chol_Sigma DxD chol(Sigma). Sigma is the prior covariance of xx
            %  or:
            %    prior_sample Dx1 single sample from N(0, Sigma)
            %
            %     log_like_fn @fn log_like_fn(xx, varargin{:}) returns 1x1 log likelihood
            %
            % Optional inputs:
            %    cur_log_like 1x1 log_like_fn(xx, varargin{:}) of initial vector.
            %                     You can omit this argument or pass [].
            %     angle_range 1x1 Default 0: explore whole ellipse with break point at
            %                     first rejection. Set in (0,2*pi] to explore a bracket of
            %                     the specified width centred uniformly at random.
            %                     You can omit this argument or pass [].
            %        varargin  -  any additional arguments are passed to log_like_fn
            %
            % Outputs:
            %              xx Dx1 (size matches input) perturbed vector
            %    cur_log_like 1x1 log_like_fn(xx, varargin{:}) of final vector
            
            % Iain Murray, September 2009
            % Tweak to interface and documentation, September 2010
            
            % Reference:
            % Elliptical slice sampling
            % Iain Murray, Ryan Prescott Adams and David J.C. MacKay.
            % The Proceedings of the 13th International Conference on Artificial
            % Intelligence and Statistics (AISTATS), JMLR W&CP 9:541-548, 2010.
            
            D = numel(xx);
            if (nargin < 5) || isempty(cur_log_like)
                cur_log_like = log_like_fn(xx, varargin{:});
            end
            if (nargin < 6) || isempty(angle_range)
                angle_range = 0;
            end
            
            % Set up the ellipse and the slice threshold
            if numel(prior) == D
                % User provided a prior sample:
                nu = reshape(prior, size(xx));
            else
                % User specified Cholesky of prior covariance:
                if ~isequal(size(prior), [D D])
                    error('Prior must be given by a D-element sample or DxD chol(Sigma)');
                end
                nu = reshape(prior'*randn(D, 1), size(xx));
            end
            hh = log(rand) + cur_log_like;
            
            % Set up a bracket of angles and pick a first proposal.
            % "phi = (theta'-theta)" is a change in angle.
            if angle_range <= 0
                % Bracket whole ellipse with both edges at first proposed point
                phi = rand*2*pi;
                phi_min = phi - 2*pi;
                phi_max = phi;
            else
                % Randomly center bracket on current point
                phi_min = -angle_range*rand;
                phi_max = phi_min + angle_range;
                phi = rand*(phi_max - phi_min) + phi_min;
            end
            
            % Slice sampling loop
            while true
                % Compute xx for proposed angle difference and check if it's on the slice
                xx_prop = xx*cos(phi) + nu*sin(phi);
                cur_log_like = log_like_fn(xx_prop, varargin{:});
                if cur_log_like > hh
                    % New point is on slice, ** EXIT LOOP **
                    break;
                end
                % Shrink slice to rejected point
                if phi > 0
                    phi_max = phi;
                elseif phi < 0
                    phi_min = phi;
                else
                    error('BUG DETECTED: Shrunk to current position and still not acceptable.');
                end
                % Propose new angle difference
                phi = rand*(phi_max - phi_min) + phi_min;
            end
            xx = xx_prop;
        end
    end
    
end

