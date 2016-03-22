classdef BlurringImageExponentialQuadraticKernel < Kernels.WindowedExponentialQuadraticKernel
    %EXPONENTIALQUADRAITCKERNEL aka Gaussian kernel, squared exponential
    % possibility to use ARD (default: yes)
    % possibility to normalize output weights (default: no)
    
    properties (SetObservable, AbortSet)
        imageFeatureName = '';
    end
    
    properties
    end
    
    methods 

        function obj = BlurringImageExponentialQuadraticKernel(dataManager, varargin)

            obj@Kernels.WindowedExponentialQuadraticKernel(dataManager, varargin{:});
            
            obj.linkProperty('imageFeatureName',[obj.kernelName '_imageFeatureName']);
        end
        
        function [params] = getHyperParameters(obj)
            params = obj.getHyperParameters@Kernels.WindowedExponentialQuadraticKernel();
            params = [params obj.dataManager.getFeatureGenerator(obj.imageFeatureName).bluramount];
        end
        
        function [numParams] = getNumHyperParameters(obj)
            numParams = obj.getNumHyperParameters@Kernels.WindowedExponentialQuadraticKernel() + 1;
        end
        
        function [] = setHyperParameters(obj, params)
            obj.setHyperParameters@Kernels.WindowedExponentialQuadraticKernel(params(1:end-1));
            
            obj.dataManager.getFeatureGenerator(obj.imageFeatureName).bluramount = params(end);
        end
        
        function obj_out = clone(obj)
           obj_out = obj.clone@Kernels.WindowedExponentialQuadraticKernel();
           obj_out.imageFeatureName = obj.imageFeatureName;
        end
        
    end    
 
    
end

