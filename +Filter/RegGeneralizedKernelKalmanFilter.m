classdef RegGeneralizedKernelKalmanFilter < Filter.GeneralizedKernelKalmanFilter
    %GENERALIZEDKERNELKALMANFILTER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        redKernelReferenceSet
        
        Kr1
        Kr2
        
        Kro
        Lrr
        GL
        R
    end
    
    methods
        function obj = RegGeneralizedKernelKalmanFilter(dataManager, winKernelReferenceSet, obsKernelReferenceSet, varargin)
            obj = obj@Filter.GeneralizedKernelKalmanFilter(dataManager, winKernelReferenceSet, obsKernelReferenceSet, varargin{:});
        end
        
        function [newMean, newCov] = observation(obj, mean, cov, obs)
%             GL = obj.observationModel.weights();
%             R = obj.observationModel.getCovariance();
            
            Q = cov * (obj.Lrr / (obj.GL * cov * obj.Lrr + obj.R));
            
            g = obj.obsKernelReferenceSet.getKernelVectors(obs);
            newMean = mean + Q * (obj.Kro * g - obj.GL * mean);
            
            newCov = cov - Q * obj.GL * cov;
            newCov = .5 * (newCov + newCov');
            [V,D] = eig(newCov);
            D(D < (1e-16 * max(D(:)))) = 1e-16 * max(D(:));
            newCov = V * D * V';
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
        
        function [m] = getEmbeddings(obj,x)
            m = obj.redKernelReferenceSet.getKernelVectors(x);
        end
        
        function K = getKernelVectors1(obj, data)
            K = obj.winKernelReferenceSet.getKernelVectors(data);
        end
        
        function K = getKernelVectors2(obj, data)
            K = obj.winKernelReferenceSet.kernel.getGramMatrix(obj.data2,data);
        end
        
        function K = getKernelVectorsO(obj, data)
            K = obj.winKernelReferenceSet.kernel.getGramMatrix(obj.dataO,data);
        end
        
        function K = getKernelVectorsR(obj, data)
            K = obj.redKernelReferenceSet.getKernelVectors(data);
        end
        
    end
    
end

