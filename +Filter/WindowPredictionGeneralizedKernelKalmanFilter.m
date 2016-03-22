classdef WindowPredictionGeneralizedKernelKalmanFilter < Filter.GeneralizedKernelKalmanFilter
    %WINDOWPREDICTIONGENERALIZEDKERNELKALMANFILTER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (AbortSet, SetObservable)
        windowSize = 4;
    end
    
    methods
        function obj = WindowPredictionGeneralizedKernelKalmanFilter(dataManager, winKernelReferenceSet, obsKernelReferenceSet, varargin)
            obj = obj@Filter.GeneralizedKernelKalmanFilter(dataManager, winKernelReferenceSet, obsKernelReferenceSet, varargin{:});
            
            obj.windowSize = obj.winKernelReferenceSet.kernel.numDims / obj.obsKernelReferenceSet.kernel.numDims;
            obj.linkProperty('windowSize',[obj.name '_windowSize']);
        end
        
        function initFiltering(obj, observationNames, outputNames, outputDims)
            outputDims = cellfun(@(n) obj.windowSize * n, outputDims, 'UniformOutput', false);
            obj.initFiltering@Filter.GeneralizedKernelKalmanFilter(observationNames, outputNames, outputDims);
        end
        
        function [xMean, xCov] = outputTransformation(obj,mean,cov,outputIndex)
            xMean = zeros(obj.outputDims{1},size(mean,2));
            if nargin > 2 || nargout > 1
                xCov = zeros(obj.outputDims{1},obj.outputDims{1});
            end
            
            M = obj.outputTransMatrix{1} * obj.Ko2;
            singleOutDim = size(M,1);
            
            for i = 1:obj.windowSize
                outputRange = (i-1)*singleOutDim+1:i*singleOutDim;
                xMean(outputRange,:) = M * mean;

                if nargin > 2 && nargout > 1
                    xCov(outputRange,outputRange) = M * cov * M' + obj.M_cov;
                    [mean, cov] = obj.transition(mean,cov);
                else
                    mean = obj.transition(mean);
                end
            end
        end
    end
    
end

