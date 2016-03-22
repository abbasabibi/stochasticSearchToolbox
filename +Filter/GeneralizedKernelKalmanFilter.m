classdef GeneralizedKernelKalmanFilter < Filter.LinearKalmanFilter
    %GENERALIZEDKERNELKALMANFILTER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (AbortSet, SetObservable)
        enableConstCovApprox = false;
    end
    
    properties
        name = 'GKKF';
        
        K11
        K12
        K22
        Ko1
        Ko2
        Koo
        
        data1
        data2
        dataO
        
        winKernelReferenceSet
        obsKernelReferenceSet
        embeddingFunction
        G
        L22
        outputTransMatrix
        M_cov = 0;
        outputData
        
        obs_O
        obs_R
        obs_GO
        obs_tag = -1;
        
        traceCov = 1e20;
        assumeCovConst = false;
        Q
    end
    
    methods
        function obj = GeneralizedKernelKalmanFilter(dataManager, winKernelReferenceSet, obsKernelReferenceSet, name)
            
            obj = obj@Filter.LinearKalmanFilter(dataManager, winKernelReferenceSet.getReferenceSetSize(), obsKernelReferenceSet.getReferenceSetSize());
            
            obj.winKernelReferenceSet = winKernelReferenceSet;
            obj.obsKernelReferenceSet = obsKernelReferenceSet;
            
            if exist('name', 'var')
                obj.name = name;
            end
            
            obj.linkProperty('enableConstCovApprox',[obj.name '_enableConstCovApprox']);
        end
        
        function [newMean, newCov] = observation(obj, mean, cov, obs)
            
            if obj.obs_tag ~= obj.observationModelTag
                obj.obs_tag = obj.observationModelTag;
                obj.obs_O = obj.observationModel.weights();
                obj.obs_R = obj.observationModel.getCovariance();
                obj.obs_GO = obj.G * obj.obs_O;
            end
            
            if ~obj.assumeCovConst
                OS = obj.obs_O * cov;
                obj.Q = OS' / (obj.obs_GO * OS' + obj.obs_R);
            end
            
            g = obj.obsKernelReferenceSet.getKernelVectors(obs);
            newMean = mean + obj.Q * (g - obj.obs_GO * mean);
                
            newCov = cov - obj.Q * obj.obs_GO * cov;
            newCov = .5 * (newCov + newCov');
            [V,D] = eig(newCov);
            D(D < (1e-16 * max(D(:)))) = 1e-16 * max(D(:));
            newCov = V * D * V';
            
            if obj.enableConstCovApprox
                traceNewCov = sum(trace(newCov));
                if abs(obj.traceCov - traceNewCov) < 1e-9
                    obj.assumeCovConst = true;
                end
                obj.traceCov = traceNewCov;
            end
        end
        
        function [xMean, xCov] = outputTransformation(obj,mean,cov,outputIdx)
            xMean = cell(length(outputIdx),1);
            if nargout >= 2
                xCov = cell(length(outputIdx),1);
            end
            
            for i = outputIdx%1:ceil(nargout/2)
                M = obj.outputTransMatrix{i};
                xMean{i} = M * mean;
                if nargout >= 2
                    xCov{i} = M * cov * M' + obj.M_cov;
                end
            end
        end
        
        function [m] = getEmbeddings(obj,x)
            m = obj.L22 * obj.embeddingFunction(x);
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
        
    end
    
    methods (Access=protected)
        function obj = beforeFiltering(obj)
            obj.assumeCovConst = false;
        end
    end
    
end

