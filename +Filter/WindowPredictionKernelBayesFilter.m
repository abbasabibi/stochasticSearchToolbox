classdef WindowPredictionKernelBayesFilter < Filter.KernelBayesFilter & Filter.WindowPredictionGeneralizedKernelKalmanFilter
    %BAYESGENERALIZEDKERNELKALMANFILTER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function obj = WindowPredictionKernelBayesFilter(varargin)
            obj = obj@Filter.KernelBayesFilter(varargin{:});
            obj = obj@Filter.WindowPredictionGeneralizedKernelKalmanFilter(varargin{:});
        end
        
        function [newMean, newCov] = observation(obj, mean, cov, obs)
            
            if obj.obs_tag ~= obj.observationModelTag
                obj.obs_tag = obj.observationModelTag;
                obj.obs_O = obj.observationModel.weights();
                obj.obs_R = obj.observationModel.getCovariance();
%                 obj.obs_GO = obj.G * obj.obs_O;
            end
            
            N = size(mean,2);
%             K = obj.K_1;
            D = obj.L22 * obj.K22 * mean;
%             D_ = cov;
            g = obj.obsKernelReferenceSet.getKernelVectors(obs);
            
%             DG = D * G;
%             newMean = DG / (DG^2 + obj.kappa * eye(size(DK))) * D * g;
            
            DG = bsxfun(@times,permute(D,[1,3,2]),obj.G);
            DG_cell = num2cell(DG,[1,2]);
            Dg_cell = num2cell(permute(D .* g,[1,3,2]),1);
            
            postMean_cell = cellfun(@(A,b) A/(A^2 + obj.obs_R) * b,DG_cell,Dg_cell,'UniformOutput',false);
            
%             GD = bsxfun(@times,obj.G,reshape(D_,1,[],N));
%             GD_cell = num2cell(GD,[1,2]);
%             KD = bsxfun(@times,K,reshape(D_,1,[],N));
%             KD_cell = num2cell(KD,[1,2]);
%             Dg_cell = num2cell(reshape(D_.*g_obs,[],1,N),1);
%             
%             postMean_cell = cellfun(@(A,B,c) A/(B + obj.kappa * eye(obj.kernel_size)) * c,KD_cell,GD_cell,Dg_cell,'UniformOutput',false);
            
            newMean = cell2mat(reshape(postMean_cell,[],N));
            
            newCov = cov;
        end
    end
    
end

