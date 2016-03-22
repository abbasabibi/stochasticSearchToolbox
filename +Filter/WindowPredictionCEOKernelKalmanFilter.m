classdef WindowPredictionCEOKernelKalmanFilter < Filter.CEOKernelKalmanFilter
    
    properties (AbortSet, SetObservable)
        windowSize = 4;
    end
    
    methods
        function obj = WindowPredictionCEOKernelKalmanFilter(dataManager, kernelReferenceSet, varargin)
            obj = obj@Filter.CEOKernelKalmanFilter(dataManager, kernelReferenceSet, varargin{:});
            
            obj.windowSize = obj.kernelReferenceSet.kernel.numDims;
            
            obj.linkProperty('windowSize',[obj.name '_windowSize']);
        end
        
        function initFiltering(obj, observationNames, outputNames, outputDims)
            outputDims = {obj.windowSize * outputDims{1}};
            obj.initFiltering@Filter.CEOKernelKalmanFilter(observationNames, outputNames, outputDims);
        end
        
        function [xMean, xCov] = outputTransformationObserved(obj,mean,cov,obs,outputIdx)
            [xMean, xCov] = obj.outputTransformation(mean,cov,outputIdx);
            
            
            singleOutDim = size(obj.outputData{1},2);
            
%             xMean(1:singleOutDim,:) = xMean(1:singleOutDim,:) + (obj.q / (obj.q + obj.r)) * obs(1:size(xMean,2),1:singleOutDim)';
        end
        
        function [xMean, xCov] = outputTransformation(obj,mean,cov,outputIdx)
            xMean = zeros(obj.outputDims{1},size(mean,2));
            if nargin > 2 || nargout > 1
                xCov = zeros(obj.outputDims{1},obj.outputDims{1});
            end
            
            M = obj.outputData{1}';
            singleOutDim = size(M,1);
            
            for i = 1:obj.windowSize
                outputRange = (i-1)*singleOutDim+1:i*singleOutDim;
                xMean(outputRange,:) = M * mean;

                if nargin > 2 && nargout > 1
                    xCov(outputRange,outputRange) = M * cov * M';
                    [mean, cov] = obj.transition(mean,cov);
                else
                    mean = obj.transition(mean);
                end
            end
        end
    end
    
end