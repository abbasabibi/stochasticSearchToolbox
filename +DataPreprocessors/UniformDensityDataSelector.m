classdef UniformDensityDataSelector < DataPreprocessors.DataPreprocessor
    
    properties (SetObservable, AbortSet)
        numLocalDataPoints = 30;
    end
    
    properties
        dataManager
        dataEntryDensity
        kernel
        
        layer
        
        bandWidthSelector;
    end
    
    % Class methods
    methods
        function obj = UniformDensityDataSelector(dataManager, kernel, dataEntryDensity)
            obj.dataManager = dataManager;
            obj.kernel = kernel;
            obj.dataEntryDensity = dataEntryDensity;
            
            obj.layer = obj.dataManager.getDataEntryDepth(dataEntryDensity);
            obj.bandWidthSelector = Kernels.Learner.MedianBandwidthSelector(dataManager, kernel, [], dataEntryDensity);
            obj.linkProperty('numLocalDataPoints');
            obj.dataNamePreprocessor = 'uniformDensity';
        end
        
        function [newData] = preprocessData(obj, data)
            hyperParams = obj.kernel.getHyperParameters();
            obj.bandWidthSelector.updateModel(data);
            
            inputData = data.getDataEntry(obj.dataEntryDensity);
            
            maxSamples = 2000;
            
            referenceSet = [];
            keepIndices = [];
            dataDensity = [];
            
            for j = 1:ceil(size(inputData,1) / maxSamples)
                
                index1 = (j-1) * maxSamples + 1;
                index2 = min(j * maxSamples, size(inputData, 1));
                
                inputDataLocal = inputData(index1:index2, :);
                keepIndices = [keepIndices, index1:index2];
                
                if (~isempty(referenceSet))
                    kernelMatrixReferenceSet = obj.kernel.getGramMatrix(inputDataLocal, referenceSet);
                    dataDensity = dataDensity + sum(kernelMatrixReferenceSet);
                end
                
                kernelMatrix = obj.kernel.getGramMatrix(inputDataLocal, inputDataLocal);
                
                dataDensity = [dataDensity sum(tril(kernelMatrix))];
                referenceSet = [referenceSet; inputDataLocal];
                localIndices = dataDensity < obj.numLocalDataPoints;
                keepIndices = keepIndices(localIndices);
                referenceSet = referenceSet(localIndices, :);
                dataDensity = dataDensity(localIndices);
            end
            newData = obj.dataManager.getDataObject([1, length(keepIndices)]);
            
            if (obj.layer == 1)
                dataEntries = obj.dataManager.getDataEntries();
            else
                if (obj.layer == 2)
                    dataEntries = obj.dataManager.getSubDataManager().getDataEntries();
                else
                    assert(false);
                end
            end
            
            for i = 1:numel(dataEntries)
                if (~obj.dataManager.isFeature(dataEntries{i}.name))
                    dataMatrix = data.getDataEntryFlatIndex(dataEntries{i}.name, keepIndices);
                    newData.setDataEntry(dataEntries{i}.name, dataMatrix);
                end
            end
            newData.resetFeatureTags();
            obj.kernel.setHyperParameters(hyperParams);
            
            fprintf('Density Preprocessor: Kept %d out of %d samples\n', newData.getNumElementsForDepth(2), data.getNumElementsForDepth(2));
            
        end
        
        
    end
end
