classdef UnscentedKalmanFilter < Filter.ExtendedKalmanFilter
    %EXTENDEDKALMANAFILTER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        alphaSquared
        kappa
        beta
        
        obs_sigma
        observationFunction
        useLinearObservationModel = true;
        
        lastX
    end
    
    methods
        function obj = UnscentedKalmanFilter(dataManager, environment, stateDim, obsDim)
            obj = obj@Filter.ExtendedKalmanFilter(dataManager, environment, stateDim, obsDim);
            
            obj.observationFunction = @(mean,noise) obj.observationModel.weights() * mean' + noise';
            
            obj.addDataManipulationFunction('initializeMeanAndCov','states',{});
        end
        
        function obj = initializeMeanAndCov(obj, data)
            obj.initialMean = mean(data)';
            obj.initialCov = cov(data);
        end
        
        function [newMean, newCov] = transition(obj, mean, cov)
%             sigma = obj.environment.getSystemNoiseCovariance(mean', zeros(1,obj.environment.dimAction), obj.environment.dt);
            sigma = obj.environment.getControlNoiseStd(mean', zeros(1,obj.environment.dimAction), obj.environment.dt);

            augMean = [mean; zeros(length(sigma),1)];
            augCov = blkdiag(cov,diag(sigma).^2);
            m = length(mean);
            L = length(augMean);
            nSigmaPoints = 2*L+1;
            
            lambda = obj.alphaSquared * (L + obj.kappa) - L;
            LLambda = L + lambda;
            
            B = chol(LLambda*augCov);% + 1e-1 * eye(L));
%             B = sqrtm(LLambda*augCov);
            
            x = zeros(nSigmaPoints,m);
            x(1,:) = obj.environment.getExpectedNextState(augMean(1:m)',augMean(m+1:end)');
            for i = 1:L
                s_ = augMean' + B(i,:);
                x(i+1,:) = obj.environment.getExpectedNextState(s_(1:m),s_(m+1:end));
                s_ = augMean' - B(i,:);
                x(i+1+L,:) = obj.environment.getExpectedNextState(s_(1:m),s_(m+1:end));
            end
            
            obj.lastX = x;
            
            w_s = 1/(LLambda) * ones(1,nSigmaPoints);
            w_s(1) = w_s(1) * lambda;
            w_s(2:end) = w_s(2:end) * .5;
            w_c = w_s;
            w_c(1) = w_c(1) + (1 - obj.alphaSquared + obj.beta);
            
            newMean = (w_s * x)';
            s_centered = bsxfun(@minus,x,newMean');
            newCov = s_centered'*(bsxfun(@times,w_c',s_centered));
            newCov = .5 * (newCov + newCov');
        end
        
        function [newMean, newCov] = observation(obj, mean, cov, obs)
            if obj.useLinearObservationModel
                [newMean, newCov] = obj.observation@Filter.ExtendedKalmanFilter(mean,cov,obs);
                return
            end
            cov = cov + eye(size(cov)) * 10^-8;
            augMean = [mean; zeros(length(obj.obs_sigma),1)];
            augCov = blkdiag(cov,obj.obs_sigma);
            m = length(mean);
            L = length(augMean);
            nSigmaPoints = 2*L+1;
            
            lambda = obj.alphaSquared * (L + obj.kappa) - L;
            LLambda = L + lambda;
            
            B = chol(LLambda*augCov);% + 1e-1 * eye(L));
%             B = sqrtm(LLambda*augCov);
            
            y = zeros(nSigmaPoints,length(obs));
            y(1,:) = obj.observationFunction(augMean(1:m)',augMean(m+1:end)');
            X = zeros(nSigmaPoints, L);
            for i = 1:L
                s_ = augMean' + B(i,:);
                X(i + 1,:) = B(i,:);
                y(i+1,:) = obj.observationFunction(s_(1:m),s_(m+1:end));
                s_ = augMean' - B(i,:);
                X(i + 1 + L,:) = - B(i,:);
                y(i+1+L,:) = obj.observationFunction(s_(1:m),s_(m+1:end));
            end
            
            w_s = 1/(LLambda) * ones(1,nSigmaPoints);
            w_s(1) = w_s(1) * lambda;
            w_s(2:end) = w_s(2:end) * .5;
            w_c = w_s;
            w_c(1) = w_c(1) + (1 - obj.alphaSquared + obj.beta);
            
            obsMean = (w_s * y)';
            y_centered = bsxfun(@minus,y,obsMean');
            obsCov = y_centered'*(bsxfun(@times,w_c',y_centered));
            
            if isempty(obj.lastX)
                obj.transition(mean,cov);
            end
            
%             x_centered = bsxfun(@minus,obj.lastX,mean');
            trsCov = X(:,1:m)'*(bsxfun(@times,w_c',y_centered));
            
            K = trsCov / obsCov;
            
            newMean = mean + K * (obs' - obsMean);
            newCov = cov - K * obsCov * K';
        end
        
        function [xMu, xCov] = outputTransformation(obj, mean, cov, outputIdx)
            if obj.useLinearObservationModel
                [xMu, xCov] = obj.outputTransformation@Filter.ExtendedKalmanFilter(mean, cov, outputIdx);
                return
            end
            cov = cov + eye(size(cov)) * 10^-8;
            augMean = [mean; zeros(length(obj.obs_sigma),1)];
            augCov = blkdiag(cov,obj.obs_sigma);
            m = length(mean);
            L = length(augMean);
            nSigmaPoints = 2*L+1;
            
            lambda = obj.alphaSquared * (L + obj.kappa) - L;
            LLambda = L + lambda;
            
            B = chol(LLambda*augCov);% + 1e-1 * eye(L));
%             B = sqrtm(LLambda*augCov);
            
            y = zeros(nSigmaPoints,obj.obsDims);
            y(1,:) = obj.observationFunction(augMean(1:m)',augMean(m+1:end)');
            X = zeros(nSigmaPoints, L);
            for i = 1:L
                s_ = augMean' + B(i,:);
                X(i + 1,:) = B(i,:);
                y(i+1,:) = obj.observationFunction(s_(1:m),s_(m+1:end));
                s_ = augMean' - B(i,:);
                X(i + 1 + L,:) = - B(i,:);
                y(i+1+L,:) = obj.observationFunction(s_(1:m),s_(m+1:end));
            end
            
            w_s = 1/(LLambda) * ones(1,nSigmaPoints);
            w_s(1) = w_s(1) * lambda;
            w_s(2:end) = w_s(2:end) * .5;
            w_c = w_s;
            w_c(1) = w_c(1) + (1 - obj.alphaSquared + obj.beta);
            
            xMu = (w_s * y)';
            y_centered = bsxfun(@minus,y,xMu');
            xCov = y_centered'*(bsxfun(@times,w_c',y_centered));
        end
    end
    
    
end

