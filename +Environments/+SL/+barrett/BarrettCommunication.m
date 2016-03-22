classdef BarrettCommunication < Environments.SL.SLRobot
    
    properties
        debug = false;
    end
    
    
    methods
        function obj = BarrettCommunication()
            obj = obj@Environments.SL.SLRobot(7);
        end
        
        
        function [SLreturn, SLreturnState, flag] = SLSendTrajectory(obj, trajectorySL, time, trajIdx, maxCommands, stateBuffer, timeOut)
            if (obj.debug)
                fprintf('Sending trajIdx %d with %d steps\n', trajIdx, size(trajectorySL, 1));
            end
            if (nargin == 2)
                time        = 0.0;
                trajIdx     = 2;
                maxCommands = 2;
                stateBuffer = [];
            end
            
            if(~exist('timeOut','var') )
                timeOut = 20;
            end
                          
            [SLreturnState flag] = Environments.SL.barrett.SLSendTrajectoryMex(trajIdx, maxCommands, ...
                time, ...
                trajectorySL, ...
                stateBuffer, ...
                timeOut);
            
            if (flag == 1)
                SLreturn = SLreturnState(1);
            else
                SLreturn = -inf;
            end
            SLreturnState = SLreturnState(1:obj.sizeStateBuffer)';
            if (trajIdx > 1)
                obj.isInit = false;
            end
        end
        
        function  [SLreturn, SLreturnState, flag] = SLSendController(obj, parameters, time, timeOut)
            
            if (obj.debug)
                fprintf('Sending trajIdx %d with %d steps\n', trajIdx, size(trajectorySL, 1));
            end
            stateBuffer = parameters;
            if (nargin == 2)
                time        = 0.0;    
            end
            
            if(~exist('timeOut','var') )
                timeOut = 20;
            end
                          
            [SLreturnState flag] = Environments.SL.barrett.SLSendTrajectoryMex(2, 2, ...
                time, ...
                zeros(1,7), ...
                stateBuffer, ...
                timeOut);
            
            if (flag == 1)
                SLreturn = SLreturnState(1);
            else
                SLreturn = -inf;
            end
            SLreturnState = SLreturnState(1:obj.sizeStateBuffer)';
            obj.isInit = false;
        end

        
        function [joints, jointsVel, jointsAcc, jointsDes, jointsDesVel, jointsDesAcc, torque, cart, SLstates, numCommand, stepIndex] = SLGetEpisode(obj, numSteps)
            
            sizeStateBuffer = obj.sizeStateBuffer;
            
            [joints, jointsVel, jointsAcc, jointsDes, jointsDesVel, jointsDesAcc, torque, cart, SLstates, numCommand, stepIndex] = Environments.SL.barrett.SLGetEpisodeMex(sizeStateBuffer);
            numSteps = min(size(joints,2), numSteps);
            joints = joints(:, 1:numSteps)';
            jointsVel = jointsVel(:, 1:numSteps)';
            jointsAcc = jointsAcc(:, 1:numSteps)';
            jointsDes = jointsDes(:, 1:numSteps)';            
            jointsDesVel = jointsDesVel(:, 1:numSteps)';
            jointsDesAcc = jointsDesAcc(:, 1:numSteps)';
            torque = torque(:, 1:numSteps)';
            cart = cart(:, 1:numSteps)';
            SLstates = SLstates(:, 1:numSteps)';
            numCommand = numCommand(:, 1:numSteps)';
            stepIndex = stepIndex(:, 1:numSteps)';                        
            
        end
        
    end
end
