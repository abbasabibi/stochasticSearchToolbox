classdef TransitionModelLearner < Learner.Learner & Data.DataManipulator & Learner.ParameterOptimization.HyperParameterObject
    %TRANSITIONMODELLEARNERSTD Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (AbortSet, SetObservable)
        lambdaT = 1e-6;
        alpha = 1e-4;
        learnTcov = false;
    end
    
    properties
        gkkf
    end
    
    methods
        function obj = TransitionModelLearner(dataManager, gkkf, features, varargin)
            obj = obj@Learner.Learner();
            obj = obj@Data.DataManipulator(dataManager);
            
            obj.gkkf = gkkf;
            
            obj.linkProperty('lambdaT',[gkkf.name '_lambdaT']);
            obj.linkProperty('alpha',[gkkf.name '_alpha']);
            obj.linkProperty('learnTcov',[gkkf.name '_learnTcov']);
            obj.unlinkProperty([gkkf.name '_lambdaT']);
            obj.unlinkProperty([gkkf.name '_alpha']);
            obj.unlinkProperty([gkkf.name '_learnTcov']);
            
            % register data manipulation functions
            obj.addDataManipulationFunction('learnTransitionModel', features, {});
            obj.addDataManipulationFunction('learnInitialValues', features, {}, true, true);
        end
        
        function learnTransitionModel(obj, data)
            data2 = data(obj.gkkf.winKernelReferenceSet.getReferenceSetIndices()+1,:);
            
            K12 = obj.gkkf.winKernelReferenceSet.getKernelVectors(data2);
            K11 = obj.gkkf.winKernelReferenceSet.getKernelMatrix();
            K22 = obj.gkkf.winKernelReferenceSet.kernel.getGramMatrix(data2,data2);
            obj.gkkf.K12 = K12;
            obj.gkkf.K11 = K11;
            obj.gkkf.K22 = K22;
            obj.gkkf.data1 = data(obj.gkkf.winKernelReferenceSet.getReferenceSetIndices(),:);
            obj.gkkf.data2 = data2;
            
            m = size(K11,1);
            obj.gkkf.L22 = (K22 + obj.lambdaT * eye(m)) \ eye(m);
            
            T = (K11 + obj.lambdaT * eye(m)) \ K12;
            
            % compute transition model error
            if obj.learnTcov
                T_cov = obj.alpha * eye(m);
            else
                A = obj.gkkf.L22 * K22 - eye(m);
                T_cov = (A * A') / m;
            end
            
            obj.gkkf.setTransitionModelWeightsBiasAndCov(T,zeros(size(T,1),1),T_cov);
            
            obj.gkkf.embeddingFunction = @(X) obj.gkkf.winKernelReferenceSet.kernel.getGramMatrix(data2,X);
        end
        
        function obj = learnInitialValues(obj, numElements, initialData)
            C = obj.gkkf.L22 * obj.gkkf.getKernelVectors2(initialData);
            obj.gkkf.initialMean = sum(C,2) / numElements;
            obj.gkkf.initialCov = cov(C');
        end
        
        function obj = updateModel(obj, data)            
            obj.callDataFunction('learnTransitionModel', data);
            
            validityEntry = obj.gkkf.winKernelReferenceSet.validityDataEntry;
            
            if data.dataManager.isDataAlias(validityEntry) || data.dataManager.isDataEntry(validityEntry)
                vdw = data.getDataEntry(validityEntry,1);
                ind = find(vdw, 1, 'first');
            else
                ind = 1;
            end
            
            obj.callDataFunction('learnInitialValues', data, :, ind);
        end
    end
    
    % methods from HyperParameterObject
    methods
        function [numParams] = getNumHyperParameters(obj)
            if obj.learnTcov
                numParams = 2;
            else
                numParams = 1;
            end
        end
        
        function [] = setHyperParameters(obj, params)
            obj.lambdaT = params(1);
            if obj.learnTcov
                obj.alpha = params(2);
            end
        end
        
        function [params] = getHyperParameters(obj)
            if obj.learnTcov
                params = [obj.lambdaT obj.alpha];
            else
                params = obj.lambdaT;
            end
        end
    end
end

