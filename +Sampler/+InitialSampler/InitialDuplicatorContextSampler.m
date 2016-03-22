
classdef InitialDuplicatorContextSampler < Sampler.InitialSampler.InitialContextSamplerStandard
    
    properties(SetObservable,AbortSet)
        numDuplication = 1;
        
    end
    
    methods
        function [obj] = InitialDuplicatorContextSampler(dataSampler)
            
            obj = obj@Sampler.InitialSampler.InitialContextSamplerStandard(dataSampler);
            obj.linkProperty('numDuplication');                                   

            
        end
    
        function [contexts] = sampleContext(obj, numElements)
            
           numUniqueContexts = ceil(numElements/obj.numDuplication);
           uniqueContexts = sampleContext@Sampler.InitialSampler.InitialContextSamplerStandard(obj,numUniqueContexts);
           duplicatedContexts = repmat(uniqueContexts,obj.numDuplication,1);
           contexts = duplicatedContexts(1:numElements,:);
           
            
        end
    end
end
