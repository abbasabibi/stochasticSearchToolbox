classdef WindowPredictionExtendedKalmanFilter < Filter.ExtendedKalmanFilter
    %EXTENDEDKALMANAFILTER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        windowSize
    end
    
    methods
        function obj = WindowPredictionExtendedKalmanFilter(dataManager, environment, stateDim, obsDim)
            obj = obj@Filter.ExtendedKalmanFilter(dataManager, environment, stateDim, obsDim);
            
            obj.environment = environment;
            
            obj.addDataManipulationFunction('initializeMeanAndCov','states',{});
        end
        
        function initFiltering(obj, observationNames, outputNames, outputDims)
            outputDims = cellfun(@(n) obj.windowSize * n, outputDims, 'UniformOutput', false);
            obj.initFiltering@Filter.ExtendedKalmanFilter(observationNames, outputNames, outputDims);
        end
        
        function [xMean, xCov] = outputTransformation(obj,mean,cov,outputIdx)
            xMean = zeros(obj.outputDims{1},size(mean,2));
            if nargin > 2 || nargout > 1
                xCov = zeros(obj.outputDims{1},obj.outputDims{1});
            end
            
            singleOutDim = size(obj.obs_H,1);
            
            for i = 1:obj.windowSize
                outputRange = (i-1)*singleOutDim+1:i*singleOutDim;
                obj.updateObservationModel(mean,[]);

                if nargin > 2 && nargout > 1
                    [m,c] = obj.outputTransformation@Filter.ExtendedKalmanFilter(mean,cov);
                    xMean(outputRange,:) = m';
                    xCov(outputRange,outputRange) = c;
                    obj.updateTransitionModel(mean,cov);
                    [mean, cov] = obj.transition(mean,cov);
                else
                    [m] = obj.outputTransformation@Filter.ExtendedKalmanFilter(mean,cov);
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

