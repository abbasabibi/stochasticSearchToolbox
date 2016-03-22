classdef SLTrajectoryEnvironment < Environments.SL.SLEnvironment
    
    properties
        
    end
    
    
    methods
        function obj = SLTrajectoryEnvironment(dataManager, robot, usedStates, controlledJoints)            
            obj = obj@Environments.SL.SLEnvironment(dataManager, robot, usedStates, controlledJoints);                  
            obj.addAdditionalInputVariablesForEpisode('referencePos');
        end
        
        
        function [SLreturn, SLreturnState, numSteps] = sendSLCommands(obj, referencePos, varargin)
            trajectorySL = repmat(obj.robot.defaultJointPositions, size(referencePos, 1), 1);
            
            numSteps = size(trajectorySL, 1);
            trajectorySL(:, obj.jointIndices) = referencePos;
            trajectorySL = bsxfun(@min, trajectorySL,  obj.robot.jointLimit);
            trajectorySL = bsxfun(@max, trajectorySL,  -obj.robot.jointLimit);
            
            [stateBuffer, ttw ] = obj.getStateBufferForSL(varargin{:});
            
            f = -1;
            assert(~any(isnan(trajectorySL(:))) && ~any(isinf(trajectorySL(:))));
            while f < 0
                if (~obj.isInit)
                    obj.robot.setInitState(obj.getInitStateForSL());
                    [ stateBuffer, ttw ] = obj.getStateBufferForSL(varargin{:});                    
                end
                
                [SLreturn, SLreturnState, f] = obj.robot.SLSendTrajectory(trajectorySL(1:obj.resampleFrequency:end, :), ttw, obj.idxTraj, ...
                    obj.maxCommands, stateBuffer, obj.timeOut);
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
