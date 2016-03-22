classdef Evaluator < Common.IASObject
   
    properties
        name
        hook
        storingType
    end
    
    methods
        function [obj] = Evaluator(name, hook, storingType)
            obj = obj@Common.IASObject();            
            obj.name = name;
            obj.hook = hook;
            obj.storingType = storingType;
        end
        
                        
    end
    
    methods (Abstract)
        [evaluation] = getEvaluation(obj, data, newData, trial)
    end
    
end