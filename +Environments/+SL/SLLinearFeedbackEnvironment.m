classdef SLLinearFeedbackEnvironment < Environments.SL.SLEnvironment
    
    properties
        gainInterafce; %handle to IFbGainsProvider.getFeedbackGainsForT
    end
    
    
    methods
        function obj = SLLinearFeedbackEnvironment(dataManager, robot, usedStates, controlledJoints)            
            obj = obj@Environments.SL.SLEnvironment(dataManager, robot, usedStates, controlledJoints);  
        end
        
        function [] = setGainInterface(obj, interface) 
            obj.gainInterface = interface;
        end        
        
        function [SLreturn, SLreturnState, numSteps] = sendSLCommands(obj, varargin)
            %%% getting the gains
            numSupraSteps = Common.Settings().getProperty('nbSupraSteps');
            [K, kff, SigmaCtl] = gainInterface(obj, 1:numSupraSteps);
            %%% adding zero elements if nb controlled joints < nb joint
            K = [K zeros(obj.dimState * numSupraSteps, obj.dimJoints - obj.dimControl)];
            kff = [kff zeros(numSupraSteps, obj.dimJoints - obj.dimControl)];
            SigmaCtl = [SigmaCtl zeros(obj.dimControl * numSupraSteps, obj.dimJoints - obj.dimControl)];
            
            %%% filling in the gains and noise matrices in the trajectory
            nbRowPerSupraStep = obj.dimState + 1 + obj.dimControl; %bias + gains joints/external states + noise
            nbTrajRow = nbRowPerSupraStep * numSupraSteps;
            trajectorySL = zeros(nbTrajRow, obj.dimJoints); 
            %%%% bias
            trajectorySL(1:nbRowPerSupraStep:nbTrajRow, :) = kff;
            %%%% gains           
            KId = repmat((1:obj.dimState)', 1, numSupraSteps) + repmat(2:nbRowPerSupraStep:nbTrajRow, obj.dimState, 1);
            KId = reshape(KId, 1, obj.dimState * numSupraSteps);
            trajectorySL(KId, :) = K;
            %%%% noise            
            SigId = repmat((1:obj.dimControl)', 1, numSupraSteps) + repmat(2+obj.dimState:nbRowPerSupraStep:nbTrajRow, obj.dimControl, 1);
            SigId = reshape(SigId, 1, obj.dimControl * numSupraSteps);
            trajectorySL(SigId, :) = SigmaCtl;
            
            [stateBuffer, ttw ] = obj.getStateBufferForSL(varargin{:});
            
            numSteps = numSupraSteps * Common.Settings().getProperty('lengthSupraStep');
            
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

        
        function [states, actions, nextStates, endEffPositions, endEffOrientations, SLreturn, SLreturnState, SLstates, varargout] = sampleEpisode(obj, varargin)
            [states, actions, nextStates, endEffPositions, endEffOrientations, SLreturn, SLreturnState, SLstates, varargout] ...
                = sampleEpisode@Environments.SL.SLEnvironment(obj, varargin);
            numSteps = size(states, 1);
            lengthSupraStep = Common.Settings().getProperty('lengthSupraStep');
            states = states(1:lengthSupraStep:numSteps, :);
            actions = actions(1:lengthSupraStep:numSteps, :);
            nextStates = nextStates(1:lengthSupraStep:numSteps, :);
            endEffPositions = endEffPositions(1:lengthSupraStep:numSteps, :);
            endEffOrientations = endEffOrientations(1:lengthSupraStep:numSteps, :);
            SLreturnState = SLreturnState(1:lengthSupraStep:numSteps, :);
            SLstates = SLstates(1:lengthSupraStep:numSteps, :);
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
