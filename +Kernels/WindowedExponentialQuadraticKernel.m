classdef WindowedExponentialQuadraticKernel < Kernels.ExponentialQuadraticKernel
    %WINDOWEDEXPONENTIALQUADRATICKERNEL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetObservable, AbortSet)
        numWindows = 1;
    end
    
    properties
        bandwidthConversionMatrix
        windowedBandwidth
    end
    
    methods
        function obj = WindowedExponentialQuadraticKernel(dataManager, numDims, kernelName, varargin)
            obj = obj@Kernels.ExponentialQuadraticKernel(dataManager, numDims, kernelName, varargin{:});
            
            obj.linkProperty('numWindows',[kernelName '_numWindows']);
            
            obj.bandwidthConversionMatrix = zeros(obj.numWindows,numDims);
            
            dimsPerWindow = ceil(numDims / obj.numWindows);
            windowStartIndices = 1:dimsPerWindow:numDims;
            windowEndIndices = [windowStartIndices(2:end)-1 numDims];
            obj.windowedBandwidth = ones(1,obj.numWindows);
            
            for i = 1:obj.numWindows
                startIdx = windowStartIndices(i);
                endIdx = windowEndIndices(i);
                obj.bandwidthConversionMatrix(i,startIdx:endIdx) = ones(1,endIdx-startIdx+1);
            end
        end
        
        function [] = setBandWidth(obj, bandWidth)
            bandWidth = reshape(bandWidth,1,[]);
            obj.windowedBandwidth = (obj.bandwidthConversionMatrix * bandWidth' ./ (size(obj.bandwidthConversionMatrix,2) / size(obj.bandwidthConversionMatrix,1)))';
            obj.bandWidth = obj.windowedBandwidth * obj.bandwidthConversionMatrix;
            obj.kernelTag = obj.kernelTag + 1;
        end
        
        function [params] = getHyperParameters(obj)
            params = obj.windowedBandwidth;
        end
        
        function [numParams] = getNumHyperParameters(obj)
            numParams = numel(obj.windowedBandwidth);
        end
        
        function [] = setHyperParameters(obj, params)
            obj.windowedBandwidth = reshape(params,1,[]);
            
            bandwidth = obj.windowedBandwidth * obj.bandwidthConversionMatrix;
            obj.setHyperParameters@Kernels.ExponentialQuadraticKernel(bandwidth);
        end
    end
    
end

