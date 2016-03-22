classdef ScaledBandwidthExponentialQuadraticKernel < Kernels.ExponentialQuadraticKernel
    %EXPONENTIALQUADRAITCKERNEL aka Gaussian kernel, squared exponential
    % possibility to use ARD (default: yes)
    % possibility to normalize output weights (default: no)
    
    properties (SetObservable, AbortSet)
        transparentBandwidth = false;
    end
    
    properties
        bandwidthFactor = 1;
        scaledBandwidth
    end
    
    methods 

        function obj = ScaledBandwidthExponentialQuadraticKernel(varargin)
            obj@Kernels.ExponentialQuadraticKernel(varargin{:});
            
            obj.scaledBandwidth = obj.bandWidth;
            
            obj.linkProperty('transparentBandwidth',[obj.kernelName '_transparentBandwidth']);
        end
        
        
        function [] = setBandwidthFactor(obj, bandwidthFactor)
            obj.bandwidthFactor = bandwidthFactor;
            obj.scaledBandwidth = obj.bandWidth * obj.bandwidthFactor;
            obj.kernelTag = obj.kernelTag + 1;
        end
        
        function bandwidth = getBandWidth(obj)
            bandwidth = obj.scaledBandwidth;
        end
        
        function [] = setBandWidth(obj, bandwidth)
            obj.setBandWidth@Kernels.ExponentialQuadraticKernel(bandwidth);
            obj.scaledBandwidth = obj.bandWidth * obj.bandwidthFactor;
        end
        
        function [bandwidthFactor] = getBandwidthFactor(obj)
            bandwidthFactor = obj.bandwidthFactor;
        end
        
        function [params] = getHyperParameters(obj)
            if obj.transparentBandwidth
                params = [obj.bandwidthFactor obj.getHyperParameters@Kernels.ExponentialQuadraticKernel()];
            else
                params = obj.bandwidthFactor;
            end
        end
        
        function [numParams] = getNumHyperParameters(obj)
            if obj.transparentBandwidth
                numParams = obj.getNumHyperParameters@Kernels.ExponentialQuadraticKernel() + 1;
            else
                numParams = 1;
            end
        end
        
        function [] = setHyperParameters(obj, params)
            obj.bandwidthFactor = params(1);
            obj.scaledBandwidth = obj.bandWidth * obj.bandwidthFactor;
            if obj.transparentBandwidth
                obj.setHyperParameters@Kernels.ExponentialQuadraticKernel(params(2:end));
            end
        end
        
        function obj_out = clone(obj)
           obj_out = obj.clone@Kernels.ExponentialQuadraticKernel();
           obj_out.bandwidthFactor = obj.bandwidthFactor;
           obj_out.scaledBandwidth = obj.scaledBandwidth;
           obj_out.transparentBandwidth = obj.transparentBandwidth;
        end
        
    end    
 
    
end

