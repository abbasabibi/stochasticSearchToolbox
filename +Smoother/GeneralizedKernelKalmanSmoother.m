classdef GeneralizedKernelKalmanSmoother < Filter.GeneralizedKernelKalmanFilter & Smoother.LinearKalmanSmoother
    %GENERALIZEDKERNELKALMANFILTER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function obj = GeneralizedKernelKalmanSmoother(dataManager, winKernelReferenceSet, obsKernelReferenceSet, name)
            
            if ~exist('name', 'var')
                name = 'GKKS';
            end
            
            obj = obj@Filter.GeneralizedKernelKalmanFilter(dataManager, winKernelReferenceSet, obsKernelReferenceSet, name);
            obj = obj@Smoother.LinearKalmanSmoother(dataManager, winKernelReferenceSet.getReferenceSetSize(), obsKernelReferenceSet.getReferenceSetSize());
        end        
    end
    
end

