classdef GPHyperParameterLearnerMarginalLikelihood < Kernels.Learner.GPHyperParameterLearner
    %sets the bandwidth to a certain constant * the median of the distances
    
    methods (Static)
        function [kernelLearner] = CreateFromTrial(trial, gpName)
            kernelLearner = Kernels.Learner.GPHyperParameterLearnerMarginalLikelihood(trial.dataManager, trial.(gpName));
        end
        
        function [kernelLearner] = CreateWithStandardReferenceSet(dataManager, GP)
            referenceSetLearner = Kernels.Learner.KernelReferenceSetLearner(dataManager, GP, GP.inputVariables);
            kernelLearner = Kernels.Learner.GPHyperParameterLearnerMarginalLikelihood(dataManager, GP, referenceSetLearner);
        end
    end
    
    
    methods
        function obj = GPHyperParameterLearnerMarginalLikelihood(dataManager, gp, gpReferenceSetLearner)
            obj = obj@Kernels.Learner.GPHyperParameterLearner(dataManager, gp, gpReferenceSetLearner);
        end
                          
        function [] = learnFinalModel(obj)
            inputData = obj.gp.getReferenceSet();
            outputData = obj.gp.getReferenceSetOutputs();
            weighting = obj.gp.getReferenceSetWeights();
            
            obj.gpLearner.learnFunction(inputData, outputData, weighting);
        end

        
        function [likelihood, gradient] = objectiveFunction(obj, params)
            
            inputData = obj.gp.getReferenceSet();
            outputData = obj.gp.getReferenceSetOutputs();
            weighting = obj.gp.getReferenceSetWeights();
            
            if (nargin > 1)
                obj.setParametersToOptimize(params);
                                                
                obj.gpLearner.learnFunction(inputData, outputData, weighting);
            end
            
            %obj.setHyperParameters(hyperParameters);
            
            [n, d] = size(obj.gp.getReferenceSet());
            
            % computes regularized kernel matrix, inverse, cholesky
            % (cholKy) and the alphas
            cholKy = obj.gp.cholKy;
            alpha = obj.gp.alpha;
            
            ldKy = 2*sum(log(diag(cholKy)));
            
            likelihood = (-.5 * trace(outputData(:, obj.gp.getDimIndicesForOutput)'*alpha) -.5 * ldKy - n/2*log(2*pi));
            
            % TODO: put prior on hyperparameters (snr)
            
            %SNR = sigf/signs;
            %SNRpenalty = -log(factorial(obj.gammaK)) -obj.gammaK*log(obj.gammaTh) + (obj.gammaK-1)*log(sigf) - sigf/obj.gammaTh;
            %scale = -length(y(:, targetIx))/5  * obj.SNRPenaltyScaler;
            
            %if and(SNR < sqrt(obj.maxCondNum / n), SNR < obj.SNRHardLimit)
            %    scale = 0;
            %end
            
            %f = f + scale*SNRpenalty;
            
            %signs adjustment for singular matrices
            %likelihood = likelihood - (obj.GPRegularizer - obj.GPRegularizer).^2;
            
            if nargout > 1
                % TODO!
                
                assert(false);
                dummy = alpha*alpha' - iKy;
                
                g = zeros(length(loghyp), 1);
                
                % dsigf_snr = scale*(-1/obj.gammaTh + (obj.gammaK-1)/sigf)*sigf/2;
                
                % dK / dsigf
                
                p1 = (2 * K *sigf);
                p1 = dummy*p1;
                
                g(end-1, 1) = -.5*trace(p1); % + dsigf_snr;
                % dK / dsign
                g(end, 1) =  -.5*trace(2*dummy*GPRegularizerLocal);% + dsign_snr;
                % dK / dwi
                
                %TODO: build in gradient from kernel
                for i = 1:d
                    
                    Wloc = zeros(d);
                    Wloc(i, i) = w(i)^-3;
                    
                    p3 = maha(x, x, Wloc);
                    p3 = (K.* p3)* w(i);
                    p3 = dummy*p3;
                    g(i, 1) = -.5*trace(p3);
                end
            end
            
        end
        
        
    end
    
end

