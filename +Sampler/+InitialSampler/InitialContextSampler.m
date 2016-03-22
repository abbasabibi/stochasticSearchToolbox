classdef InitialContextSampler < Data.DataManipulator & Common.IASObject
    
    properties
        
    end
    
    methods
        function [obj] = InitialContextSampler(dataSampler)
            
            obj = obj@Data.DataManipulator(dataSampler.getDataManagerForSampler());
            obj = obj@Common.IASObject();
            
            obj.addDataManipulationFunction('sampleContext', {}, {'contexts'}, true, true);
        end
    
        
    end
    
    methods (Abstract)
        
        [states] = sampleContext(obj, numElements, varargin);
        
    end
end