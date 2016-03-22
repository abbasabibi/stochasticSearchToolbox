classdef ExpQuadLinearKernel < Kernels.ProductKernel
    %EXPQUADLINEARKERNEL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        expQuadKernel
        linearKernel
        ARD = true;
    end
    
    methods
        function obj = ExpQuadLinearKernel(dataManager, numDims, kernelName)
            obj = obj@Kernels.ProductKernel(dataManager, numDims, {}, {}, kernelName);
            
            obj.expQuadKernel = Kernels.ExponentialQuadraticKernel(dataManager, numDims, [kernelName 'ExpQuad']);
            obj.linearKernel = Kernels.LinearKernel(dataManager, numDims, [kernelName 'Lin']);
            obj.linearKernel.offset = 1;
            
            obj.kernels = {obj.expQuadKernel obj.linearKernel};
            obj.stateIndices = {1:numDims, 1:numDims};
        end
        
        
        function [params] = getBandWidth(obj)
            params = obj.expQuadKernel.getBandWidth();
        end
        
        function [] = setBandWidth(obj, params)     
            obj.expQuadKernel.setBandWidth(params);
        end
    end
    
end

