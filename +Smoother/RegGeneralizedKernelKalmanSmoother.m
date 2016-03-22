classdef RegGeneralizedKernelKalmanSmoother < Filter.RegGeneralizedKernelKalmanFilter & Smoother.GeneralizedKernelKalmanSmoother
    %GENERALIZEDKERNELKALMANFILTER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function obj = RegGeneralizedKernelKalmanSmoother(dataManager, winKernelReferenceSet, obsKernelReferenceSet, name)
            
            if ~exist('name', 'var')
                name = 'GKKS';
            end
            
            obj = obj@Filter.RegGeneralizedKernelKalmanFilter(dataManager, winKernelReferenceSet, obsKernelReferenceSet, name);
            obj = obj@Smoother.GeneralizedKernelKalmanSmoother(dataManager, winKernelReferenceSet, obsKernelReferenceSet, name);
        end        
    end
    
end

