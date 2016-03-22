classdef LinearKernel < Kernels.Kernel
    %LINEARKERNEL simple linear kernel
    
    properties
        scale;
        offset;
    end
    
    methods

        function obj = LinearKernel(dataManager, numDims, name)


            obj@Kernels.Kernel(dataManager, numDims, name);
            obj.scale = 1;  
            obj.offset = 0;
        end
        
        function [params] = getHyperParameters(obj)

            params = [obj.scale obj.offset];

        end
        
        function n = getNumHyperParameters(obj)
            n = 2;
        end
        
        function [K] = getGramMatrix(obj, a, b)

            K = obj.scale * a * b' + obj.offset;

        end
        
        function [] = setHyperParameters(obj, params)
            obj.scale = params(1);
            obj.offset = params(2);
        end
             
        
        function [gradientMatrices, gramMatrix] = getKernelDerivParam(obj, data)
            gramMatrix = obj.getGramMatrix(data, data);
            
            gradientMatrices = zeros(size(gramMatrix, 1), size(gramMatrix, 2), obj.getNumHyperParameters());
                
            gradientMatrices(:,:,1) = (gramMatrix-obj.offset )/obj.scale;                  
            gradientMatrices(:,:,2) = ones(size(gramMatrix));
        end
        
        
        function [g] = getKernelDerivData(refdata, curdata, precompute)
            error('not implemented yet')
        end
        
    end   
end


