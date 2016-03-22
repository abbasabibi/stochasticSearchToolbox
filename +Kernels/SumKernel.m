classdef SumKernel < Kernels.CompositeKernel
    %Sum of kernels 
    

    
    methods 
        function obj = SumKernel(dataManager, numDims, kernels, stateIndices,name)

            obj@Kernels.CompositeKernel(dataManager, numDims,kernels,stateIndices, name);
      
        end
        
 
        
        function [K] = getGramMatrix(obj, a, b)
            K = ones(size(a,1), size(b,1));
            for i = 1:size(obj.kernels,2)
                K = K + obj.kernels{i}.getGramMatrix(a(:,obj.stateIndices{i}), b(:,obj.stateIndices{i}));
            end
        end
        

        
        function gradientMatrices = getKernelDerivParam(obj, data)
            % all kernel derivatives are zero except for the one
            % to which paramidx applies!
            
            % get index of kernel to derive
            % and index of paramidx within the kernel
                        
            gradientMatrices = zeros(size(data, 1), size(data,1), obj.getNumHyperParameters());
            paramIndex = 1;            
            
            for i = 1:size(obj.kernels,2)
                paramIndexes = paramIndex:(paramIndex+obj.kernels{i}.getNumHyperParameters-1);
                paramIndex = paramIndex + obj.kernels{i}.getNumHyperParameters;               
                gradientMatrices(:,:,paramIndexes) = obj.kernels{i}.getKernelDerivParam(data(:,obj.stateIndices{i} ));
            end  

        end
        

        
        function [g] = getKernelDerivData(refdata, curdata, precompute)
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

