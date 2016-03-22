classdef SubSpaceKernelBayesFilter < Filter.RegGeneralizedKernelKalmanFilter
    %BAYESGENERALIZEDKERNELKALMANFILTER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (AbortSet, SetObservable)
        D
        LK
        DLK
    end
    
    properties (AbortSet, SetObservable)
        normalization = false;
    end
    
    methods
        function obj = SubSpaceKernelBayesFilter(varargin)
            obj = obj@Filter.RegGeneralizedKernelKalmanFilter(varargin{:});
            
            obj.linkProperty('normalization',[obj.name '_normalization']);
        end
        
        function [newMean, newCov] = observation(obj, mean, cov, obs)
            
%             if obj.obs_tag ~= obj.observationModelTag
%                 obj.obs_tag = obj.observationModelTag;
%                 obj.obs_O = obj.observationModel.weights();
%                 obj.obs_R = obj.observationModel.getCovariance();
%                 obj.obs_GO = obj.G * obj.obs_O;
%             end
            
            alpha = permute(mean,[1,3,2]);
            
%             N = size(mean,2);
%             D = obj.Kro * obj.G * obj.Kro';
%             LK = obj.Lrr * obj.Kro;
            alphaKL = bsxfun(@times,alpha,obj.LK');
%             DE = bsxfun(@times,obj.DLK,alphaKL);
            alphaKL_cell = num2cell(alphaKL,[1 2]);
            DE_cell = reshape(cellfun(@(A) obj.DLK * A,alphaKL_cell,'UniformOutput',false),1,[]);
%             DE2 = bsxfun(@plus,bsxfun(@times,DE,DE),obj.R);
%             DEinvDE2 = bsxfun(@rdivide,DE,DE2);
            
            
            g = obj.obsKernelReferenceSet.getKernelVectors(obs);
            g_cell = num2cell(g,[1]);
            
            LKDEinvDE2_ = cellfun(@(A,b) obj.LK' * ((A / (A * A + obj.R)) * (obj.Kro * b)),DE_cell,g_cell,'UniformOutput',false);
            newMean = mean .* cell2mat(LKDEinvDE2_);
            
            newCov = cov;
            
            if obj.normalization
                newMean = bsxfun(@rdivide,newMean,(max(newMean) - min(newMean)));
            end
        end
        
        function [xMean, xCov] = outputTransformation(obj,mean,cov,outputIdx)
            if not(exist('outputIdx','var'))
                outputIdx = 1;
            end
            
            xMean = cell(length(outputIdx),1);
            if nargout >= 2
                xCov = cell(length(outputIdx),1);
            end
            
            for i = outputIdx
                xMean{i} = obj.outputTransMatrix{i} * mean;
                if nargout >= 2
                    xCov{i} = obj.outputTransMatrix{i} * cov * obj.outputTransMatrix{i}' + obj.M_cov;
                end
            end
        end
    end
    
end

