classdef MonteCarloSmoother < Filter.MonteCarloFilter & Smoother.AbstractSmoother
    %MONTECARLOSMOOTHER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function obj = MonteCarloSmoother(dataManager, stateDims, obsDims)
            obj = obj@Filter.MonteCarloFilter(dataManager, stateDims, obsDims);
            obj = obj@Smoother.AbstractSmoother(dataManager, stateDims, obsDims);
        end
        
        function [mu, var] = smoothData(obj, observations, observationPoints)
            dataRaw = obj.dataBase.getDataEntry3D(obj.dataEntry);
            if size(observations,2) ~= size(dataRaw,2)
                observations = observations';
            end
            
            
            % compute the log-likelihood of the observations for each
            % sample trajectory
            logP_O_Y = -1 * ((bsxfun(@minus,permute(observations,[3,2,1]),dataRaw).^2)./(2* obj.obsNoise));
            % for each non-observed observation, set the distribution to
            % uniform
            logP_O_Y(:,not(logical(observationPoints)),:) = -log(size(dataRaw,1));
            % compute the sum of the log-likelihood (normal sum for smoothing).
            % Substract the max to prevent numerical
            % issues. Take the exp to obtain the likelihood
            pO_t = exp(bsxfun(@minus,sum(logP_O_Y,2),max(logP_O_Y,[],1)));
            % normalize for each time-step
            pt_O = bsxfun(@rdivide,pO_t,sum(pO_t,1));
            
            % weigh each time-step of the sample trajectories with the
            % probability of that trajectory in that time-step
            weightedEpisodes = bsxfun(@times,dataRaw,pt_O);
            % compute the weighted mean
            mu = sum(weightedEpisodes,1);
            % compute the weighted variance
            if obj.outputFullCovariance
                diffs = bsxfun(@minus,dataRaw,mu);
                outerProd = bsxfun(@times,bsxfun(@times,diffs,pt_O),permute(diffs,[1,2,4,3]));
                var = sum(outerProd,1);
            else
                var = sum(bsxfun(@times,bsxfun(@minus,dataRaw,mu).^2,pt_O),1);
            end
            
            if size(mu,3) > 1
                mu = permute(mu,[2,3,1]);
                var = permute(var,[2,3,4,1]);
            else
                mu = mu';
                var = var';
            end
        end
    end
    
end

