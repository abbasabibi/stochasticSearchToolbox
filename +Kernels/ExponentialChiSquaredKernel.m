classdef ExponentialChiSquaredKernel < Kernels.Kernel
    %EXPONENTIALCHISQUAREDKERNEL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        gamma = 1;
    end
    
    methods
        function obj = ExponentialChiSquaredKernel(dataManager, numDims, kernelName)
            obj = obj@Kernels.Kernel(dataManager, numDims, kernelName);
        end
    end
    
    methods
        function [params] = getHyperParameters(obj)
            params = obj.gamma;
        end
        
        function [numParams] = getNumHyperParameters(obj)
            numParams = 1;
        end
        
        function [] = setHyperParameters(obj, params)
            obj.gamma = params;
            obj.setHyperParameters@Kernels.Kernel(params);
        end
        
        function [G] = getGramMatrix(X, Y)
            M = bsxfun(@minus,X,permute(Y,[1,3,2]));
            P = bsxfun(@plus,X,permute(Y,[1,3,2]));
            
            
        end
        
        function [gradientMatrices, gramMatrix] = getKernelDerivParam(data)
            
        end
        
        function [g] = getKernelDerivData(refdata, curdata)
            
        end
        
        function obj_out = clone(obj)
            
        end
    end
end

