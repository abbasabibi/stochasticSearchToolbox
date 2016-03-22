classdef GPHyperParameterLearnerLOOCVLikelihood < Kernels.Learner.GPHyperParameterLearner
    %sets the bandwidth to a certain constant * the median of the distances
    
    properties
        validationSetIndices
        
    end
    
    methods (Static)
        function [kernelLearner] = CreateFromTrial(trial, gpName)
            kernelLearner = Kernels.Learner.GPHyperParameterLearnerLOOCVLikelihood(trial.dataManager, trial.(gpName));
        end
        
        function [kernelLearner] = CreateWithStandardReferenceSet(dataManager, GP)
            referenceSetLearner = Kernels.Learner.RandomKernelReferenceSetLearner(dataManager, GP);
            kernelLearner = Kernels.Learner.GPHyperParameterLearnerLOOCVLikelihood(dataManager, GP, referenceSetLearner);
        end
    end
    
    
    methods
        function obj = GPHyperParameterLearnerLOOCVLikelihood(dataManager, gp, gpReferenceSetLearner)
            obj = obj@Kernels.Learner.GPHyperParameterLearner(dataManager, gp, gpReferenceSetLearner);
            
        end
                                    
        function [] = learnFinalModel(obj)
            inputData = obj.gp.getReferenceSet();
            outputData = obj.gp.getReferenceSetOutputs();
            weighting = obj.gp.getReferenceSetWeights();
            
            obj.gpLearner.learnFunction(inputData, outputData, weighting);
        end
        
        function [] = processTrainingData(obj, data)
            obj.processTrainingData@Kernels.Learner.GPHyperParameterLearner(data);
            
            numPoints = size(obj.gp.getReferenceSet(),1);
            validationSets = mat2cell((1:numPoints)', ones(1,numPoints), 1);
            obj.validationSetIndices = validationSets;
        end
        
        function [logLike, gradient] = objectiveFunction(obj, params)
            
            inputData = obj.gp.getReferenceSet();
            outputData = obj.gp.getReferenceSetOutputs();
            weighting = obj.gp.getReferenceSetWeights();
            weighting = weighting / max(weighting);
            if (nargin > 1)
                obj.setParametersToOptimize(params);
                                                
                obj.gpLearner.learnFunction(inputData, outputData, weighting);
            end
            % gradients wrt LOG parameters!
            
            % traj indices: cell array of indices per trajectory
            
            %[n, d] = size(obj.trainingInput);
            n = numel(obj.validationSetIndices);
            %n = 2;
            %'only traj 1'
            
            logLike = 0; %negative log pseudo-likelihood
            
            %testf = 0;
            %testg = zeros(size(logparams,2),1);
            
            %obj.weighting = ones(size(obj.weighting));
            
            cholKy = obj.gp.cholKy;
            alpha = obj.gp.alpha;
            
            invKy = (eye(size(outputData,1))/cholKy)/cholKy';
            
            for fold = 1:n
                idxs = obj.validationSetIndices{fold};
                if(numel(idxs)~=0)
                    for dim = 1:size(outputData,2)
                        
                        output = outputData(idxs, dim);
                        foldMean =  output - invKy(idxs, idxs) \ alpha(idxs, dim);
                        wt = weighting(idxs);
                        pointVar = diag(inv(invKy(idxs, idxs)));
                        
                        %these variances include the weights which we don't know
                        % for new points, so subtract it...
                        pointVar = pointVar - obj.gp.GPRegularizer ./ wt + obj.gp.GPRegularizer;
                        
                        %testf = testf + pointVar(1);
                        
                        %weighted variances of the one-point marginals
                        
                        % likelihood of individual points
                        if(numel(idxs)~=0)
                            logLikelihoodFold = -0.5*wt'*log(pointVar)  ...
                                -sum(0.5*(output - foldMean).^2.*wt./pointVar)  ...
                                -0.5*sum(wt)*log(2*pi);
                            logLike = logLike + logLikelihoodFold;
                        end
                    end
                end
            end
            
            if(nargout>1)
                %TODO!!!
                assert(false);
                g = zeros(obj.getNumHyperParameters(),1);
                
                for paramidx = 1:size(params,2)
                    
                    %compute df/d_param_idx
                    Z_j = K \ obj.kernel.getKernelDerivParam(obj.trainingInput);
                    Za = Z_j*alpha;
                    ZdivK = Z_j/K;
                    for fold = 1:n
                        
                        idxs = obj.validationSetIndices{fold};
                        if(numel(idxs)~=0)
                            output = obj.trainingOutput(idxs, :);
                            foldMean = output - iK(idxs, idxs)\alpha(idxs);
                            wt = obj.weightingReference(idxs);
                            pointVar = diag(inv(iK(idxs, idxs)));
                            pointVar = pointVar - params(1)./wt + params(1);
                            
                            dmu_dth = -iK(idxs,idxs)\ZdivK(idxs,idxs)/iK(idxs,idxs)*alpha(idxs) ...
                                + iK(idxs,idxs) \ Za(idxs);
                            %dmu_dth2 = iK(idxs,idxs)\Za(idxs) - iK(idxs,idxs)\(iK(idxs,idxs)\ZdivK(idxs,idxs)*alpha(idxs));
                            %dvar_dth = diag(iK(idxs, idxs)\(iK(idxs, idxs)\ZdivK(idxs,idxs)) );
                            dvar_dth = diag ( iK(idxs,idxs)\ZdivK(idxs,idxs)/iK(idxs,idxs) );
                            if(paramidx==1)
                                dvar_dth = dvar_dth - 1./wt + 1;
                            end
                            
                            dp_dmu = (output - foldMean)./pointVar;
                            dp_dvar = -0.5./pointVar + (output-foldMean).^2./(2*pointVar.^2 );
                            
                            g(paramidx) = g(paramidx) + dmu_dth'*(wt.*dp_dmu) + dvar_dth'*(wt.*dp_dvar);
                            %testg(paramidx) = testg(paramidx) + dvar_dth(1);
                            %g(paramidx) = g(paramidx) + (numer1 + numer2)/iK(fold,fold);
                        end
                    end
                end
            end
        end
        
        
    end
    
end

