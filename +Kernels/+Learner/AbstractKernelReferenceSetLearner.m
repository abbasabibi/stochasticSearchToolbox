classdef AbstractKernelReferenceSetLearner < Learner.Learner & Data.DataManipulator
    
    properties
        kernelReferenceSet
        weightName
    end
    
    properties (AbortSet, SetObservable)
        maxSizeReferenceSet = 300;
        minRelWeight = 1e-3;
    end
    
    
    
    
    methods
        function obj = AbstractKernelReferenceSetLearner(dataManager, kernelReferenceSet)
            obj = obj@Data.DataManipulator(dataManager);
            
            obj.kernelReferenceSet = kernelReferenceSet;
            
            if ~strcmp(kernelReferenceSet.name, '')
                obj.linkProperty('maxSizeReferenceSet', [obj.kernelReferenceSet.name '_maxSizeReferenceSet']);
            else
                obj.linkProperty('maxSizeReferenceSet');
            end
            
            obj.registerReferenceSetFunction();
        end
        
        function [] = registerReferenceSetFunction(obj)
            functionInput = {obj.kernelReferenceSet.inputDataEntryReferenceSet};
            functionOutput = {obj.kernelReferenceSet.referenceSetIndicator};
            
            if obj.dataManager.isDataAlias(obj.kernelReferenceSet.validityDataEntry) || obj.dataManager.isDataEntry(obj.kernelReferenceSet.validityDataEntry)
                functionInput = [functionInput {obj.kernelReferenceSet.validityDataEntry}];
            end
            
            if obj.dataManager.isDataAlias(obj.kernelReferenceSet.parentReferenceSetIndicator) || obj.dataManager.isDataEntry(obj.kernelReferenceSet.parentReferenceSetIndicator)
                functionInput = [functionInput {obj.kernelReferenceSet.parentReferenceSetIndicator}];
            end
            
            if not(obj.dataManager.isDataEntry(obj.kernelReferenceSet.referenceSetIndicator))
                depth = obj.dataManager.getDataEntryDepth(obj.kernelReferenceSet.inputDataEntryReferenceSet);
                obj.dataManager.addDataEntryForDepth(depth, obj.kernelReferenceSet.referenceSetIndicator, 1);
            end
            
            obj.addDataManipulationFunction('setReferenceSet', functionInput, functionOutput);
            obj.setTakesData('setReferenceSet', true)
        end
        
        function obj = updateModel(obj, data)
            obj.callDataFunction('setReferenceSet', data);
            
            indexList = data.getDataEntry(obj.kernelReferenceSet.referenceSetIndicator);
            obj.kernelReferenceSet.setReferenceSet(data, logical(indexList));
            
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
    
    methods (Abstract)
        Indicator = setReferenceSet(obj, inputDataMatrix, valid, parentIndicator);
    end
    
end

