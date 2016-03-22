classdef WindowPredictionUnscentedKalmanFilter < Filter.UnscentedKalmanFilter
    %EXTENDEDKALMANAFILTER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        windowSize
    end
    
    methods
        function obj = WindowPredictionUnscentedKalmanFilter(dataManager, environment, stateDim, obsDim)
            obj = obj@Filter.UnscentedKalmanFilter(dataManager, environment, stateDim, obsDim);
            
            obj.environment = environment;
            
            obj.addDataManipulationFunction('initializeMeanAndCov','states',{});
        end
        
        function initFiltering(obj, observationNames, outputNames, outputDims)
            outputDims = cellfun(@(n) obj.windowSize * n, outputDims, 'UniformOutput', false);
            obj.initFiltering@Filter.UnscentedKalmanFilter(observationNames, outputNames, outputDims);
        end
        
        function [xMean, xCov] = outputTransformation(obj,mean,cov,outputIdx)
            xMean = zeros(obj.outputDims{1},size(mean,2));
            if nargin > 2 || nargout > 1
                xCov = zeros(obj.outputDims{1},obj.outputDims{1});
            end
            
            singleOutDim = obj.outputDims{1} / obj.windowSize;
            
            for i = 1:obj.windowSize
                outputRange = (i-1)*singleOutDim+1:i*singleOutDim;

                if nargin > 2 && nargout > 1
                    obj.updateObservationModel(mean,cov);
                    [m, c] = obj.outputTransformation@Filter.UnscentedKalmanFilter(mean,cov,1);
                    xMean(outputRange,:) = m';
                    xCov(outputRange,outputRange) = c;
                    
                    obj.updateTransitionModel(mean,cov);
                    [mean, cov] = obj.transition(mean,cov);
                else
                    obj.updateObservationModel(mean,cov);
                    [m] = obj.outputTransformation@Filter.UnscentedKalmanFilter(mean,[],1);
                    xMean(outputRange,:) = m';
                    
                    obj.updateTransitionModel(mean,[]);
                    mean = obj.transition(mean);
                end
            end
        end
    end
    
    methods (Access=protected) 

    end
    
end

