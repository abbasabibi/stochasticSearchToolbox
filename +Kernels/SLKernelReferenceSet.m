classdef SLKernelReferenceSet < Kernels.KernelReferenceSet
    properties
        
        weightName = '';
        outputDataEntryReferenceSet
        
    end     
    
    properties(Access=protected)
        referenceSetOutputs = [];
        referenceSetWeights = [];        
    end
        
    methods
               
        function obj = SLKernelReferenceSet(dataManager, kernel, inputDataEntry, outputDataEntry, weightName, varargin)
            obj = obj@Kernels.KernelReferenceSet(dataManager, kernel, inputDataEntry, varargin{:});

            obj.outputDataEntryReferenceSet = outputDataEntry;
            if (exist('weightName', 'var'))
                obj.weightName = weightName;
            end
        end                      
                
        function [] = setReferenceSet(obj, data, referenceSetIndices)
            obj.setReferenceSet@Kernels.KernelReferenceSet(data, referenceSetIndices);
            
            obj.referenceSetOutputs = data.getDataEntry(obj.outputDataEntryReferenceSet);
            obj.referenceSetOutputs = obj.referenceSetOutputs(obj.referenceSetIndices,:);
            
            if (~isempty(obj.weightName))
                weights = data.getDataEntry(obj.weightName);
                obj.referenceSetWeights = weights(obj.referenceSetIndices); 
            else
                obj.referenceSetWeights = ones(size(obj.referenceSetOutputs,1),1);
            end
        end
        
        function [] = setReferenceSetMatrices(obj, inputData, outputData, weights)
            if (~exist('weights','var'))
                weights = ones(size(inputData,1));
            end
            
            obj.referenceSet = inputData;                        
            obj.referenceSetOutputs = outputData;
            obj.referenceSetWeights = weights;                                    
        end
        
        function setWeightName(obj, weightName)
            obj.weightName = weightName;
        end
        
        function [referenceSetOutputs] = getReferenceSetOutputs(obj)
            referenceSetOutputs = obj.referenceSetOutputs;
        end
        
        function [referenceSetWeights] = getReferenceSetWeights(obj)
            referenceSetWeights = obj.referenceSetWeights;
        end
      
    end
    
end

