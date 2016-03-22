classdef CloneKernelReferenceSetLearner < Learner.Learner & Data.DataManipulator
    
    properties
        baseKernelReferenceSet
        kernelReferenceSet
    end

    methods
        function obj = CloneKernelReferenceSetLearner(dataManager, kernelReferenceSet, baseKernelReferenceSet)
            
            obj = obj@Data.DataManipulator(dataManager);
            obj.kernelReferenceSet = kernelReferenceSet;
            obj.baseKernelReferenceSet = baseKernelReferenceSet;
            
            obj.registerReferenceSetFunction();
        end
        
        function [] = registerReferenceSetFunction(obj)
            obj.addDataManipulationFunction('setReferenceSet', {obj.kernelReferenceSet.inputDataEntryReferenceSet}, {});
        end
            
        function [] = setReferenceSet(obj, inputDataMatrix)
            referenceSetIndices = obj.baseKernelReferenceSet.getReferenceSetIndices();
            
            obj.kernelReferenceSet.setReferenceSet(inputDataMatrix(referenceSetIndices,:), referenceSetIndices);
        end
        
        function obj = updateModel(obj, data)            
            obj.callDataFunction('setReferenceSet', data);
        end
    end
    
end