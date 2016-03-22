classdef KernelReferenceSetLearner < Learner.Learner & Data.DataManipulator
    
    properties
        kernelReferenceSet
        inputDataEntry
        weightName
        
    end
    
    properties (AbortSet, SetObservable)
        maxSizeReferenceSet = 300;
        minRelWeight = 1e-3;
    end
    
    
    methods (Static)
        function [kernelLearner] = CreateFromTrial(trial, featureName, inputDataEntry)
            kernelLearner = Kernels.Learner.KernelReferenceSetLearner(trial.dataManager, trial.(featureName), inputDataEntry);
        end
    end
    
    
    methods
        function obj = KernelReferenceSetLearner(dataManager, kernelReferenceSet, inputDataEntry)
            
            obj = obj@Data.DataManipulator(dataManager);
            obj.kernelReferenceSet = kernelReferenceSet;
            if (~exist('inputDataEntry', 'var'))
                inputDataEntry = kernelReferenceSet.inputDataEntryReferenceSet;
            end
            obj.inputDataEntry = inputDataEntry;
            if (~iscell(obj.inputDataEntry))
                obj.inputDataEntry = {obj.inputDataEntry};
            end

            if ~strcmp(kernelReferenceSet.name, '')
                obj.linkProperty('maxSizeReferenceSet', [kernelReferenceSet.name '_maxSizeReferenceSet']);
                obj.linkProperty('minRelWeight', 'minRelWeightReferenceSet');           

            else
                obj.linkProperty('maxSizeReferenceSet');
                obj.linkProperty('minRelWeight', [kernelReferenceSet.name 'minRelWeightReferenceSet']);           

            end          
 
        end
        
        function obj = updateModel(obj, data)
            inputDataMatrix = cell2mat(data.getDataEntryCellArray(obj.inputDataEntry));
            isValid = not(any(isnan(inputDataMatrix), 2));
            %TODO: compute index list!
            inputDataMatrix = inputDataMatrix(isValid, :);
            [inputDataMatrix, indexUnique] = unique(inputDataMatrix, 'rows');
            if(obj.isWeightedLearner())
                weights = data.getDataEntry(obj.getWeightName());
                weights = weights(isValid);
                wtIndex = weights(indexUnique) > obj.minRelWeight * max(weights);
                indexUnique = indexUnique(wtIndex);
            end
            if (size(indexUnique,1) > obj.maxSizeReferenceSet)
                
                indexList = randperm(size(indexUnique,1));
                indexList = indexList(1:obj.maxSizeReferenceSet);
                
                %indexList = obj.gridset(inputDataMatrix(indexUnique),obj.maxSizeReferenceSet);
            else
                indexList = 1:size(indexUnique, 1);
            end
            indexList = indexUnique(indexList);
            
            obj.kernelReferenceSet.setReferenceSet(data, indexList);
        end
        
        function [indexList] = gridset(obj,inputData,cnt)
            minValues = min(inputData);
            maxValues = max(inputData);
            perDim = floor(nthroot(cnt,size(inputData,2)))-1;
            stepsPerDim = (maxValues-minValues)./perDim;
            for i=1:numel(minValues)
                perDimValues{i} = minValues(i):stepsPerDim(i):maxValues(i);
            end
            points = combvec(perDimValues{:})';
            distances = pdist2(points,inputData);
            [~,indexList] = min(distances,[],2);
            indexList = unique(indexList);
        end
        
        function [] = setWeightName(obj, weightName)
            obj.weightName = {weightName};
            
            if (isprop('weightName', obj.kernelReferenceSet))
                obj.kernelReferenceSet.weightName = weightName;
            end
        end
        
        function [isWeight] = isWeightedLearner(obj)
            isWeight = ~isempty(obj.weightName);
        end
        
        function [weightName] = getWeightName(obj)
            weightName = obj.weightName{1};
        end
    end
    
end

