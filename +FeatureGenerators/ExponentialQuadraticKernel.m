classdef ExponentialQuadraticKernel < FeatureGenerators.Kernel.Kernel
    %EXPONENTIALQUADRAITCKERNEL aka Gaussian kernel, squared exponential
    % possibility to use ARD (default: yes)
    % possibility to normalize output weights (default: no)
    
    properties
        scale;
        bandwidth;
        normalized = false;
        ARD = true; % automatic relevance determination: if true, optimize
                    % lengthscales separately
    end
    
    properties(SetObservable, AbortSet)
        bandwidthFactor = 10;

    end
    
    methods 

        function obj = ExponentialQuadraticKernel(dataManager, featureVariables, stateIndices, numFeatures, tolearn, name, normalized, ARD)
            if(~exist('name','var'))
                name= 'ExpQuadKernel';
            end
            if(~exist('tolearn','var'))
                tolearn = featureVariables;
            end
            obj@FeatureGenerators.Kernel.Kernel(dataManager, featureVariables, name, stateIndices, numFeatures,tolearn);
            
            obj.linkProperty('bandwidthFactor');
           
            if(stateIndices==':')
                obj.bandwidth = obj.bandwidthFactor*ones(1,dataManager.getNumDimensions(featureVariables));
            else
                obj.bandwidth = obj.bandwidthFactor*ones(1,numel(stateIndices));
            end
            obj.scale = 1;
            if(exist('normalized', 'var'))
                obj.normalized = normalized;
            end
            if(exist('ARD', 'var'))
                obj.ARD = ARD;
            end
            
           
                
        end
        
        function [params] = getHyperParametersInternal(obj)
            if(obj.ARD)
                params = [obj.scale, obj.bandwidth];
            else
                params = [obj.scale, obj.bandwidth(1)]; %bandwidths all the same
            end
        end
        
        function [] = setHyperParametersInternal(obj, params)
            obj.scale = params(1);
            if(obj.ARD)
                obj.bandwidth = params(2:end);
            else
                obj.bandwidth = ones(size(obj.bandwidth))*params(2);
            end
        end
        
        function [K] = getGramMatrixInternal(obj, a, b)
            Q = diag(1./(obj.bandwidth.^2));
            aQ = a * Q ; sqdist = bsxfun ( @plus , sum ( aQ .* a , 2 ) ,sum ( b * Q .* b , 2 )' ) -2* aQ * b' ;
            K = exp(-0.5* sqdist);

            if(obj.normalized)
              %  K = K/(sqrt(prod(obj.bandwidth.^2)*(2*pi)^(numel(obj.bandwidth) )));
                K = K/sum(K);
            end
            K = obj.scale * K;
        end
        
        function grammatrixinternal = precomputeForDerivative(obj,data)
            grammatrixinternal = obj.getGramMatrixInternal(data,data );
        end
        
        function g = getKernelDerivParamInternal(obj, paramidx, data, grammatrixinternal)
            if(~exist('grammatrixinternal','var'))
                grammatrixinternal = obj.precomputeForDerivative(data);
            end
            if(obj.normalized)
                assert(false,'derivative not implemented for normalized kernel')
            end
            if(paramidx==1)
                g = grammatrixinternal/obj.scale;
            else
                if(obj.ARD)
                    
                    dim = paramidx-1;
                    sqdist = (bsxfun(@minus, data(:,dim), data(:,dim)')).^2;
                    g = grammatrixinternal .* (sqdist * 1/(obj.bandwidth(dim)^3));
                else

                    sqdist = bsxfun ( @plus , sum ( data .* data, 2 ) ,sum ( data .* data , 2 )' ) -2* data * data' ;
                    g = grammatrixinternal .* (sqdist * 1/(obj.bandwidth(1)^3));
                end
            end
        end
        
        function g = getKernelDerivDataInternal(obj, refdata, curdata)
            % refdata = n * d
            % curdata = m * d
            % returns g = m*d*n. g(i,j,l) is:
            % d k(refdata(l,:), curdata(i,:))
            % ---------------------------
            % d curdata(i,d)
            grammatrixinternal = obj.getGramMatrixInternal(refdata,curdata );
            grammatrixinternal= permute(grammatrixinternal, [2,3,1]);
            
            %calculate -2*Q*(x-x')
            Q = diag(1./(obj.bandwidth.^2));
            Qref = permute(Q * refdata, [3,2,1 ] );
            Qcur = permute(Q * curdata, [1,2,3 ] );
            scaleddist = -2*bsxfun(@plus, Qcur, -Qref);
            
            g = bsxfun(@times, grammatrixinternal, scaleddist);
        end
        
        function C = convolve(obj, a, b,bwfactor)
            % Calculates \int p(x | a, bw^2) P(x | b, bw^2) dx
            % (where bw is the st.dev.)
            assert(obj.normalized, 'cannot convolve if kernel is not normalized!')
            
            % example: matrix cookbook p. 27
            % norm factor: N(refdata, curdata, sqrt(2)*bw)
            % integral over new distr: N(x | m_c, sigma_c) = 1
            
            normfactor_var = bwfactor.^2 + obj.bandwidth.^2;
            
            Q = diag(1./(normfactor_var));
            aQ = a * Q ; sqdist = bsxfun ( @plus , sum ( aQ .* a , 2 ) ,sum ( b * Q .* b , 2 )' ) -2* aQ * b' ;
            C = exp(-0.5* sqdist);
            C = C/(sqrt(prod(normfactor_var)*(2*pi)^(numel(normfactor_var) )));
            
            
        end
        
        function obj_out = clone(obj)
           
           args = {obj.getDataManager, obj.featureVariables, obj.stateIndices , obj.numFeatures, obj.tolearn, obj.featureName, obj.normalized, obj.ARD };
           obj_out = feval(class(obj), args{:});
           obj_out.setHyperParameters(obj.getHyperParameters);
           
        end
        
    end    
 
    
end

