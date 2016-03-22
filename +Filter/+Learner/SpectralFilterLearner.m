classdef SpectralFilterLearner < Learner.Learner & Data.DataManipulator & Learner.ParameterOptimization.HyperParameterObject
    %SPECTRALFILTERLEARNER Summary of this class goes here
    %   Detailed explanation goes here
    
    
    properties (AbortSet, SetObservable)
        outputDataName
%         
%         stateFeatureName = 'stateFeatures';
%         obsFeatureName = 'obsFeatures';
%         
%         stateFeatureSize
%         obsFeatureSize
        
        observations = 'observations';
        lambda = 1e-5;
        numEigenvectors
    end
    
    properties
        filter
        
        state1KRSL
        state2KRSL
        state3KRSL
        bandwidthSelector
        
        initialized = false
    end
    
    methods
        function obj = SpectralFilterLearner(dataManager, filter, numEigenvectors, features1, obsFeatures, outputNames, outputDims)
            obj = obj@Learner.Learner();
            obj = obj@Data.DataManipulator(dataManager);
            
            obj.filter = filter;
            obj.numEigenvectors = numEigenvectors;
            
            obj.addDataManipulationFunction('learnInitialMean', {features1}, {}, true, true);
            
            obj.outputDataName = features1;
            obj.linkProperty('outputDataName','spectralLearner_outputDataName');
            
            obj.linkProperty('lambda','spectralLearner_lambda');
            obj.linkProperty('numEigenvectors','spectralLearner_numEigenvectors');
            
            obj.linkProperty('observations',['spectralLearner_observations']);
            if ~iscell(obj.observations)
                obj.observations = {obj.observations};
            end
            
            obj.filter.initFiltering(obsFeatures, outputNames, outputDims)
        end
        
        function learnInitialMean(obj, m, data)
            K20 = obj.filter.state2KernelReferenceSet.getKernelVectors(data);
            obj.filter.initialMean = K20 * ones(m,1)./m;
        end
        
        function obj = initializeModel(obj, data)
            obj.bandwidthSelector.updateModel(data);
            
            obj.updateKernelReferenceSets(data);
            
            obj.initialized = true;
        end
        
        function obj = updateKernelReferenceSets(obj, data)
            obj.state1KRSL.updateModel(data);
            obj.state2KRSL.updateModel(data);
            obj.state3KRSL.updateModel(data);
            
            obj.updateOutputData(data);
        end
        
        function obj = updateOutputData(obj, data)
            outputDataIndices = obj.filter.state2KernelReferenceSet.getReferenceSetIndices();
            outputData = data.getDataEntry(obj.outputDataName);
            obj.filter.outputData = outputData(outputDataIndices,:);
        end
        
        function obj = updateModel(obj, data)
            if not(obj.initialized)
                obj.initializeModel(data);
            end
            
            K1 = obj.filter.state1KernelReferenceSet.getKernelMatrix();
            K1 = K1 + obj.lambda * eye(size(K1));
            R1 = chol(K1);
            
            K2 = obj.filter.state2KernelReferenceSet.getKernelMatrix();
            K2 = K2 + obj.lambda * eye(size(K2));
            
            [V, D] = eigs(R1 * K2 * R1', min(size(R1,1),obj.numEigenvectors));
            D = abs(D);
            
            K21 = obj.filter.state2KernelReferenceSet.getKernelVectors(obj.filter.state1KernelReferenceSet.getReferenceSet());
            K23 = obj.filter.state2KernelReferenceSet.getKernelVectors(obj.filter.state3KernelReferenceSet.getReferenceSet());
            iK2 = inv(K2);

            %      L*A * Omega^-1 * (L*A)'
            obj.filter.B = R1' * V * inv(D) * V' * R1;

            %   K  * L  *    L*A  * Omega^-2  *   (L*A)'
            obj.filter.A = K1 * K2 * R1' * V * inv(D.^2) *  V' * R1;
            
            obj.filter.K1 = K1;
            obj.filter.K2 = K2;
            obj.filter.K21 = K21;
            obj.filter.K23 = K23;
            obj.filter.iK2 = iK2;
            obj.filter.K2B = K2 * obj.filter.B;
            obj.filter.K12B = K21' * obj.filter.B;
            
            validityEntry = obj.filter.state1KernelReferenceSet.validityDataEntry;
            
            if data.dataManager.isDataAlias(validityEntry) || data.dataManager.isDataEntry(validityEntry)
                vdw = data.getDataEntry(validityEntry,1);
                ind = find(vdw, 1, 'first');
            else
                ind = 1;
            end
            
            obj.callDataFunction('learnInitialMean', data, :, ind);
        end
    end
    
    % methods from HyperParameterObject
    methods
        function [numParams] = getNumHyperParameters(obj)
            numParams = 1 + obj.filter.state1KernelReferenceSet.kernel.getNumHyperParameters();
        end
        
        function [] = setHyperParameters(obj, params)
            obj.lambda = params(1);
            obj.filter.state1KernelReferenceSet.kernel.setHyperParameters(params(2:end));
        end
        
        function [params] = getHyperParameters(obj)
            params = [obj.lambda obj.filter.state1KernelReferenceSet.kernel.getHyperParameters()];
        end
    end
end

