classdef RandomKernelReferenceSetLearner < Kernels.Learner.AbstractKernelReferenceSetLearner
    
    methods (Static)
        function [kernelLearner] = CreateFromTrial(trial, featureName, inputDataEntry)
            kernelLearner = Kernels.Learner.RandomKernelReferenceSetLearner(trial.dataManager, trial.(featureName));
        end
    end
    
    
    methods
        
        function obj = RandomKernelReferenceSetLearner(dataManager, kernelReferenceSet)
            obj = obj@Kernels.Learner.AbstractKernelReferenceSetLearner(dataManager, kernelReferenceSet);
        end
        
        function indicator = setReferenceSet(obj, data, inputDataMatrix, valid, parentIndicator)
            M = size(inputDataMatrix,1);
            
            if not(exist('parentIndicator','var'))
                parentIndicator = true(M,1);
            end
            
            if exist('valid', 'var')
                validInputDataMatrix = inputDataMatrix(logical(valid & parentIndicator),:);
                orig_index = find(valid & parentIndicator);
            else
                validInputDataMatrix = inputDataMatrix(logical(parentIndicator),:);
                orig_index = find(parentIndicator);
            end
            
            [~, indexUnique] = unique(validInputDataMatrix, 'rows', 'stable');
            
            if(obj.isWeightedLearner())
                weights = data.getDataEntry(obj.getWeightName());
                weights = weights(orig_index);
                wtIndex = weights(indexUnique) > obj.minRelWeight * max(weights);
                indexUnique = indexUnique(wtIndex);
            end
            
            if (size(indexUnique,1) > obj.maxSizeReferenceSet)
                %                 indexList = 1:size(uniqueValidInputDataMatrix,1);
                indexList = randperm(size(indexUnique,1));
                indexList = indexList(1:obj.maxSizeReferenceSet);
            else
                indexList = 1:size(indexUnique, 1);
            end
            indexList = indexUnique(indexList);
            indexList = orig_index(indexList);
            
            indicator = false(M,1);
            indicator(indexList) = true;
        end
        
        
    end
    
end

