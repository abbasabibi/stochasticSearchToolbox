classdef PeriodicKernel < Kernels.Kernel
    %PERIODIC KERNEL squared exponential of (sin, cos) features of
    %input data.
    
    properties (SetObservable, AbortSet)
        ARD = true; % automatic relevance determination: if true, optimize
                    % lengthscales separately
        
        bandWidth = [];
        period  = 2 * pi
        
    end

    
    properties
        
        
        fixedperiod;
        normalize=false;
    end
    
    methods 


        function obj = PeriodicKernel(dataManager, numDims, name, period,  normalize)

            %if period is to be learned, pass a number < 0 as parameter
            
            obj@Kernels.Kernel(dataManager, numDims,  name);
            
                        
            if(exist('normalized', 'var'))
                obj.normalized = normalized;
            end           
            
            if(exist('period','var'))
                assert(isnumeric(period));
                if(numel(period) == 1)
                    obj.period = period*ones(1,numDims);
                else
                    obj.period = period;
                end                
            else
                obj.period = 2 * pi *ones(1,numDims);
            end
            
            if(exist('normalize', 'var') )
                %for interpretation as density if using guassian approximation
                obj.normalize=normalize;
            end
            
            obj.bandWidth = ones(1, numDims);
        end
        
        function [params] = getHyperParameters(obj)
            params = [obj.bandWidth];
         end
        
        function [] = setHyperParameters(obj, params)
            obj.setHyperParameters@Kernels.Kernel(params);            
            obj.bandWidth = params;            
        end
        
        function [] = setBandWidth(obj, bandWidth)
            obj.bandWidth = bandWidth;
            obj.kernelTag = obj.kernelTag + 1;
        end
        
        function [bandWidth] = getBandWidth(obj)
            bandWidth = obj.bandWidth;
        end
        
        
        function [numParams] = getNumHyperParameters(obj)
            numParams = obj.numDims;
        end
        
        function [K] = getGramMatrix(obj, data1, data2)
            logK = zeros(size(data1,1), size(data2,1));
            
            for i = 1:size(data1,2)
                % Check: Does this make sense???
                logK = logK + sin(pi* abs(bsxfun(@minus,data1(:,i),data2(:,i)' ) /obj.period(i))).^2/obj.bandWidth(i)^2;
            end
            
            K = exp(-2*logK);
            if(obj.normalize)
                K = K/(sqrt(prod(obj.bandwidth.^2)*(2*pi)^(numel(obj.bandwidth) )));
            end
        end
        
        function gradientMatrices = getKernelDerivParam(obj, data)
           
            
            grammatrixinternal = obj.getGramMatrix(data, data);
            
            gradientMatrices = zeros(size(grammatrixinternal, 1), size(grammatrixinternal,2), obj.getNumHyperParameters());
            
            for dim = 1:obj.getNumHyperParameters()                   
                
                sqdist = sin(pi* abs(bsxfun(@minus,data(:,dim),data(:,dim)' ) /obj.period(dim))).^2;
               
                gradientMatrices(:,:, dim) = grammatrixinternal .* (sqdist * 1/(obj.bandWidth(dim)^3));
            end
            
            gradientMatrices = 4*gradientMatrices;
        end
        
        function g = getKernelDerivData(obj, refdata, curdata)
            % refdata = n * d
            % curdata = m * d
            % returns g = m*d*n. g(i,j,l) is:
            % d k(refdata(l,:), curdata(i,:))
            % ---------------------------
            % d curdata(i,d)
            
            g = ones(size(curdata,1), size(curdata,2), size(refdata,1));
            
            gm = obj.getGramMatrix(refdata, curdata);
            
            for dim = 1:size(refdata,2) %dimension we want to take derivative of
                dif = bsxfun(@minus,refdata(:,dim),curdata(:,dim)' );
                g_dim = gm .* 2 .* (sin(abs(dif)*pi/obj.period(dim))/obj.bandwidth(dim));
                g_dim = g_dim .* cos(abs(dif)*pi/obj.period(dim)) .* pi/obj.period(dim);
                g_dim = g_dim .* sign(dif) * -1;
                g(:,:, dim) = g_dim';
            end
            
            
            %logK = zeros(size(a,1), size(b,1));
            %
            %for i = 1:size(a,2)
            %    logK = logK + sin(pi* abs(bsxfun(@minus,a(:,i),b(:,i)' ) /obj.period(i))).^2/obj.bandwidth(i)^2;
            %end
            % 
            %K = obj.scale * exp(-logK);            

        end
        
        function proj = getFourierProjection(obj, numFeatures, randStream,x )
            % note - I can't find / calculate fourier transform.
            % but - this kernel is just a squared exponential on features:
            % [sin(a), cos(a)]:
            % 2*sin^2(abs(a-b)) = 2 - 2 sin(a)sin(b) -2 cos(a)cos(b)
            % so we can take sin and cos features and multiply those with
            % normal samples...
            
            
            s = RandStream.getGlobalStream;
            RandStream.setGlobalStream(randStream);
            cov = diag(1./[obj.bandWidth(:);obj.bandWidth(:)].^2);
            omega = mvnrnd(zeros(1,obj.numDims*2),cov ,numFeatures);
            RandStream.setGlobalStream(s);
            
            proj = [cos(x), sin(x)] * omega';
        end
                

    end    
 
    
end

