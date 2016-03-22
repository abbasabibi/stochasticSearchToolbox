classdef RationalQuadraticKernel < Kernels.Kernel
    %RATIONALQUADRATICKERNEL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties

        bandwidth;
        alpha;
    end
    
    methods

        function obj = RationalQuadraticKernel(dataManager, numFeatures, name)


            obj@Kernels.Kernel(dataManager, numFeatures, name);
            
            obj.bandwidth = 1;

            obj.alpha = 1;
            
                
        end
        
        function [params] = getHyperParameters(obj)

            params = [obj.bandwidth, obj.alpha];

        end
        
        function [] = setHyperParameters(obj, params)

            obj.bandwidth = params(1);
            obj.alpha = params(2);
        end
        
        function n = getNumHyperParameters(obj)
            n=2;
        end
        
        function [K] = getGramMatrix(obj, a, b)

            sqdist = getSquaredDist(obj, a,b);
            K = obj.scale*(1+sqdist/(2*obj.alpha*obj.bandwidth^2) ).^(-obj.alpha) ;

            
        end
        
        function d = getSquaredDist(obj, a, b)
            d = bsxfun ( @plus , sum ( a .* a, 2 ) ,sum ( b .* b , 2 )' ) -2* a * b'  ;
        end
        

        
        function g = getKernelDerivParam(obj, paramidx, data, precomputed)
            grammatrix = obj.getGramMatrix(data,data );
            squareddist = obj.getSquaredDist(data,data);
            g = zeros(size(gramMatrix, 1), size(gramMatrix, 2), obj.getNumHyperParameters());
            
            g(:,:,1) = grammatrixinternal/obj.scale;

            g(:,:,2) = squareddist.*grammatrix^(1/obj.alpha+1)/obj.bandwidth^3;

            d_div_2ak2 = squareddist / (2*obj.alpha*obj.bandwidth^2);
            tmp = squareddist./(2*obj.alpha*(1+d_div_2ak2)*obj.bandwidth^2 );
            g(:,:,3)  = grammatrix.*(tmp - log(1+d_div_2ak2 ));

        end
        
   
        

    end
    
end

