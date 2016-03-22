classdef LinearKalmanFilter < Filter.AbstractKalmanFilter
    %LINEARKALMANFILTER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        tr_F
        tr_f
        tr_Fcov
        tr_Ftag = -1;
        tr_Fcovtag = -1;
        
        update_obs_model = true;
        obs_H
        obs_e
        obs_Hcov
        obs_Htag = -1;
    end
    
    methods
        function obj = LinearKalmanFilter(dataManager, stateDim, obsDim)
            obj = obj@Filter.AbstractKalmanFilter(dataManager, stateDim, obsDim);
        end
        
        function [newMean, newCov] = transition(obj, mean, cov)
            if obj.transitionModelTag ~= obj.tr_Ftag
                obj.tr_Ftag = obj.transitionModelTag;
                obj.tr_F = obj.transitionModel.weights();
                obj.tr_f = obj.transitionModel.bias();
            end
            
            newMean = bsxfun(@plus,obj.tr_F * mean,obj.tr_f);
            % save the covariance
            if nargin > 2
                if obj.transitionModelTag ~= obj.tr_Fcovtag
                    obj.tr_Fcovtag = obj.transitionModelTag;
                    obj.tr_Fcov = obj.transitionModel.getCovariance();
                end
                newCov = obj.tr_F * cov * obj.tr_F' + obj.tr_Fcov;
                
                newCov = .5 * (newCov + newCov');
            end
%             imagesc(newCov);
%             colorbar
%             pause;
        end
        
        function [newMean, newCov] = observation(obj, mean, cov, observation)
            if obj.obs_Htag ~= obj.observationModelTag
                obj.obs_Htag = obj.observationModelTag;
                obj.obs_H = obj.observationModel.weights();
                obj.obs_e = obj.observationModel.bias();
                obj.obs_Hcov = obj.observationModel.getCovariance();
            end
            Q = cov * obj.obs_H' / (obj.obs_H * cov * obj.obs_H' + obj.obs_Hcov);
            newMean = mean + Q * bsxfun(@minus,observation',obj.obs_H * mean + obj.obs_e);
            newCov = cov - Q * obj.obs_H * cov;
            newCov = .5 * (newCov + newCov');
            [V,D] = eig(newCov);
            D(D < (1e-16 * max(D(:)))) = 1e-16 * max(D(:));
            newCov = V * D * V';
        end
        
        function [xMu, xCov] = outputTransformation(obj, mean, cov, outputIdx)
            if obj.obs_Htag ~= obj.observationModelTag
                obj.obs_Htag = obj.observationModelTag;
                obj.obs_H = obj.observationModel.weights();
                obj.obs_e = obj.observationModel.bias();
                obj.obs_Hcov = obj.observationModel.getCovariance();
            end
            
            xMu = obj.obs_H * mean + obj.obs_e;
            
            if nargout > 1
                xCov = obj.obs_H * cov * obj.obs_H' + obj.obs_Hcov;
            end
        end
    end
    
end