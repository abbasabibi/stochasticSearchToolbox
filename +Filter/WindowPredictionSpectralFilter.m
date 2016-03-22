classdef WindowPredictionSpectralFilter < Filter.SpectralFilter
    %WINDOWPREDICTIONSPECTRALFILTER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (AbortSet, SetObservable)
        windowSize = 4
    end
    
    methods
        function obj = WindowPredictionSpectralFilter(dataManager, stateDims, obsDims, state1KernelReferenceSet, state2KernelReferenceSet, state3KernelReferenceSet)
            obj = obj@Filter.SpectralFilter(dataManager, stateDims, obsDims, state1KernelReferenceSet, state2KernelReferenceSet, state3KernelReferenceSet);
            
            obj.linkProperty('windowSize',[obj.name '_windowSize']);
        end
        
        function initFiltering(obj, observationNames, outputNames, outputDims)
            outputDims = cellfun(@(n) obj.windowSize * n, outputDims, 'UniformOutput', false);
            obj.initFiltering@Filter.SpectralFilter(observationNames, outputNames, outputDims);
        end
        
        function xMean = outputTransformation(obj, mean)
            xMean = zeros(size(mean,2),obj.outputDims{1});
            
            M = obj.K12B;
            singleOutDim = size(obj.outputData,2);
            
            for i = 1:obj.windowSize
                outputRange = (i-1)*singleOutDim+1:i*singleOutDim;
                
                [~, ind] = max(M * mean);
                xMean(:,outputRange) = obj.outputData(ind,:);
                
                mean = obj.K23 * ((obj.iK2 * (obj.K2B * mean)) .* (obj.A * mean));
                % normalized to [0,1]; 
                mean = bsxfun(@rdivide,mean,(max(mean) - min(mean)));% - min(mean);
            end
        end
    end
    
end

