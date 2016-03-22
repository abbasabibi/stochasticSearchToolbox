classdef ExponentialQuadraticKernel < Kernels.Kernel
    %EXPONENTIALQUADRAITCKERNEL aka Gaussian kernel, squared exponential
    % possibility to use ARD (default: yes)
    % possibility to normalize output weights (default: no)
    
    properties (SetObservable, AbortSet)
        ARD = false; % automatic relevance determination: if true, optimize
                    % lengthscales separately
        
       
    end
    
    properties
        bandWidth = [];
        normalized = true;
    end
    
    methods 

        function obj = ExponentialQuadraticKernel(dataManager, numDims, kernelName, normalized)

            obj@Kernels.Kernel(dataManager, numDims, kernelName);
            
            obj.linkProperty('ARD', ['ExponentialQuadraticKernelUseARD', strrep(kernelName,'~','')]);
            if(exist('normalized', 'var'))
                obj.normalized = normalized;
            end

            if (obj.ARD)
                obj.bandWidth = ones(1, obj.numDims);
            else
                obj.bandWidth = 1;
            end
        end
        
        function [v] = getGramDiag(obj, data)
            v = ones(size(data,1),1);            
        end
        
        function [] = setBandWidth(obj, bandWidth)

            if(obj.ARD)
                obj.bandWidth = bandWidth;
            else
                obj.bandWidth = mean(bandWidth);
            end
            obj.bandWidth = reshape(obj.bandWidth,1,[]);
            obj.kernelTag = obj.kernelTag + 1;
        end
        
        function [bandWidth] = getBandWidth(obj)
            bandWidth = obj.bandWidth;
        end
        
        function [params] = getHyperParameters(obj)
            params = obj.bandWidth;
        end
        
        function [numParams] = getNumHyperParameters(obj)
            numParams = numel(obj.bandWidth);
        end
        
        function [] = setHyperParameters(obj, params)
            obj.setHyperParameters@Kernels.Kernel(params);
            
            obj.bandWidth = reshape(params,1,[]);
            if (obj.ARD)
                assert(length(params) == obj.numDims);
            else
                assert(length(params) == 1);
            end
        end
        
        function [K] = getGramMatrix(obj, a, b)
            bandwidth = obj.getBandWidth();
            
            Q = diag(1./(bandwidth.^2));
            aQ = a * Q ; 
            K = bsxfun ( @plus , sum ( aQ .* a , 2 ), sum ( b * Q .* b , 2 )');
            K = K -2* aQ * b' ;
            K = exp(-0.5* K);

            if(obj.normalized)
                K = K/(sqrt(prod(bandwidth.^2)*(2*pi)^(numel(bandwidth) )));
            end
            K = K;
        end
        
        function [gradientMatrices, gramMatrix] = getKernelDerivParam(obj, data)
            bandwidth = obj.getBandWidth();
            
            gramMatrix = obj.getGramMatrix(data, data);
            
            gradientMatrices = zeros(size(gramMatrix, 1), size(gramMatrix, 2), obj.getNumHyperParameters());
            
            if(obj.normalized)
                assert(false,'derivative not implemented for normalized kernel')
            end
            if(obj.ARD)
                
                for (dim = 1:obj.numDims)
                    sqdist = (bsxfun(@minus, data(:,dim), data(:,dim)')).^2;
                    gradientMatrices(:, :, dim) = - gramMatrix .* (sqdist * 1/(bandwidth(dim)^3));
                end
            else
                
                sqdist = bsxfun ( @plus , sum ( data .* data, 2 ) ,sum ( data .* data , 2 )' ) -2* (data * data') ;
                gradientMatrices(:, :, 1) = - gramMatrix .* (sqdist * 1/(bandwidth(1)^3));
            end
            gradientMatrices = -gradientMatrices;
            
        end
        
        function g = getKernelDerivData(obj, refdata, curdata)
            bandwidth = obj.getBandWidth();
            % refdata = n * d
            % curdata = m * d
            % returns g = m*d*n. g(i,j,l) is:
            % d k(refdata(l,:), curdata(i,:))
            % ---------------------------
            % d curdata(i,j)
            grammatrixinternal = obj.getGramMatrix(refdata,curdata );
            grammatrixinternal= permute(grammatrixinternal, [2,3,1]);
            
            %calculate -2*Q*(x-x')
            Q = diag(1./(bandwidth.^2));
            Qref = permute(refdata * Q , [3,2,1 ] );
            Qcur = permute( curdata*Q, [1,2,3 ] );
            scaleddist = -2*bsxfun(@plus, Qcur, -Qref);
            
            g = bsxfun(@times, grammatrixinternal, scaleddist);
            
            assert(false); % Geri: need to fix the order of dimensions

        end
        
        function omega = getFourierSamples(obj, numFeatures, randStream )
            bandwidth = obj.getBandWidth();

            s = RandStream.getGlobalStream;
            RandStream.setGlobalStream(randStream);
            omega = mvnrnd(zeros(obj.numDims,1), diag(1./bandwidth.^2),numFeatures);
            RandStream.setGlobalStream(s);
        end
        
        function proj = getFourierProjection(obj, numFeatures, randStream, x)
            omega = obj.getFourierSamples(numFeatures, randStream);
            proj = x*omega';
        end
        
        
        function obj_out = clone(obj)
           
           args = {obj.getDataManager, obj.kernelName, obj.normalized};
           obj_out = feval(class(obj), args{:});
           obj_out.setHyperParameters(obj.getHyperParameters);
           obj_out.ARD = obj.ARD;
        end
        
    end    
 
    
end

