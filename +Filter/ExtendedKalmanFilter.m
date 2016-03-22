classdef ExtendedKalmanFilter < Filter.LinearKalmanFilter
    %EXTENDEDKALMANAFILTER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        environment
    end
    
    methods
        function obj = ExtendedKalmanFilter(dataManager, environment, stateDim, obsDim)
            obj = obj@Filter.LinearKalmanFilter(dataManager, stateDim, obsDim);
            
            obj.environment = environment;
        end
        
        function initFiltering(obj, observationNames, outputNames, outputDims)
            obj.initFiltering@Filter.LinearKalmanFilter(observationNames, outputNames, outputDims);
            
            obj.addDataManipulationFunction('initializeMeanAndCov','states',{});
        end
        
        function obj = initializeMeanAndCov(obj, data)
            obj.initialMean = mean(data)';
            obj.initialCov = cov(data);
        end
        
        function [newMean, newCov] = transition(obj, mean, cov)
            [~, newCov] = obj.transition@Filter.LinearKalmanFilter(mean, cov);
            
            newMean = obj.environment.getExpectedNextState(mean', 0)';
        end
    end
    
    methods (Access=protected) 
        function obj = updateTransitionModel(obj, mean, cov)
            [f, F, Fu, controlNoise] = obj.environment.getLinearizedDynamics(mean', zeros(obj.environment.dimAction,1));
            Fcov = Fu * diag(controlNoise.^2) * Fu';
            obj.setTransitionModelWeightsBiasAndCov(F, f, Fcov);
        end
        
        function obj = updateObservationModel(obj, mean, cov)
            if obj.update_obs_model
                if isa(obj.environment,'Environments.Misc.PlanarForwardKinematics')
                    H = zeros(obj.obsDims,obj.stateDims);
                    H(:,1:2:end) = obj.environment.getJacobian(mean(1:2:end)');
                    e = obj.environment.getForwardKinematics(mean(1:2:end)')' - H * mean;
                    obj.setObservationModelWeightsBiasAndCov(H,e);
                end
            end
        end
    end
    
end

