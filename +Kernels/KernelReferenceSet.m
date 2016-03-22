classdef KernelReferenceSet < Data.DataManipulator
    
    properties (AbortSet, SetObservable)
        inputDataEntryReferenceSet
        validityDataEntry
        referenceSetIndicator
        parentReferenceSetIndicator
    end
    
    properties(SetAccess=protected)
        
        
        kernelReferenceTag = 1;
        
        kernel
        
        K = [];
        KTag = 1;
        
        name = '';
     
    end     
    
    properties(Access=protected)
        referenceSet = [];
        referenceSetIndices;  

    end
        
    methods
               
        function obj = KernelReferenceSet(dataManager, kernel, inputDataEntry, kernelReferenceSetName)
            obj = obj@Data.DataManipulator(dataManager);
            obj.kernel = kernel;
            
            if (exist('inputDataEntry', 'var'))
                if (iscell(inputDataEntry))
                    if (iscell(inputDataEntry{1}))
                        inputDataEntry = inputDataEntry{1};
                    end
                end
                obj.inputDataEntryReferenceSet = inputDataEntry;               
            end

            
            if exist('kernelReferenceSetName', 'var')
                obj.name = kernelReferenceSetName;
            end
            if (iscell(obj.inputDataEntryReferenceSet))
                inputDataName = obj.inputDataEntryReferenceSet{1};                
            else
                inputDataName = obj.inputDataEntryReferenceSet;
            end
            
            % TODO: unlink the property for now. Such things should not be in the properties, way too complicated 
            if ~strcmp(obj.name,'')
                %obj.linkProperty('inputDataEntryReferenceSet',[obj.name '_inputDataEntry']);
                
                obj.validityDataEntry = [inputDataName 'Valid'];
                obj.linkProperty('validityDataEntry',[obj.name '_validityDataEntry']);
                
                obj.referenceSetIndicator = [obj.name 'Indicator'];
                obj.linkProperty('referenceSetIndicator',[obj.name '_referenceSetIndicator']);
                obj.linkProperty('parentReferenceSetIndicator',[obj.name '_parentReferenceSetIndicator']);
            else
                %obj.linkProperty('inputDataEntryReferenceSet');
                
                obj.validityDataEntry = [inputDataName 'Valid'];
                %obj.linkProperty('validityDataEntry');
                
                obj.referenceSetIndicator = 'referenceSetIndicator';
                %obj.linkProperty('referenceSetIndicator');
                %obj.linkProperty('parentReferenceSetIndicator');
            end
           
        end                      
                
        function [] = setReferenceSet(obj, data, referenceSetIndices)
            if (~iscell(obj.inputDataEntryReferenceSet))
                inputDataEntryReferenceSetCell =  {obj.inputDataEntryReferenceSet};
            else
                inputDataEntryReferenceSetCell = obj.inputDataEntryReferenceSet;
            end
            
            obj.referenceSet = cell2mat(data.getDataEntryCellArray(inputDataEntryReferenceSetCell));
            assert(size(obj.referenceSet,2) == obj.kernel.numDims);
            obj.kernelReferenceTag = obj.kernelReferenceTag + 1;
            
            if (nargin == 2)
                referenceSetIndices = true(size(obj.referenceSet,1),1);
            end            
            obj.referenceSetIndices = referenceSetIndices;
            obj.referenceSet = obj.referenceSet(obj.referenceSetIndices, :);

        end
        
        function [referenceSet] = getReferenceSet(obj)
            referenceSet = obj.referenceSet;
        end
        
        function [tag] = getKernelReferenceSetTag(obj)
            tag = obj.kernelReferenceTag;
        end
        

        function [K] = getKernelMatrix(obj)                       
            K = obj.kernel.getGramMatrix(obj.getReferenceSet(), obj.getReferenceSet());
        end
        
        function [K] = getKernelVectors(obj, sampleMatrix)
            K = obj.kernel.getGramMatrix(obj.getReferenceSet(), sampleMatrix);
        end 
        
        function [referenceSetIndices] = getReferenceSetIndices(obj)
            referenceSetIndices = obj.referenceSetIndices;
        end
        
        function [referenceSetSize] = getReferenceSetSize(obj)
            if islogical(obj.referenceSetIndices)
                referenceSetSize = sum(obj.referenceSetIndices);
            else
                referenceSetSize = length(obj.referenceSetIndices);
            end
        end
    end
    
end

