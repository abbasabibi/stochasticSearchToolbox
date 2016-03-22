classdef GeneralizedKernelKalmanSmootherLearner < Learner.Learner & Learner.ParameterOptimization.HyperParameterObject
    %GENERALIZEDKERNELKALMANFILTERLEARNER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (AbortSet, SetObservable)
        outputDataName
        
        stateFeatureName = 'stateFeatures';
        obsFeatureName = 'obsFeatures';
        
        stateFeatureSize
        obsFeatureSize
        
        stateKernelType = 'ExponentialQuadraticKernel';
        obsKernelType = 'ExponentialQuadraticKernel';
        
        conditionalOperatorType = 'std';
        referenceSetLearnerType = 'greedy';
        
        observations = 'observations'
        
        windowPrediction = false;
    end
    
    properties
        name
        
        filter
        transitionModelLearner
        observationModelLearner
        
        stateKernelReferenceSet
        obsKernelReferenceSet
        reducedKernelReferenceSet
        
        stateKRSL
        obsKRSL
        reducedKRSL
        
        stateBandwidthSelector
        obsBandwidthSelector
        
        hyperParamObjects
        
        initialized = false;
    end
    
    methods
        function obj = GeneralizedKernelKalmanSmootherLearner(dataManager, name)
            obj = obj@Learner.Learner();
            obj = obj@Learner.ParameterOptimization.HyperParameterObject();
            
            obj.name = name;
            
            obj.linkProperty('outputDataName',[name '_outputDataName']);
            
            obj.linkProperty('stateFeatureName',[name '_stateFeatureName']);
            obj.linkProperty('obsFeatureName',[name '_obsFeatureName']);
            
            obj.linkProperty('stateFeatureSize',[name '_stateFeatureSize']);
            obj.linkProperty('obsFeatureSize',[name '_obsFeatureSize']);
            
            obj.linkProperty('stateKernelType',[name '_stateKernelType']);
            obj.linkProperty('obsKernelType',[name '_obsKernelType']);
            
            obj.linkProperty('conditionalOperatorType',[name '_conditionalOperatorType']);
            obj.linkProperty('referenceSetLearnerType',[name '_referenceSetLearnerType']);
            
            obj.linkProperty('observations',[name '_observations']);
            if ~iscell(obj.observations)
                obj.observations = {obj.observations};
            end
            
            obj.linkProperty('windowPrediction',[name '_windowPrediction']);
            
            numOutputDimensions = length(obj.outputDataName);
            outputDimensions = cell(numOutputDimensions,1);
            for i = 1:numOutputDimensions
                outputDimensions{i} = dataManager.getNumDimensions(obj.outputDataName{i});
            end
            
            stateKernel = Kernels.(obj.stateKernelType)(dataManager, obj.stateFeatureSize, 'stateKernel');
            obsKernel = Kernels.(obj.obsKernelType)(dataManager, obj.obsFeatureSize, 'obsKernel');
            
            obj.stateKernelReferenceSet = Kernels.KernelReferenceSet(stateKernel, 'stateKRS');
            obj.stateKernelReferenceSet.inputDataEntryReferenceSet = obj.stateFeatureName;
            obj.obsKernelReferenceSet = Kernels.KernelReferenceSet(obsKernel, 'obsKRS');
            obj.obsKernelReferenceSet.inputDataEntryReferenceSet = obj.obsFeatureName;
            obj.reducedKernelReferenceSet = Kernels.KernelReferenceSet(stateKernel, 'reducedKRS');
            obj.stateKernelReferenceSet.inputDataEntryReferenceSet = obj.stateFeatureName;

            switch (obj.conditionalOperatorType)
                case 'std'
                    switch (obj.referenceSetLearnerType)
                        case 'greedy'
                            obj.stateKRSL = Kernels.Learner.GreedyKernelReferenceSetLearner(dataManager, obj.stateKernelReferenceSet);
                            obj.obsKRSL = Kernels.Learner.GreedyKernelReferenceSetLearner(dataManager, obj.obsKernelReferenceSet);
                        case 'random'
                            obj.stateKRSL = Kernels.Learner.RandomKernelReferenceSetLearner(dataManager, obj.stateKernelReferenceSet);
                            obj.obsKRSL = Kernels.Learner.RandomKernelReferenceSetLearner(dataManager, obj.obsKernelReferenceSet);
                    end
                    if obj.windowPrediction
%                         obj.filter = Filter.WindowPredictionGeneralizedKernelKalmanFilter(dataManager, obj.stateKernelReferenceSet, obj.obsKernelReferenceSet);
                    else
                        obj.filter = Smoother.GeneralizedKernelKalmanSmoother(dataManager, obj.stateKernelReferenceSet, obj.obsKernelReferenceSet);
                    end
                    obj.transitionModelLearner = Filter.Learner.TransitionModelLearner(dataManager, obj.filter, obj.stateFeatureName, obj.reducedKernelReferenceSet);
                    obj.observationModelLearner = Filter.Learner.ObservationModelLearner(dataManager, obj.filter, obj.stateFeatureName, obj.reducedKernelReferenceSet);

                case 'reg'
                    obj.stateKRSL = Kernels.Learner.RandomKernelReferenceSetLearner(dataManager, obj.stateKernelReferenceSet);
                    obj.obsKRSL = Kernels.Learner.RandomKernelReferenceSetLearner(dataManager, obj.obsKernelReferenceSet);
                    switch (obj.referenceSetLearnerType)
                        case 'greedy'
                            obj.reducedKRSL = Kernels.Learner.GreedyKernelReferenceSetLearner(dataManager, obj.reducedKernelReferenceSet);
                        case 'random'
                            obj.reducedKRSL = Kernels.Learner.RandomKernelReferenceSetLearner(dataManager, obj.reducedKernelReferenceSet);
                    end
                    if obj.windowPrediction
%                         obj.filter = Filter.WindowPredictionRegGeneralizedKernelKalmanFilter(dataManager, obj.stateKernelReferenceSet, obj.obsKernelReferenceSet);
                    else
                        obj.filter = Smoother.RegGeneralizedKernelKalmanSmoother(dataManager, obj.stateKernelReferenceSet, obj.obsKernelReferenceSet);
                    end
                    obj.transitionModelLearner = Filter.Learner.TransitionModelLearnerReg(dataManager, obj.filter, obj.stateFeatureName, obj.reducedKernelReferenceSet);
                    obj.observationModelLearner = Filter.Learner.ObservationModelLearnerReg(dataManager, obj.filter, obj.stateFeatureName, obj.reducedKernelReferenceSet);
            end
            
            obj.stateBandwidthSelector = Kernels.Learner.RandomMedianBandwidthSelector(dataManager, obj.stateKernelReferenceSet);
            obj.obsBandwidthSelector = Kernels.Learner.RandomMedianBandwidthSelector(dataManager, obj.obsKernelReferenceSet);
            
            obj.hyperParamObjects = {obj.filter, stateKernel, obsKernel, obj.transitionModelLearner, obj.observationModelLearner};
            
            obj.filter.initFiltering(obj.observations, {'filteredMu', 'filteredVar'}, outputDimensions);
            obj.filter.initSmoothing(obj.observations, {'smoothedMu', 'smoothedVar'}, outputDimensions);
        end
        
        function obj = initializeModel(obj, data)
            obj.stateBandwidthSelector.updateModel(data);
            obj.obsBandwidthSelector.updateModel(data);
            
            obj.updateKernelReferenceSets(data);
            
            obj.initialized = true;
        end
        
        function obj = updateModel(obj, data)
            if not(obj.initialized)
                obj.initializeModel(data);
            end
            
            obj.transitionModelLearner.updateModel(data);
            obj.observationModelLearner.updateModel(data);
        end
        
        function obj = updateKernelReferenceSets(obj,data)
            obj.stateKRSL.updateModel(data);
            obj.obsKRSL.updateModel(data);
            if strcmp(obj.conditionalOperatorType,'reg')
                obj.reducedKRSL.updateModel(data);
            end
            
            obj.updateOutputData(data);
        end
        
        function obj = updateOutputData(obj, data)
            if iscell(obj.outputDataName)
                obj.filter.outputData = cell(length(obj.outputDataName),1);
                for i = 1:length(obj.outputDataName)
                    fullOutputData = data.getDataEntry(obj.outputDataName{i});
                    obj.filter.outputData{i} = fullOutputData(obj.obsKRSL.kernelReferenceSet.getReferenceSetIndices(),:);
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
            numParams = cellfun(@(x) x.getNumHyperParameters(),obj.hyperParamObjects, 'UniformOutput', true);
            numParams = sum(numParams);
        end
        
        function [] = setHyperParameters(obj, params)
            idx = 1;
            for o = obj.hyperParamObjects
                idx_end = o{1}.getNumHyperParameters() + idx - 1;
                o{1}.setHyperParameters(params(idx:idx_end));
                idx = idx_end + 1;
            end
        end
        
        function [params] = getHyperParameters(obj)
            params = cell2mat(cellfun(@(x) x.getHyperParameters(),obj.hyperParamObjects, 'UniformOutput', false));
        end
    end
end

