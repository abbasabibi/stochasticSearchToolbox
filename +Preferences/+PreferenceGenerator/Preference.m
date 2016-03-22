classdef Preference
    
    enumeration
        Undefined, Preferred, Dominated, Equal
    end
    
    methods(Static)
        function [index] = getIntRepresentation(enum)
            m = enumeration(enum);
            index = find(m==enum);
        end
    end
    
end

