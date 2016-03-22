classdef SLControllerEnvironment < Environments.SL.SLEnvironment
    
    properties
        
    end
    
    
    methods
        function obj = SLControllerEnvironment(dataManager, robot, numParameters)
                        
            obj = obj@Environments.SL.SLEnvironment(dataManager, robot);            
            
            obj.addAdditionalInputVariablesForEpisode('parameters');
        end
        
        
        function [SLreturn, SLreturnState, numSteps] = sendSLCommands(obj, parameters, varargin)
            [stateBuffer, ttw ] = obj.getStateBufferForSL(varargin{:});
            
            f = -1;
            while f < 0
                if (~obj.isInit)
                    obj.robot.setInitState(obj.getInitStateForSL());
                    [ stateBuffer, ttw ] = obj.getStateBufferForSL(varargin{:});                    
                end
                
                [SLreturn, SLreturnState, f] = obj.robot.SLSendController(parameters);
                obj.isInit = false;
                
                if (f == -1)
                    if (obj.realBot)
                        f = 1;
                        obj.validLastStep = false;
                    end
                    fprintf('Got SL Failure!\n');
                end
                obj.sendAdditionalSLCommands();
            end
            numSteps = SLreturnState(2);
        end
        
%         function [numTimeSteps] = getNumTimeSteps(obj)
%             numTimeSteps = obj.trajectoryGenerator.getNumTimeSteps();
%         end
       
        function [] = sendAdditionalSLCommands(obj)
        end
      
        function [stateBuffer ttw ] = getStateBufferForSL(obj, state, action)
            stateBuffer = 0;
            ttw = 0;
        end
                
    end
end
