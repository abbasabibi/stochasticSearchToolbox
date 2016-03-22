classdef GaussianActionPolicy <  Distributions.Gaussian.GaussianLinearInFeatures    
    properties
        additionalNoiseProvider
    end
    
    methods                
        
        function obj = GaussianActionPolicy(dataManager, inputFeatures)
            superargs = {};
            if(nargin==1 || isempty(inputFeatures))
                inputFeatures = 'states';
            end
            if (nargin >= 1)
                superargs = {dataManager, 'actions', {inputFeatures}, 'GaussianAction'};
            end
            
            obj = obj@Distributions.Gaussian.GaussianLinearInFeatures(superargs{:});
            obj.addDataFunctionAlias('sampleAction', 'sampleFromDistribution');
        end
        
        
        function [] = setAdditionalNoiseProvider(obj, additionalNoiseProvider)
            obj.additionalNoiseProvider = additionalNoiseProvider;
        end
        
        
         function [mean, sigma] = getExpectationAndSigma(obj, numElements, varargin)
             [mean, sigma] = obj.getExpectationAndSigma@Distributions.Gaussian.GaussianLinearInFeatures(numElements, varargin{:});
            
             if (~isempty(obj.additionalNoiseProvider))
                 %do the reduction if the variance     
                 sigmaTemp = permute(sigma, [2 3 1]);
                 sigma2 = sigmaTemp' * sigmaTemp;
                 if (length(varargin) == 0)
                     states = zeros(numElements, obj.additionalNoiseProvider.dimState);
                 else
                     states = varargin{1};
                 end
                 additionalSigma = obj.additionalNoiseProvider.getControlNoiseStd(states, zeros(numElements, obj.dimOutput));
                                  
                 if (size(additionalSigma,1) > 1)
                     warning('pst:AdditionalNoiseProvider', 'State dependent Noise models for noise provider not implemented yet!');                     
                 end
                 additionalSigma2 = diag(additionalSigma.^2);
                 sigma2 = sigma2 - additionalSigma2;                 
                 diagL0 = diag(sigma2);
                
                 diagL0(diagL0 <= 0) = diagL0(diagL0 <= 0) - 10^-4;
                 diagL0(diagL0 > 0) = 0;
                  
                 sigma2 = sigma2 - diag(diagL0);
                 sigmaStdDiag = diag(sqrt(sigma2)); 
                 
                 sigmaMax   = sigmaStdDiag * sigmaStdDiag';
                 sigmaTooBig = abs(sigma2) > sigmaMax;
                 sigmaTooBig(logical(eye(size(sigma2,1)))) = false;
                 sigmaSign  = sign(sigma2);
                 
                 sigma2(sigmaTooBig) = sigmaMax(sigmaTooBig) .* sigmaSign(sigmaTooBig) * 0.99;
                 
                 ridgeFactor = 10^-4;
                 while (true)
                     try 
                         sigma(1,:,:) = chol(sigma2 + ridgeFactor * eye(size(sigma2,1)));
                         break;
                     catch ME
                         ridgeFactor = ridgeFactor * 10;
                     end
                 end
             end
         end
        
    end
end
