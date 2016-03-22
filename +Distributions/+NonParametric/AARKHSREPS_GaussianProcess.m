
classdef AARKHSREPS_GaussianProcess < Distributions.DistributionWithMeanAndVariance & Functions.Mapping & Functions.Function
    %Gaussian Process Policy  Selecting actions according to GP
    %   Specifically for GP's as defined in action-affine RKHS-REPS
    
    properties(SetObservable, AbortSet)
        initSigma = 1;
    end
    
    properties
        %%%%%%%%%%%%%%%%%%
        
        % all cell array with one cell per iteration
        actions
        rewards
        
        hyperparameters_r
        hyperparameters_sp
        inverse_sq_kernels_r % could be computed on-the fly to be more memory-efficient
        inverse_sq_kernels_sp
        etas
        state_representations %states at every iteration to calculate k-vector
        expValWeightEmbedding % weights to calculate expected value from embedding strenghts
                              % = alpha * G
        %%%%%%%%%%%%%%%%%%
        
        kernel_states_r
        kernel_states_sp
        
        %%%
        scaling % optional scaling if actions have been normalized before
    end
    
    methods
        function obj = AARKHSREPS_GaussianProcess(dataManager, kernel_states_r, kernel_states_sp, state_representation, scaling)

            obj = obj@Distributions.DistributionWithMeanAndVariance();
            obj = obj@Functions.Mapping(dataManager, 'actions', state_representation, 'GaussianProcess');


            obj.kernel_states_r = kernel_states_r;
            obj.kernel_states_sp = kernel_states_sp;

            obj.linkProperty('initSigma', ['initSigma', upper(obj.outputVariable(1)), obj.outputVariable(2:end)]);

           
            obj.registerMappingInterfaceDistribution();
            obj.addDataFunctionAlias('sampleAction', 'sampleFromDistribution');
            
            if(~exist('scaling', 'var'))
                obj.scaling = 1;
            else
                obj.scaling = scaling;
            end
        end
        

        
        function [likelihood] = negloglikelihood(obj, valInput, valOutput, weighting,logparams)
            % do we need this?
            error('AARKHSREPS_GaussianProcess:notImplemented','do we need this? not implemented yet');
        end
        
        function [varargout] = trajCVnegloglikelihood(obj, logparams, trajindices)
            % do we need this?
            error('AARKHSREPS_GaussianProcess:notImplemented','do we need this? not implemented yet');
        end
        
        function [f, g] = CVlikelihood(obj, logparams, factor)
            % do we need this?
            error('AARKHSREPS_GaussianProcess:notImplemented','do we need this? not implemented yet');
        end
        
        function [mean] = getExpectation(obj, ~, inputData)
            if(isempty(obj.weighting))
                obj.weighting = ones(size(obj.trainingInput,1),1);
            end
            idxs = find(obj.weighting > max(obj.weighting)*10e-4);

            wtKernelMatrix = obj.kernel.getWeightedGramMatrix(obj.trainingInput(idxs,:), obj.weighting(idxs));
            % calculate kvec
            % matrix with one column per input data point
            kvecs = obj.kernel.getGramMatrix(inputData,obj.trainingInput(idxs,:));
            

            %aforementioned vectors times inverse of kernel matrix
            kVecWeightedInverseInputKernelLocal = ...
                kvecs / wtKernelMatrix;

            %calculate means
            mean = kVecWeightedInverseInputKernelLocal * obj.trainingOutput(idxs,:);            
        end
        

        function [mean, sigma] = getExpectationAndSigma(obj, ~, inputData)
            range = obj.dataManager.getRange(obj.outputVariable);
            
            if(isempty(obj.actions))
                % no training set given, random policy
                
                
            
                sigma = repmat(range .* obj.initSigma, size(inputData,1),1);
                mean = zeros(size(inputData,1), size(range,2));
            else        
                % start precision matrix at 1/sigma
                % TODO lambda / sigma not necessarily diagonal?
                %lambda = repmat(range .* obj.initSigma, size(inputData,1),1);
                lambda = repmat(permute(diag(1./(range .* obj.initSigma)),[3,1,2]), [size(inputData,1),1,1]);
                % is (i,j,n)
                
                %first parameter in canonical form, related to mean
                lambdamu = zeros(size(inputData,1), size(range,2));
                
                
                hyperparameterstemp_r = obj.kernel_states_r.getHyperParameters;
                hyperparameterstemp_sp = obj.kernel_states_sp.getHyperParameters;
                % go from t = 1 through size(actions)
                for it = 1:numel(obj.actions)
                    %set hyperparameters and refset
                    obj.kernel_states_r.setHyperParameters(obj.hyperparameters_r{it} )
                    obj.kernel_states_sp.setHyperParameters(obj.hyperparameters_sp{it} )
                    
                    ks_r = obj.kernel_states_r.getGramMatrix(inputData, obj.state_representations{it});
                    ks_sp = obj.kernel_states_sp.getGramMatrix(inputData, obj.state_representations{it});
                    
                    a_outer = bsxfun(@times, obj.actions{it}, permute(obj.actions{it},[1,3,2])); % a_outer(i,:,:) = a(i,:)'*a(i,:)
                    rewkernelinv = obj.rewards{it}'*obj.inverse_sq_kernels_r{it};
                    embedkernelinv = obj.expValWeightEmbedding{it}* obj.inverse_sq_kernels_sp{it};
                    
                    %cov_r = permute(sum(bsxfun(@times, rewkernelinv, a_outer),1), [2,3,1 ]);
                    %cov_V = permute(sum(bsxfun(@times, embedkernelinv, a_outer),1), [2,3,1 ]);
                    
                    cov_r = repmat(sum(bsxfun(@times, rewkernelinv', a_outer),1),[size(inputData,1),1,1]);
                    cov_V = repmat(sum(bsxfun(@times, embedkernelinv', a_outer),1),[size(inputData,1),1,1]);
                    
                    
                    lambda = lambda   -2*(cov_r + cov_V)/obj.etas{it};
                    
                    m_r =( rewkernelinv  * bsxfun(@times, ks_r', obj.actions{it}))';% reward term
                    m_V = (embedkernelinv  * bsxfun(@times, ks_sp', obj.actions{it}))';% value term
                    
                    lambdamu = lambdamu + (m_V + m_r)/obj.etas{it}; 
                    %calc new lambda and lambdamu for every state
                end
                obj.kernel_states_r.setHyperParameters(hyperparameterstemp_r);
                obj.kernel_states_sp.setHyperParameters(hyperparameterstemp_sp);
                % calc sigma and mu from lambda and lambdamu
                
                sigma = zeros(size(lambda));
                mean = zeros(size(lambda,1), size(range,2));
                for i = 1:size(sigma,1)
                    covar = inv(lambda(i,:,:)); 
                    sigma(i,:, :) = sqrtm(covar);%sqrt of covariance
                    mean(i,:) = covar*lambdamu(i,:);
                end
                %sigma = lambda;
                
                mean = mean * obj.scaling;
                sigma = sigma * obj.scaling;
                
            end
            
        end

    end
    
end