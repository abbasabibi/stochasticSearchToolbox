classdef ExpQuadExpQuadLinearKernel < Kernels.SumKernel
    %EXPQUADLINEARKERNEL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        expQuadLinKernel
        expQuadKernel
        ARD = true;
    end
    
    methods
        function obj = ExpQuadExpQuadLinearKernel(dataManager, numDims, kernelName)
            obj = obj@Kernels.SumKernel(dataManager, numDims, {}, {}, kernelName);
            
            obj.expQuadLinKernel = Kernels.ExpQuadLinearKernel(dataManager, numDims, [kernelName 'ExpQuadLin']);
            obj.expQuadKernel = Kernels.ExponentialQuadraticKernel(dataManager, numDims, [kernelName 'ExpQuad']);
            
            obj.kernels = {obj.expQuadLinKernel obj.expQuadKernel};
            obj.stateIndices = {1:numDims, 1:numDims};
        end
        
        
        function [params] = getBandWidth(obj)
            params = [obj.expQuadLinKernel.getBandWidth() obj.expQuadKernel.getBandWidth()];
        end
        
        function [] = setBandWidth(obj, params)
            numBandwidthParams = length(obj.getBandWidth());
            if numBandwidthParams == length(params)
                obj.expQuadLinKernel.setBandWidth(params(1:end/2));
                obj.expQuadKernel.setBandWidth(params(end/2+1:end));
            else
                obj.expQuadLinKernel.setBandWidth(params);
                obj.expQuadKernel.setBandWidth(params);
            end
        end
    end
    
end

