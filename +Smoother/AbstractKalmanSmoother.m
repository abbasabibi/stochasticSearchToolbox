classdef AbstractKalmanSmoother < Filter.AbstractKalmanFilter & Smoother.AbstractSmoother
    %ABSTRACTKALMANSMOOTHER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        inv_fw_cov_pr = [];
        inv_fw_cov_pr_avail = [];
    end
    
    methods
        function obj = AbstractKalmanSmoother(dataManager, stateDims, obsDims)
            obj = obj@Filter.AbstractKalmanFilter(dataManager, stateDims, obsDims);
            obj = obj@Smoother.AbstractSmoother(dataManager, stateDims, obsDims);
            
        end
        
        function [mus, vars] = smoothData(obj, observations, observationPoints, outputIdx)
            if not(exist('outputIdx','var'))
                outputIdx = 1:length(obj.outputDims);
            end
            
            obj.beforeFiltering();
            
            T = size(observations,1);
            N = size(observations,3);
            
            if size(obj.initialMean,2) == 1
                mean = repmat(obj.initialMean,1,N);
            else
                mean = obj.initialMean;
            end
            cov = obj.initialCov;
            
            fw_mean_po = zeros(obj.stateDims, N, T);
            fw_cov_po = zeros(obj.stateDims, obj.stateDims, T);
            fw_mean_pr = zeros(obj.stateDims, N, T);
            fw_cov_pr = zeros(obj.stateDims, obj.stateDims, T);
            if isempty(obj.inv_fw_cov_pr)
                obj.inv_fw_cov_pr = zeros(obj.stateDims, obj.stateDims, T);
                obj.inv_fw_cov_pr_avail = false(T,1);
            end
            
            mus = zeros(T, sum([obj.outputDims{outputIdx}]), N);
            if obj.outputFullCov
                vars = zeros(T, sum([obj.outputDims{outputIdx}]), sum([obj.outputDims{outputIdx}]), N);
            else
                vars = zeros(T, sum([obj.outputDims{outputIdx}]), N);
            end
            
            if nargin < 3
                observationPoints = true(T,1);
            else
                observationPoints = logical(observationPoints);
            end
            
            % forward pass
            for t = 1:T
                obj.updateObservationModel(mean,cov);
                if observationPoints(t)
                    [mean, cov] = obj.observation(mean,cov,permute(observations(t,:,:),[3,2,1]));
                end
                
                fw_mean_po(:,:,t) = mean;
                fw_cov_po(:,:,t) = cov;
                
                obj.updateTransitionModel(mean,cov);
                [mean, cov] = obj.transition(mean,cov);
                
                fw_mean_pr(:,:,t) = mean;
                fw_cov_pr(:,:,t) = cov;
            end
            
            % the smoothed estimate of the last time step is equal to the
            % filtered estimate.
            mean = fw_mean_po(:,:,t);
            cov = fw_cov_po(:,:,t);
            
            obj.updateObservationModel(mean,cov);
            [xMu, xCov] = obj.outputTransformation(mean,cov, outputIdx);

            if iscell(xMu)
                mus(t,:,:) = reshape(vertcat(xMu{:}),1,[],N);
            else
                mus(t,:,:) = reshape(xMu,1,[],N);
            end

            if obj.outputFullCov
                if iscell(xCov)
                    vars(t,:,:,:) = repmat(permute(blkdiag(xCov{:}),[3,1,2]),[1,1,1,N]);
                else
                    vars(t,:,:,:) = repmat(permute(xCov,[3,1,2]),[1,1,1,N]);
                end
            else
                if iscell(xCov)
                    vars(t,:,:) = repmat(diag(blkdiag(xCov{:}))',[1,1,N]);
                else
                    vars(t,:,:) = repmat(diag(xCov)',[1,1,N]);
                end
            end
            
            % backward pass
            for t = T-1:-1:1
%                 if ~obj.inv_fw_cov_pr_avail(t)
%                     obj.inv_fw_cov_pr(:,:,t) = inv(fw_cov_pr(:,:,t));
%                 end
%                 
%                 [mean, cov] = obj.smoothingStep(mean, cov, ...
%                     fw_mean_po(:,:,t), fw_cov_po(:,:,t), ...
%                     fw_mean_pr(:,:,t), fw_cov_pr(:,:,t), ...
%                     obj.inv_fw_cov_pr(:,:,t));
                obj.updateTransitionModel(fw_mean_po(:,:,t), fw_cov_po(:,:,t));
                [mean, cov] = obj.smoothingStep(mean, cov, ...
                    fw_mean_po(:,:,t), fw_cov_po(:,:,t), ...
                    fw_mean_pr(:,:,t), fw_cov_pr(:,:,t));
                
                obj.updateObservationModel(mean,cov);
                [xMu, xCov] = obj.outputTransformation(mean,cov, outputIdx);
                if iscell(xMu)
                    mus(t,:,:) = reshape(vertcat(xMu{:}),1,[],N);
                else
                    mus(t,:,:) = reshape(xMu,1,[],N);
                end
                
                if obj.outputFullCov
                    if iscell(xCov)
                        vars(t,:,:,:) = repmat(permute(blkdiag(xCov{:}),[3,1,2]),[1,1,1,N]);
                    else
                        vars(t,:,:,:) = repmat(permute(xCov,[3,1,2]),[1,1,1,N]);
                    end
                else
                    if iscell(xCov)
                        vars(t,:,:) = repmat(diag(blkdiag(xCov{:}))',[1,1,N]);
                    else
                        vars(t,:,:) = repmat(diag(xCov)',[1,1,N]);
                    end
                end
            end
            
            obj.afterFiltering();
        end
    end
   
    methods (Abstract)
        [mean, cov] = smoothingStep(obj, mean, cov, fw_mean_po, fw_cov_po, fw_mean_pr, fw_cov_pr, inv_fw_cov_pr);
    end
    
end

