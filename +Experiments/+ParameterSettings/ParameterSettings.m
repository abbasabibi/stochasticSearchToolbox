classdef ParameterSettings < Common.handleplus  
    
    methods (Abstract,Static)
        [] = setParametersForTrial(obj, trial);
    end
    
end