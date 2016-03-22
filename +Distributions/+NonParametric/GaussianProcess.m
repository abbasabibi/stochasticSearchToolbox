
classdef GaussianProcess < Distributions.DistributionWithMeanAndVariance & Functions.Mapping & Functions.Function
    %Gaussian Process Policy  Selecting actions according to GP
    %   GP fitted on weighted samples
    %   conditioned on S, policy is a Gaussian
    
    properties(SetObservable, AbortSet)
        initSigma = 1;
    end
    
    properties
        trainingInput
        trainingOutput
        weighting
        kernel
        distribution

    end
    
    methods
        function obj = GaussianProcess(dataManager, kernel, varOut, varIn)

            obj = obj@Distributions.DistributionWithMeanAndVariance();
            obj = obj@Functions.Mapping(dataManager, varOut, varIn, 'GaussianProcess');


            obj.kernel = kernel;

            obj.linkProperty('initSigma', ['initSigma', upper(obj.outputVariable(1)), obj.outputVariable(2:end)]);


            obj.registerMappingInterfaceDistribution();
            %obj.addDataFunctionAlias('sampleAction', 'sampleFromDistribution');
        end
        

        
        function [likelihood] = negloglikelihood(obj, valInput, valOutput, weighting,logparams)
            
            params = exp(logparams);
            obj.kernel.kernel.setHyperParameters(params); % not the nicest solution...
            
            logprobs = getDataProbabilities(obj, valInput, valOutput);
            likelihood = -logprobs'*weighting;
            
        end
        
        function [varargout] = trajCVnegloglikelihood(obj, logparams, trajindices)

            
            
            % gradients wrt LOG parameters!
            
            % traj indices: cell array of indices per trajectory
            
            params = exp(logparams);
            
            %[n, d] = size(obj.trainingInput);
            n = size(trajindices,1);
            %n = 2;
            %'only traj 1'
            
            obj.kernel.kernel.setHyperParameters(params);
            f = 0; %negative log pseudo-likelihood 
            g = zeros(size(logparams,2),1);
            
            %testf = 0;
            %testg = zeros(size(logparams,2),1);
            
            %obj.weighting = ones(size(obj.weighting));
            
            K = obj.kernel.kernel.getWeightedGramMatrix(obj.trainingInput, obj.weighting); %weighed
            
            precomputed = obj.kernel.kernel.precomputeForDerivative(obj.trainingInput);
            
            iK = inv(K);
            alpha = K\obj.trainingOutput;
            
            for fold = 1:n
                idxs = trajindices{fold};
                if(numel(idxs)~=0)
                    for dim = 1:size(obj.trainingOutput,2)
                        output = obj.trainingOutput(idxs, dim);
                        foldMean =  output - iK(idxs, idxs)\alpha(idxs, dim);
                        wt = obj.weighting(idxs);
                        pointVar = diag(inv(iK(idxs, idxs)));

                        %these variances include the weights which we don't know
                        % for new points, so subtract it...
                        pointVar = pointVar - params(1)./wt + params(1);



                        %testf = testf + pointVar(1);

                        %weighted variances of the one-point marginals

                        % likelihood of individual points
                        if(numel(idxs)~=0)
                            logLikelihood = -0.5*wt'*log(pointVar)  ...
                                -sum(0.5*(output - foldMean).^2.*wt./pointVar)  ...
                                -0.5*sum(wt)*log(2*pi);
                            f = f + logLikelihood;
                            %if (fold < 10)
                            %    fprintf('likely2: %f\n', logLikelihood);
                            %    foldMean
                            %    pointVar
                            %end
                        end
                    end
                end
            end
            if(nargout>1)
                for paramidx = 1:size(params,2)

                    %compute df/d_param_idx
                    Z_j = K\obj.kernel.kernel.getKernelDerivParam(paramidx,...
                        obj.trainingInput, precomputed, obj.weighting );
                    Za = Z_j*alpha;
                    ZdivK = Z_j/K;
                    for fold = 1:n

                        idxs = trajindices{fold};
                        if(numel(idxs)~=0)
                            output = obj.trainingOutput(idxs, :);
                            foldMean = output - iK(idxs, idxs)\alpha(idxs);
                            wt = obj.weighting(idxs);
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
                g = -g .* params';
                varargout{2} = g;
            end

            f = -f;
            varargout{1} = f;
            % for log parameters
            
            %testg = testg.*params';
            
            
        end
        
        function [f, g] = CVlikelihood(obj, logparams, factor)
            % factor : multiplication factor, e.g. -1 to minimize
            % gradients wrt LOG parameters!
            
            params = exp(logparams);
            
            [n, d] = size(obj.trainingInput);
            obj.kernel.kernel.setHyperParameters(params);
            f = 0; %negative log pseudo-likelihood 
            g = zeros(size(logparams,2),1);
            
            %obj.weighting = ones(size(obj.weighting));
            
            K = obj.kernel.kernel.getWeightedGramMatrix(obj.trainingInput, obj.weighting); %weighed
            precomputed = obj.kernel.kernel.precomputeForDerivative(obj.trainingInput);
            
            iK = inv(K);
            alpha = K\obj.trainingOutput;
            
            for fold = 1:n
                foldMean = obj.trainingOutput(fold, :) - alpha(fold)/iK(fold, fold);
                foldVar = 1/iK(fold, fold);
                logLikelihood = -0.5*log(foldVar) - ...
                    ((obj.trainingOutput(fold, :) - foldMean)^2)/(2*foldVar) ...
                    - 0.5*log(2*pi);
                %f = f + logLikelihood;
                f = f + obj.weighting(fold)*logLikelihood;
                %hold on; plot(fold, logLikelihood, 'g*'); hold off;
            end
            for paramidx = 1:size(params,2)
                
                %compute df/d_param_idx
                Z_j = K\obj.kernel.kernel.getKernelDerivParam(paramidx,...
                    obj.trainingInput, precomputed, obj.weighting );
                Za = Z_j*alpha;
                ZdivK = Z_j/K;
                for fold = 1:n
                    numer1 = alpha(fold)*Za(fold);
                    numer2 = -0.5*(1+alpha(fold)^2/iK(fold,fold))*ZdivK(fold,fold);
                    g(paramidx) = g(paramidx) + obj.weighting(fold)*(numer1 + numer2)/iK(fold,fold);
                    %g(paramidx) = g(paramidx) + (numer1 + numer2)/iK(fold,fold);
                end
            end

            f = f*factor;
            
            % for log parameters
            g = g*factor .* params';
            
            
        end
        
        function [mean] = getExpectation(obj, ~, inputData)
            if(isempty(obj.weighting))
                obj.weighting = ones(size(obj.trainingInput,1),1);
            end
            idxs = find(obj.weighting > max(obj.weighting)*10e-4);

            wtKernelMatrix = obj.kernel.kernel.getWeightedGramMatrix(obj.trainingInput(idxs,:), obj.weighting(idxs));
            % calculate kvec
            % matrix with one column per input data point
            kvecs = obj.kernel.kernel.getGramMatrix(inputData,obj.trainingInput(idxs,:));
            

            %aforementioned vectors times inverse of kernel matrix
            kVecWeightedInverseInputKernelLocal = ...
                kvecs / wtKernelMatrix;

            %calculate means
            mean = kVecWeightedInverseInputKernelLocal * obj.trainingOutput(idxs,:);            
        end
        

        function [mean, sigma] = getExpectationAndSigma(obj, ~, inputData)
            
            if(size(obj.trainingOutput,1)==0)
                % no training set given, random policy
                
                range = obj.dataManager.getRange(obj.outputVariable);
            
                sigma = repmat(range .* obj.initSigma, size(inputData,1),1);
                mean = zeros(size(inputData,1), size(range,2));
            else        
                if(isempty(obj.weighting))
                    obj.weighting = ones(size(obj.trainingInput,1),1);
                end
                idxs = find(obj.weighting > max(obj.weighting)*10e-4);

                
                
                
                
                %fprintf('current params:\n')
                %disp(obj.kernel.getHyperParameters())
                
                % average weights -> correspond to p(s)
                
                %kernelMatrix = obj.kernel.getGramMatrix(obj.trainingInput(idxs,:), obj.trainingInput(idxs,:));
                %ps = sum(bsxfun(@times, kernelMatrix, obj.weighting(idxs,:)))';
                %conditional_weighting = obj.weighting(idxs,:)./ps;
                %conditional_weighting = conditional_weighting/max(conditional_weighting);
                conditional_weighting = obj.weighting(idxs,:);
                
                
                % calculate kvec
                % matrix with one row per input data point
                kvecs = obj.kernel.kernel.getGramMatrix(inputData,obj.trainingInput(idxs,:));
                wtKernelMatrix = obj.kernel.kernel.getWeightedGramMatrix(obj.trainingInput(idxs,:), conditional_weighting);

                
                %aforementioned vectors times inverse of kernel matrix
                kVecWeightedInverseInputKernelLocal = ...
                    kvecs / wtKernelMatrix;




                %calculate means
                mean = kVecWeightedInverseInputKernelLocal * obj.trainingOutput(idxs,:);


                %calculate kself - k(x_i,x_i) for each input x_i
                
                kself = obj.kernel.kernel.getGramDiag(inputData);
                

                %calculate sigmas
                sigmasq = kself + obj.kernel.kernel.lambda - sum((kVecWeightedInverseInputKernelLocal) .* kvecs,2);
                sigma = repmat(sqrt(sigmasq),1,size(obj.trainingOutput,2)) ;

            end
        end

    end
    
end

