classdef RobotTask < Data.DataManipulator & Data.OptionalParameterInterface
    
    properties           
    end       
    
    
    methods
        function obj = RobotTask(dataManager)
            obj = obj@Data.DataManipulator(dataManager);
            obj = obj@Data.OptionalParameterInterface();
        end           
        
        function [context] = initializeRobotTask(obj, varargin)
        end                  
        
    end
    
    
end
