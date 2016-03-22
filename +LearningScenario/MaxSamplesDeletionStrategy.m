classdef MaxSamplesDeletionStrategy < LearningScenario.DeletionStrategy
    
    properties (SetObservable,AbortSet)
        maxSamples = 100;
    end
    
    methods
        %%
        function obj = MaxSamplesDeletionStrategy(name)
            if (~exist('name', 'var'))
                name = '';
            end
            
            obj = obj@LearningScenario.DeletionStrategy();    

            obj.linkProperty('maxSamples', ['maxSamples', name]);
        end
        
        function [keepIndices] = getIndicesToKeepBeforeLearning(obj, data)
            if (data.isDataEntry('isVirtualSample'))
                virtualSampleIndices = and(data.getDataEntry('isVirtualSample'), ~data.getDataEntry('isInitialVirtualSample'));
                offset = find(~virtualSampleIndices, 1);
                numElements = sum(~virtualSampleIndices);
            else
                numElements = data.getNumElements();
                offset = 1;
            end
            keepIndices = true(data.getNumElements(), 1);
            numDelete = numElements - obj.maxSamples;
            
            keepIndices(offset:(offset + numDelete - 1)) = false;
        end
        
        function [keepIndices] = getIndicesToKeepAfterLearning(obj, data)                        
            if (data.isDataEntry('isVirtualSample'))
                virtualSampleIndices = and(data.getDataEntry('isVirtualSample'), ~data.getDataEntry('isInitialVirtualSample'));
                keepIndices = ~virtualSampleIndices;
            else
                keepIndices = true(data.getNumElements(), 1);
            end
        end
    end
    
    
end % classdef
