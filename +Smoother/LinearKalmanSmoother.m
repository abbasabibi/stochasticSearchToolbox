classdef LinearKalmanSmoother < Filter.LinearKalmanFilter & Smoother.AbstractKalmanSmoother & Learner.ParameterOptimization.HyperParameterObject
    %LINEARKALMANSMOOTHER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        lambdaI = 1e-6;
    end
    
    methods
        function obj = LinearKalmanSmoother(dataManager, stateDim, obsDim)
            obj = obj@Filter.LinearKalmanFilter(dataManager, stateDim, obsDim);
            obj = obj@Smoother.AbstractKalmanSmoother(dataManager, stateDim, obsDim);
        end
        
        function [mean, cov] = smoothingStep(obj, mean, cov, fw_mean_po, fw_cov_po, fw_mean_pr, fw_cov_pr, inv_fw_cov_pr)
            F = obj.getTransitionModelWeightsBiasAndCov();
            
            if ~exist('inv_fw_cov_pr','var')
                C = fw_cov_po * F' / (fw_cov_pr + obj.lambdaI * eye(size(fw_cov_pr)));
            else
                C = fw_cov_po * F' * inv_fw_cov_pr;
            end
            
            mean = fw_mean_po + C * (mean - fw_mean_pr);
            cov = fw_cov_po + C * (cov - fw_cov_pr) * C';
            cov = .5 * (cov + cov');
            [V,D] = eig(cov);
            D(D < (1e-16 * max(D(:)))) = 1e-16 * max(D(:));
            cov = V * D * V';
        end
    end
    
    
    methods
        function [numParams] = getNumHyperParameters(obj)
            numParams = 1;
        end
        
        function [] = setHyperParameters(obj, params)
            obj.lambdaI = params;
        end
        
        function [params] = getHyperParameters(obj)
            params = obj.lambdaI;
        end
    end
    
end

