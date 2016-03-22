classdef CEOKernelKalmanFilterLearner < Learner.Learner & Data.DataManipulator & Learner.ParameterOptimization.HyperParameterObject
    %GENERALIZEDKERNELKALMANFILTERLEARNER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (AbortSet, SetObservable)
        outputDataName
        
        featureName = 'features';
        
        featureSize
        
        kernelType = 'ExponentialQuadraticKernel';
        
        observations = 'observations'
        
        sigma = 1e-6;
        lambda = 1e-6;
        
        q = 1e-0
        r = 1e-2;
        
        windowPrediction = false;
    end
    
    properties
        name 
        
        filter
        kernelReferenceSet
        kernelReferenceSetLearner
        bandwidthSelector
    end
    
    methods
        function obj = CEOKernelKalmanFilterLearner(dataManager, name)
            obj = obj@Learner.Learner();
            obj = obj@Data.DataManipulator(dataManager);
            
            obj.name = name;
            
            obj.linkProperty('outputDataName',[name '_outputDataName']);
            
            obj.linkProperty('featureName',[name '_featureName']);
            
            obj.linkProperty('featureSize',[name '_featureSize']);
            
            obj.linkProperty('kernelType',[name '_kernelType']);
            
            obj.linkProperty('observations',[name '_observations']);
            if ~iscell(obj.observations)
                obj.observations = {obj.observations};
            end
            
            obj.linkProperty('sigma',[name '_sigma']);
            obj.linkProperty('lambda',[name '_lambda']);
            obj.linkProperty('q',[name '_q']);
            obj.linkProperty('r',[name '_r']);
            
            obj.linkProperty('windowPrediction', [name '_windowPrediction']);
            
            
            numOutputDimensions = length(obj.outputDataName);
            outputDimensions = cell(numOutputDimensions,1);
            for i = 1:numOutputDimensions
                outputDimensions{i} = dataManager.getNumDimensions(obj.outputDataName{i});
            end
            
            kernel = Kernels.(obj.kernelType)(dataManager, obj.featureSize, 'kernel');
            
            obj.kernelReferenceSet = Kernels.KernelReferenceSet(kernel, 'kernelReferenceSet');
            obj.kernelReferenceSet.inputDataEntryReferenceSet = obj.featureName;
            obj.kernelReferenceSetLearner = Kernels.Learner.GreedyKernelReferenceSetLearner(dataManager, obj.kernelReferenceSet);

            obj.bandwidthSelector = Kernels.Learner.RandomMedianBandwidthSelector(dataManager, obj.kernelReferenceSet);
            
            if obj.windowPrediction
                obj.filter = Filter.WindowPredictionCEOKernelKalmanFilter(dataManager,obj.kernelReferenceSet);
            else
                obj.filter = Filter.CEOKernelKalmanFilter(dataManager,obj.kernelReferenceSet);
            end
            
            obj.addDataManipulationFunction('learnInitialValues', obj.featureName, {}, true, true);
            
            obj.filter.initFiltering(obj.observations, {'filteredMu', 'filteredVar'}, outputDimensions);
        end
        
        function obj = learnInitialValues(obj, m, data1)
            obj.filter.initialMean = obj.filter.L * obj.filter.kernelReferenceSet.getKernelVectors(data1) * ones(m,1) / m;
            obj.filter.initialCov = obj.lambda * obj.filter.L * obj.filter.kernelReferenceSet.getKernelMatrix() * obj.filter.L';
        end
        
        function obj = initializeModel(obj, data)
            obj.bandwidthSelector.updateModel(data);
            
            obj.updateKernelReferenceSets(data);
            
            obj.isInitialized = true;
        end
        
        function obj = updateModel(obj, data)
            if ~obj.isInitialized
                obj.initializeModel(data);
            end
            
            obj.filter.q = obj.q;
            obj.filter.r = obj.r;
            
            K = obj.filter.kernelReferenceSet.getKernelMatrix();
            T = obj.filter.kernelReferenceSet.getKernelVectors(obj.filter.data2);
            m = obj.filter.kernelReferenceSet.getReferenceSetSize();
            L = (K + obj.sigma * m * eye(m)) \ eye(m);
            C = (K + obj.sigma * m * eye(m)) \ T;
            C_cov = (K + obj.sigma * m * eye(m)) \ K / (K + obj.sigma * m * eye(m)); %(q*r/(q+r)) r = obj.filter.r; q = obj.filter.q;
            
            obj.filter.setTransitionModelWeightsBiasAndCov(C,zeros(size(T,1),1),C_cov);
            obj.filter.L = L;
            obj.filter.M = obj.kernelReferenceSet.kernel.getGramMatrix(obj.filter.data2,obj.filter.data2);
            
            episode1 = data.getDataEntry(obj.featureName,1);
            firstNonNan = find(not(any(isnan(episode1),2)),1);
            obj.callDataFunction('learnInitialValues',data,:,firstNonNan);
        end
        
        function obj = updateKernelReferenceSets(obj,data)
            obj.kernelReferenceSetLearner.updateModel(data);
            
            features = data.getDataEntry(obj.featureName);
            obj.filter.data2 = features(obj.kernelReferenceSet.getReferenceSetIndices()+1,:);
            
            obj.updateOutputData(data);
        end
        
        function obj = updateOutputData(obj, data)
            if iscell(obj.outputDataName)
                obj.filter.outputData = cell(length(obj.outputDataName),1);
                for i = 1:length(obj.outputDataName)
                    fullOutputData = data.getDataEntry(obj.outputDataName{i});
                    obj.filter.outputData{i} = fullOutputData(obj.kernelReferenceSetLearner.kernelReferenceSet.getReferenceSetIndices(),:);
                end
            else
                outputData = data.getDataEntry(obj.outputDataName);
                obj.filter.outputData = {outputData(obj.obsKRSL.kernelReferenceSet.getReferenceSetIndices(),:)};
            end
        end
    end
    
    % methods from HyperParameterObject
    methods
        function [numParams] = getNumHyperParameters(obj)
            numParams = 4 + obj.filter.kernelReferenceSet.kernel.getNumHyperParameters();
        end
        
        function [] = setHyperParameters(obj, params)
            obj.sigma = params(1);
            obj.lambda = params(2);
            obj.q = params(3);
            obj.r = params(4);
            obj.filter.kernelReferenceSet.kernel.setHyperParameters(params(5:end));
        end
        
        function [params] = getHyperParameters(obj)
            params = [obj.sigma obj.lambda obj.q obj.r obj.filter.kernelReferenceSet.kernel.getHyperParameters()];
        end
    end
    
end

