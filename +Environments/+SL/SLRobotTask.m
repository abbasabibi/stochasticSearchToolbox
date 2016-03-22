classdef SLRobotTask < Environments.SL.RobotTask
    
    properties       
        robot
        additionalDataEntries = {};
        
        useSLReward = true;
    end       
    
    
    methods
        function obj = SLRobotTask(dataManager, robot)
            obj = obj@Environments.SL.RobotTask(dataManager);
            obj.robot = robot;
        end           
        
        function [contexts] = initializeRobotTask(obj, varargin)
            obj.inputParameterDeMux(varargin);
            initState = obj.getInitStateForSL();
            state = obj.robot.setInitState(initState);
            contexts = state;
            
        end                  
        
        function initState = getInitStateForSL(obj)
            initState = zeros(1, 10);
        end
                
        function [output] = getAdditionalDataEntries(obj, SLstates)
            output = {};
        end
    end
    
    
end
