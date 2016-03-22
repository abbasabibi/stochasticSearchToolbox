%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This is a test class for the settings. We show how we can set general 
% properties.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
classdef TestSettingsClass < Common.IASObject

    % Define some properties that we will register in the parameter pool.
    % All linked properties NEED to be declared as 'SetObservable' and
    % 'AbortSet'. In addition, we can provide the default value of the
    % property if the user does not specify another value.
    properties (AbortSet, SetObservable)

        % define 'testProperty1' with default value 10
        testProperty1 = 10.0
        
        % define 'testProperty1' with default value 'Geri'
        testProperty2 = 'Geri'; 
        
    end
    
    methods
        
        function obj = TestSettingsClass()
            obj = obj@Common.IASObject();
            
            % link the properties, use same name as local name
            obj.linkProperty('testProperty1');
            
            % link the properties, use 'CoolFanzyName'
            obj.linkProperty('testProperty2', 'CoolFanzyName');
        end
        
        function [value] = dummyProperty2(obj, x)
            value = obj.testProperty2(x);
        end
        
    end
    
end