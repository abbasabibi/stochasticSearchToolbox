classdef CEOKernelKalmanFilter < Filter.LinearKalmanFilter
    %GENERALIZEDKERNELKALMANFILTER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        q
        r
        
        kernelReferenceSet
        
        M
        L
        data2
        outputData
        
        name = 'CEOKKF';
    end
    
    methods
        function obj = CEOKernelKalmanFilter(dataManager, kernelReferenceSet, name)
            obj = obj@Filter.LinearKalmanFilter(dataManager, kernelReferenceSet.getReferenceSetSize(), kernelReferenceSet.getReferenceSetSize());
            
            obj.kernelReferenceSet = kernelReferenceSet;
            
            if exist('name','var')
                obj.name = name;
            end
        end
        
        function [newMean, newCov] = transition(obj, mean, cov)
            if obj.transitionModelTag ~= obj.tr_Ftag
                obj.tr_Ftag = obj.transitionModelTag;
                obj.tr_F = obj.transitionModel.weights();
                obj.tr_f = obj.transitionModel.bias();
            end
            
            newMean = obj.tr_F * mean;
            if nargin > 2
                if obj.transitionModelTag ~= obj.tr_Fcovtag
                    obj.tr_Fcovtag = obj.transitionModelTag;
                    obj.tr_Fcov = obj.transitionModel.getCovariance();
                end
                newCov = obj.tr_F * cov * obj.tr_F' + obj.tr_Fcov;
                newCov = .5 * (newCov + newCov');
            end
        end
        
        function [newMean, newCov] = transitionObserved(obj, mean, cov, obs)
            if obj.transitionModelTag ~= obj.tr_Ftag
                obj.tr_Ftag = obj.transitionModelTag;
                obj.tr_F = obj.transitionModel.weights();
                obj.tr_f = obj.transitionModel.bias();
                obj.tr_Fcov = obj.transitionModel.getCovariance();
            end
            
            newMean = obj.tr_F * mean + obj.q/(obj.q+obj.r) * obj.L * obj.kernelReferenceSet.getKernelVectors(obs);
            newCov = obj.tr_F * cov * obj.tr_F' + obj.q*obj.r/(obj.q+obj.r) * obj.tr_Fcov;
            newCov = .5 * (newCov + newCov');
        end

        function [newMean, newCov] = observation(obj, mean, cov, obs)
            q_r = obj.q + obj.r;
            Gi = ((q_r)*eye(size(obj.M)) + cov * obj.M) \ cov;
            newCov = obj.r/q_r * (cov - Gi * obj.M * cov - obj.q*Gi);
            g = obj.kernelReferenceSet.kernel.getGramMatrix(obj.data2,obs);
            newMean = obj.r/q_r * (mean + Gi * obj.M * mean + Gi * g);
        end
        
        function [mus, vars] = filterData(obj, observations, observationPoints, outputIdx)
            if not(exist('outputIdx','var'))
                outputIdx = 1:length(obj.outputDims);
            end
            
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
            
            observations = permute(observations,[3,2,1]);
            
            if nargin < 3
                observationPoints = true(T,1);
            else
                observationPoints = logical(observationPoints);
            end
            
            for t = 1:T
                if observationPoints(t)
                    [mean, cov] = obj.observation(mean,cov,observations(:,:,t));
                
                    [xMu, xCov] = obj.outputTransformationObserved(mean,cov,observations(:,:,t),outputIdx);
                
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
                    
                    [mean, cov] = obj.transitionObserved(mean,cov,observations(:,:,t));
                else
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

                    [mean, cov] = obj.transition(mean,cov);
                end
            end
        end
        
        function [xMean, xCov] = outputTransformation(obj,mean,cov,outputIdx)
            xMean = cell(length(outputIdx),1);
            if nargout >= 2
                xCov = cell(length(outputIdx),1);
            end
            
            for i = outputIdx%1:ceil(nargout/2)
                oD = obj.outputData{i}';
                xMean{i} = oD * mean;
                if nargout >= 2
                    xCov{i} = oD * cov * oD';
                end
            end
        end
        
        function [xMean, xCov] = outputTransformationObserved(obj,mean,cov,obs,outputIdx)
            xMean = cell(length(outputIdx),1);
            if nargout >= 2
                xCov = cell(length(outputIdx),1);
            end
            
            for i = outputIdx%1:ceil(nargout/2)
                oD = obj.outputData{i}';
                xMean{i} = oD * mean + (obj.q / (obj.q + obj.r)) * obs';
%                 xMean{i} = oD * mean;
                if nargout >= 2
                    xCov{i} = oD * cov * oD';
                end
            end
        end
        
        function [m] = getEmbeddings(obj,x)
            m = obj.L * obj.kernelReferenceSet.getKernelVectors(x);
        end
    end
    
end

