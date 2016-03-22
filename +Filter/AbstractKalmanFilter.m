classdef AbstractKalmanFilter < Filter.AbstractFilter
    %ABSTRACTKALMANFILTER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        initialMean
        initialCov
        outputFullCov = false;
        stabilizeInitialLinearization = false;
    end
    
    properties (Access=protected)
        transitionModel
        observationModel
        
        transitionModelTag = 0;
        observationModelTag = 0;
    end
    
    methods
        function obj = AbstractKalmanFilter(dataManager, stateDims, obsDims)
            obj = obj@Filter.AbstractFilter(dataManager, stateDims, obsDims);
            
            obj.transitionModel = Distributions.Gaussian.GaussianLinearInFeatures(dataManager, stateDims, stateDims, 'transitionModel');
            obj.transitionModel.saveCovariance = true;
            obj.observationModel = Distributions.Gaussian.GaussianLinearInFeatures(dataManager, obsDims, stateDims, 'observationModel');
            obj.observationModel.saveCovariance = true;
        end
    
        function [mus, vars] = filterData(obj, observations, observationPoints, outputIdx)
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
            
            if obj.stabilizeInitialLinearization
                mean_ = mean;
                for i = 1:50
                    obj.updateObservationModel(mean_,cov);
                    [mean_, cov_] = obj.observation(mean_,cov,permute(observations(1,:,:),[3,2,1]));
                end
                mean = mean_;
            end
            
            for t = 1:T
                if not(t == 1 && obj.stabilizeInitialLinearization)
                    obj.updateObservationModel(mean,cov);
                end
                if observationPoints(t)
                    [mean, cov] = obj.observation(mean,cov,permute(observations(t,:,:),[3,2,1]));
                end
                
                [xMu, xCov] = obj.outputTransformation(mean,cov,outputIdx);
                
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
                
%                 plot(t,observations(t,:),'.b'); plot(t,mus(t,1),'.g');
                
                obj.updateTransitionModel(mean,cov);
                [mean, cov] = obj.transition(mean,cov);
            end
            
            obj.afterFiltering();
        end
        
        function [mu, cov] = outputTransformation(obj, mu, cov, outputIdx)
        end
        
        function [] = setTransitionModelWeightsBiasAndCov(obj, M, b, cov)
            [mOut, mIn] = size(M);
            obj.stateDims = mIn;
            obj.transitionModel.setInputVariables(mIn);
            obj.transitionModel.setOutputVariables(mOut);
            obj.transitionModel.setWeightsAndBias(M,b);
            obj.transitionModel.setCovariance(cov);
            obj.transitionModelTag = obj.transitionModelTag + 1;
        end
        
        function [] = setObservationModelWeightsBiasAndCov(obj, M, b, cov)
            [mOut, mIn] = size(M);
            obj.obsDims = mOut;
            obj.observationModel.setInputVariables(mIn);
            obj.observationModel.setOutputVariables(mOut);
            obj.observationModel.setWeightsAndBias(M,b);
            if nargin > 3
                obj.observationModel.setCovariance(cov);
            end
            obj.observationModelTag = obj.observationModelTag + 1;
        end
        
        function [W, b, C] = getTransitionModelWeightsBiasAndCov(obj)
            W = obj.transitionModel.weights();
            b = obj.transitionModel.bias();
            
            if nargout > 2
                C = obj.transitionModel.getCovariance();
            end
        end
        
        function [W, b, C] = getObservationModelWeightsBiasAndCov(obj)
            W = obj.observationModel.weights();
            b = obj.observationModel.bias();
            
            if nargout > 2
                C = obj.observationModel.getCovariance();
            end
        end
    end
    
    methods (Access=protected)
        function obj = updateTransitionModel(obj,mean,cov)
        end
        
        function obj = updateObservationModel(obj,mean,cov)
        end
        
        function obj = beforeFiltering(obj)
        end
        
        function obj = afterFiltering(obj)
        end
    end
    
    methods (Abstract)
        [mean, cov] = transition(obj, mean, cov);
        [mean, cov] = observation(obj, mean, cov, obs);
    end
    
end

