classdef ShrunkLinearGaussianMLLearner2 < Learner.SupervisedLearner.LinearFeatureFunctionMLLearner
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
        varianceTarget;
             %CMA Parameters
        p_sigma = 0;
        p_c = 0;
        sigma = 0;
        
        
        chi_n = 0;
        
        c_sigma = 0;
        d_sigma = 0;
        
        LMU;
        CMU;

    end
    
    properties (SetObservable,AbortSet)
        
        shrinkvar = 0;
        getvarianceTarget = false;

    end
    
    methods
        
        function obj = ShrunkLinearGaussianMLLearner2(dataManager, linearfunctionApproximator, varargin)
            
            obj = obj@Learner.SupervisedLearner.LinearFeatureFunctionMLLearner(dataManager, linearfunctionApproximator, varargin{:});
            obj.linkProperty('shrinkvar');
            obj.linkProperty('getvarianceTarget');
            obj.initCMApara();
            
        end
        
       function [] = initCMApara(obj)
            
            dimParam = obj.getDataManager.getNumDimensions(obj.outputVariable);
            
            obj.p_sigma     = zeros(1, dimParam);
            obj.p_c         = zeros(1, dimParam);
            
            obj.chi_n   = sqrt(2) * exp(gammaln((dimParam + 1) /2) - gammaln(dimParam/2));
            
            obj.sigma = 1;
            
        end

        
        function [] =computeCMAsigma(obj,weights)
            
            dimParam = obj.getDataManager.getNumDimensions(obj.outputVariable);
            ueff = sum(weights.^2)^-1;
            
            obj.c_sigma = (ueff + 2) / (dimParam + ueff  + 3);
            obj.d_sigma = 1 + 2 * max([0, sqrt((ueff - 1)/(dimParam-1))]) + obj.c_sigma;
            
            SigmaA =obj.functionApproximator.getCovariance;
            currCovMat = SigmaA /  obj.sigma^2;
            
            sigma2 = obj.sigma^2;
           
            [B,D] = eig(currCovMat);
            
            obj.p_sigma = (1 - obj.c_sigma) * obj.p_sigma + (sqrt(obj.c_sigma * (2 - obj.c_sigma) * ueff) *(B * diag(diag(D) .^ (-0.5)) * B') * (obj.LMU - obj.CMU)' / obj.sigma)';
            obj.sigma   = obj.sigma * exp(obj.c_sigma/obj.d_sigma * (norm(obj.p_sigma) / obj.chi_n - 1));
            
            
            
        end
        
        function [] = learnFunction(obj, inputData, outputData, weighting)
            
            if (~exist('weighting', 'var'))
                weighting = ones(size(inputData,1),1);
            end
            
            %obj.learnFunction@Learner.SupervisedLearner.LinearFeatureFunctionMLLearner(inputData, outputData, weighting);
            
            oldMean = mean(obj.functionApproximator.getExpectation(size(inputData,1), inputData));
            
            obj.LMU = oldMean; 
            obj.learnFunction@Learner.SupervisedLearner.LinearFeatureFunctionMLLearner(inputData, outputData, weighting);
            newMean = mean(obj.functionApproximator.getExpectation(size(inputData,1), inputData));
            obj.CMU= newMean;
            
            oldCov =obj.functionApproximator.getCovariance;
            trueEntropyBefore = 1/2*(log(((2*pi*exp(1))^size(outputData,2)) * det(oldCov))/log(exp(1)))

            sumW    = sum(weighting);
            weighting = weighting / sumW;
            
            biasTerm = ( sum(weighting)^2 - sum(weighting.^2));
            priorCov = 1.0;
            priorCovWeight = 10^-16;
            rangeOutput = obj.dataManager.getRange(obj.functionApproximator.outputVariable);
            
            if(biasTerm > 0 )
                
                %expectedOutput = obj.functionApproximator.getExpectation(size(inputData,1), inputData);
                %difference =  expectedOutput - outputData;
                
                SigmaA = obj.covWeightedShrinkKPM(inputData,outputData,weighting);
                
                cholA = chol(SigmaA);
                obj.functionApproximator.setSigma(cholA);
                newCov = obj.functionApproximator.getCovariance;
                
                KL = 1/2 *(trace(oldCov \ newCov ) + (newMean-oldMean)*(oldCov \ (newMean-oldMean)') ...
                    -size(outputData,2) +  sum(log(eig(oldCov))) - sum(log(eig(newCov))))
                trueEntropy = 1/2*(log(((2*pi*exp(1))^size(outputData,2)) * det(newCov))/log(exp(1)))

                
                n = size(outputData,2);
                N = 20;
                Sigma = newCov;
                mu = newMean;
                r = mvnrnd(mu,Sigma,N);
                p = mvnpdf(r,mu,Sigma);
                logP = log(p)./log(exp(1));
                estimatedEntropy = -1*((1/N) * sum(logP))
              
            else
                
                SigmaA = diag(rangeOutput) * priorCov * priorCovWeight / (1 + priorCovWeight);
                obj.functionApproximator.setCovariance(SigmaA);
                
            end
            
            
        end
        
        
        function [s] = covWeightedShrinkKPM(obj,inputData,x,weights)
            % Shrinkage estimate of a covariance matrix, using optimal shrinkage coefficient.
            % INPUT:
            % x is n*p data matrix
            % shrinkvar : if 1, shrinks the diagonal variance terms, default is 0
            %
            % OUTPUT:
            % s is the posdef p*p cov matrix
            % lamcor is the shrinkage coefficient for the correlation matrix
            % lamvar is the shrinkage coefficient for the variances
            %
            % See  J. Schaefer and K. Strimmer.  2005.  A shrinkage approach to
            %   large-scale covariance matrix estimation and implications
            %   for functional genomics. Statist. Appl. Genet. Mol. Biol. 4:32.
            % This code is based on their original code http://strimmerlab.org/software.html
            % but has been vectorized and simplified by Kevin Murphy.
            
            
            [n p] = size(x);
            
            if p==1, s=obj.clcVar(inputData,x,weights); return; end
            
            if obj.shrinkvar
                [v, lamvar] = obj.varshrink(inputData,x,weights);
            else
                v = obj.clcVar(inputData,x,weights);
                lamvar = 0;
            end
            
            dsv = diag(sqrt(v));
            [r, lamcor] = obj.corshrink(inputData,x,weights);
            %r(logical(eye(p))) = v;
            %s=r;
            s = dsv*r*dsv;
            
            %s=obj.covShrink(inputData,x,weights);
        end
        
        
        
        function [sv, lambda] = varshrink (obj,inputData,x,weights)
            % Eqns 10 and 11 of Opgen-Rhein and Strimmer (2007)
            
            %             [v, vv] = obj.varcov(x,weights);
            %             v = diag(v); vv = diag(vv);
            %
            %             if(obj.getvarianceTarget)
            %
            %                 vtarget = diag(obj.functionApproximator.getCovariance);
            %
            %             else
            %
            %                 vtarget = mean(diag(v));
            %
            %             end
            %             numerator = sum(vv);
            %             denominator = sum((v-vtarget).^2);
            %             lambda = numerator/denominator;
            %             lambda = min(lambda, 1); lambda = max(lambda, 0);
            %             sv = (1-lambda)*v + lambda*vtarget;
            [n, p] = size(x);
            minTerm = 1;
            [v, vv] = obj.varcov(inputData,x,weights);
            v = diag(v); vv = diag(vv);
            numParameters = length(v);
            
            if(obj.getvarianceTarget)
                
                vtarget = diag(obj.functionApproximator.getCovariance);
                %numEffSamples = 1/sum(weights.^2);
                %computeCMAsigma(obj,weights);
                %minTerm = obj.sigma; 
            else
                
                vtarget = median(v);
                
            end
        
            %vtarget = mean(v);
            numerator = sum(vv);
            denominator = sum((v-vtarget).^2);
            lambda = numerator/denominator;
            effsampes = (1/sum(weights.^2));
            lambda = min(lambda, (1-(effsampes/(p^2)))); lambda = max(lambda, 0);
            
            %lambda = minTerm;
            sv = (1-lambda)*v + lambda*vtarget;
            
        end
        
        function [cov] = covShrink(obj,inputData,x,weights)
            
            
            [n, p] = size(x);
            
            [r, vr] = obj.varcov(inputData,x,weights);
            shrinkageTarget = obj.functionApproximator.getCovariance;
            %%%
            %varTarget = mean(diag(r));
            offdiagsumrij2 = sum(sum((tril(r,0)-tril(shrinkageTarget,0)).^2));
            %offdiagsumrij2 = offdiagsumrij2 +sum((diag(r)-varTarget).^2);
            offdiagsumvrij = sum(sum(tril(vr,0)));
            lambda = offdiagsumvrij/offdiagsumrij2;
            lambda = min(lambda, 1); lambda = max(lambda, 0)
            cov = (1-lambda)*r +(lambda)*shrinkageTarget;
            %%
        end
        
        function [Rhat, lambda] = corshrink(obj,inputData,x,weights)
            % Eqn on p4 of Schafer and Strimmer 2005
            [n, p] = size(x);
            effsampes = (1/sum(weights.^2));
            [r, vr] = obj.varcor(inputData,x,weights);
            offdiagsumrij2 = sum(sum(tril(r,-1).^2));
            offdiagsumvrij = sum(sum(tril(vr,-1)));
            lambda = offdiagsumvrij/offdiagsumrij2;
            lambda = min(lambda, (1-(effsampes/(p^2)))); lambda = max(lambda, 0);
            %lambda = (1-(effsampes/(p^2)))
            Rhat = (1-lambda)*r;
            Rhat(logical(eye(p))) = 1;
        end
        
        function [S, VS] = varcor(obj,inputData,x,weights)
            % s(i,j) = cov X(i,j)
            % vs(i,j) = est var s(i,j)
            
            [n,p] = size(x);
            xc = obj.makeMeanZero(inputData,x,weights);
            xc = obj.makeStdOne(inputData,xc,weights); % convert S to R
            
            R = bsxfun(@times, xc, weights)' * xc;
            S = (1 / (1-sum(weights.^2))) * R;
            %S = cov(xc);
            
            XC1 = repmat(reshape(xc', [p 1 n]), [1 p 1]); % size p*p*n !
            XC2 = repmat(reshape(xc', [1 p n]),  [p 1 1]); % size p*p*n !
            XC12 = XC1 .* XC2;
            
            R3d = repmat(R,[1,1,n]);
            b = ones(1,1,n);
            b(1,1,:) = weights;
            W3d = repmat(b,[p,p,1]);
            
            VS = (XC12 - R3d).^2;
            VS =VS .* W3d;
            VS = sum(VS,3);
            coff = sum(weights.^2)/((1-sum(weights.^2))^3);
            VS = VS * coff;
            
            %             VS = (n/((n-1)^3)).* sum(VS,3);
            %             S = obj.sampleCor(inputData,x,weights);
            %             XC1 = repmat(reshape(x', [p 1 n]), [1 p 1]); % size p*p*n !
            %             XC2 = repmat(reshape(x', [1 p n]),  [p 1 1]); % size p*p*n !
            %             Variance = var(XC1 .* XC2, weights,  3) ;
            
        end
        
        function [S, VS] = varcov(obj,inputData,x,weights)
            
            [n,p] = size(x);
            xc = obj.makeMeanZero(inputData,x,weights);
            %xc = obj.makeStdOne(inputData,xc,weights); % convert S to R
            
            R = bsxfun(@times, xc, weights)' * xc;
            S = (1 / (1-sum(weights.^2))) * R;
            %S = cov(xc);
            
            XC1 = repmat(reshape(xc', [p 1 n]), [1 p 1]); % size p*p*n !
            XC2 = repmat(reshape(xc', [1 p n]),  [p 1 1]); % size p*p*n !
            XC12 = XC1 .* XC2;
            
            R3d = repmat(R,[1,1,n]);
            b = ones(1,1,n);
            b(1,1,:) = weights;
            W3d = repmat(b,[p,p,1]);
            
            VS = (XC12 - R3d).^2;
            VS =VS .* W3d;
            VS = sum(VS,3);
            coff = sum(weights.^2)/((1-sum(weights.^2))^3);
            VS = VS * coff;
        end
        
        function xc = makeMeanZero(obj,inputData,x,weights)
            % make column means zero
            [n,p] = size(x);
            m = obj.functionApproximator.getExpectation(size(inputData,1), inputData);
            
            xc = x - m;
            
            
        end
        
        function varx = clcVar(obj,inputData,x,weights)
            
            xc = obj.makeMeanZero(inputData,x,weights);
            varx = bsxfun(@times, xc.^ 2, weights) ;
            varx = (1/(1-sum(weights.^2))) .* sum(varx);
            
        end
        
        function xc = makeStdOne(obj,inputData,x,weights)
            % make column  variances one
            [n,p] = size(x);
            varx = bsxfun(@times, x.^ 2, weights) ;
            varx = (1/(1-sum(weights.^2))) .* sum(varx);
            standardDev =  sqrt(varx);
            sd = ones(n, 1)*standardDev;
            xc = x ./ sd;
            
        end
        
        function R = sampleCov(obj,inputData,xc,w)
            % Matrix of Weighted Correlation Coefficients
            xc = obj.makeMeanZero(inputData,xc,w);
            R = bsxfun(@times, xc, w)' * xc;
            R = (1 / (1-sum(w.^2))) * R;
            
        end
        
        function R = sampleCor(obj,inputData,xc,w)
            % Matrix of Weighted Correlation Coefficients
            xc = obj.makeMeanZero(inputData,x,w);
            xc = obj.makeStdOne(inputData,xc,w); % convert S to R
            
            R = bsxfun(@times, xc, w)' * xc;
            R = (1 / (1-sum(w.^2))) * R;
            
        end
        
        
    end
    
end

