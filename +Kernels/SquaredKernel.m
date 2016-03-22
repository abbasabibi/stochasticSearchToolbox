classdef SquaredKernel < Kernels.CompositeKernel
    %SQUAREDKERNEL square of a given kernel
    

    
    methods

        function obj = SquaredKernel(dataManager, kernel, name)

            stateIndices= {1:kernel.numDims};
            
            obj@Kernels.CompositeKernel(dataManager, kernel.numDims, {kernel}, stateIndices,name);
            

        end
        

        
        function [K] = getGramMatrix(obj, a, b)

            K = obj.kernels{1}.getGramMatrix(a,b).^2;

        end
        

        

        
        function g = getKernelDerivParam(obj, data)
            subgrammatrix = obj.kernels{1}.getGramMatrix(data,data );

            g = 2 * bsxfun(@times, subgrammatrix, obj.kernels{1}.getKernelDerivParam(data));
        end
        
        function [g] = getKernelDerivData(refdata, curdata)
            error('not implemented yet')
        end

        
    end  
    
    methods(Access = protected)
        function cpObj = copyElement(obj)
            cpObj = copyElement@matlab.mixin.Copyable(obj);
            for i = 1:numel(obj.kernels)
                cpObj.kernels{i} = obj.kernels{i}.copy;
            end
        end
    end
end


