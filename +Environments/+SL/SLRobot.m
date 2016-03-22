classdef SLRobot < Common.IASObject
    
    properties           
        dimJoints
        
        jointLimit;
        defaultJointPositions = zeros(1, 7);
                
        sizeStateBuffer = 10;
        
        resampleFrequency = 1;
        
        isInit = false;
        useMatlabInitState = true;
        maxCommands;
    end       
    
    
    methods
        function obj = SLRobot(dimJoints, maxCommands)
            obj = obj@Common.IASObject();
            if (~exist('maxCommands', 'var'))
                maxCommands = 2;
            end
            obj.dimJoints = dimJoints;
            obj.maxCommands = maxCommands;
            obj.jointLimit = ones(1, dimJoints) * pi;
        end                                     
        
        function [states] = setInitState(obj, initState)
            
            if (obj.useMatlabInitState)
                if (obj.isInit)
                    [r, states, f] = obj.SLSendTrajectory(zeros(1,obj.dimJoints), 0, 2, obj.maxCommands, -1, 1);
                end
                [r, states, f]     = obj.SLSendTrajectory(zeros(1,obj.dimJoints), 0, 1, obj.maxCommands, initState, 20);
            else
                [r, states, f]     = obj.SLSendTrajectory(zeros(1,obj.dimJoints), 0, 1, obj.maxCommands, 0, 20);
            end
            obj.isInit = true;
        end
        
        
    end
    
    methods (Abstract)
        [SLreturn, SLreturnState, f] = SLSendTrajectory(obj, trajectorySL, ttw, idxTraj, maxCommands, stateBuffer, timeOut);
        [SLreturn, SLreturnState, f] = SLSendController(obj, parameters, time, timeOut);
        
        [joints, jointsVel, jointsAcc, jointsDes, jointsDesVel, jointsDesAcc, torque, cart, SLstates] = SLGetEpisode(obj);
       
    end
end
