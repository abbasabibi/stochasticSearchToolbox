classdef ExtendedKalmanSmoother < Filter.ExtendedKalmanFilter & Smoother.LinearKalmanSmoother
    %EXTENDEDKALMANSMOOTHER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function obj = ExtendedKalmanSmoother(dataManager, environment, stateDim, obsDim)
            obj = obj@Filter.ExtendedKalmanFilter(dataManager, environment, stateDim, obsDim);
            obj = obj@Smoother.LinearKalmanSmoother(dataManager, stateDim, obsDim);
        end
        
        function initSmoothing(obj, observationNames, outputNames, outputDims)
            obj.initSmoothing@Smoother.LinearKalmanSmoother(observationNames, outputNames, outputDims);
            
            obj.addDataManipulationFunction('initializeMeanAndCov','states',{});
        end
    end
    
end

