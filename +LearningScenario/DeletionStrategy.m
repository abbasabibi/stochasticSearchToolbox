classdef DeletionStrategy < Common.IASObject
    
    properties (SetAccess=protected)
        
    end
    
    methods
        %%
        function obj = DeletionStrategy()
            obj = obj@Common.IASObject();
        end
        
        function [keepIndices] = getIndicesToKeepAfterLearning(obj, data)
            keepIndices = true(data.getNumElements(),1);
        end
        
        function [] = deleteSamples(obj, data, beforeLearning)
            if (~exist('beforeLearning', 'var'))
                beforeLearning = 'beforeLearning';
            end
            if (strcmp(beforeLearning, 'beforeLearning'))
                keepIndices = obj.getIndicesToKeepBeforeLearning(data);
            else
                keepIndices = obj.getIndicesToKeepAfterLearning(data);
            end
            if (~isempty(keepIndices))
                data.deleteData(keepIndices);
            end
            
        end
    end
    
    methods (Abstract)
        [keepIndices] = getIndicesToKeepBeforeLearning(obj, data);
        
    end
    
end % classdef
