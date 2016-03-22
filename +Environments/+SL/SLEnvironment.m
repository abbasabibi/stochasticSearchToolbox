classdef SLEnvironment < Environments.SL.RobotEnvironment
    
    properties
        controlMethod
        initStateIndices = [];
        
        jointIndices = 1:7;
        controlledJointsId;
        
        cartIndices = 1:3
        cartOrientationIndices = 4:7;
        
        
        realBot = 0;
        useMatlabInitState = true;
        
        isInit = false;
        
        timeOut = 20;
        resampleFrequency = 1;
        
        maxCommands = 2;
        idxTraj = 2;
        
        robot;
    end
    
    
    methods
        function obj = SLEnvironment(dataManager, robot, usedStates, controlledJoints)
            
            obj = obj@Environments.SL.RobotEnvironment(dataManager, robot.dimJoints, usedStates, controlledJoints);
            
            obj.robot = robot;
            obj.jointIndices = 1:robot.dimJoints;
            obj.controlledJointsId = obj.jointIndices;
            if(~isempty(obj.controlledJoints))
                obj.controlledJointsId = find(obj.controlledJoints);
            end
            
            obj.controlMethod = Environments.SL.SLControlType.InverseDynamicsControl;
            obj.dataManager.addDataEntry('steps.endEffPositions', 3, -ones(1,3) * 3, ones(1,3) * 3);
            obj.dataManager.addDataEntry('steps.endEffOrientations', 4, -ones(1,4) * 3, ones(1,4) * 3);
            obj.dataManager.addDataEntry('steps.SLstates', 10);
            
            obj.dataManager.addDataEntry('SLreturns', 1);
            obj.dataManager.addDataEntry('SLreturnStates', 10);            
            
            obj.addAdditionalOutputVariablesForEpisode('endEffPositions');
            obj.addAdditionalOutputVariablesForEpisode('endEffOrientations');
            obj.addAdditionalOutputVariablesForEpisode('SLreturns');
            obj.addAdditionalOutputVariablesForEpisode('SLreturnStates');
            obj.addAdditionalOutputVariablesForEpisode('SLstates');
            
        
        end
        
        function [] = setDefaultJointPositions(obj, defaultJointPositions)
            obj.robot.defaultJointPositions = defaultJointPositions;
        end
        
        function [] = setRealRobot(obj, isRealRobot, resampleFrequency)
            obj.realBot = isRealRobot;
            obj.resampleFrequency = resampleFrequency;
            if (isRealRobot)
                obj.timeOut = 20;
                obj.useMatlabInitState = false;
            else
                obj.timeOut = 10;
            end
        end
        
        
        function [states, actions, nextStates, endEffPositions, endEffOrientations, SLreturn, SLreturnState, SLstates, varargout] = sampleEpisode(obj, varargin)
            
            assert(obj.isInit);
            obj.validLastEpisode = true;
            
            
            [SLreturn, SLreturnState, numSteps] = obj.sendSLCommands(varargin{:});
            
            %            end
            %pause(0.3);
            
            % get the sensor state from SL
            [joints, jointsVel, ~, jointsDes, ~, jointsDesAcc, torque, cart, SLstates] = obj.robot.SLGetEpisode(numSteps + 1);
            
            %%% setting the states
            states = zeros(size(joints, 1), obj.dimState);              
            if(isempty(obj.usedStates)) %default behavior:states are all joints pos and vels
                states(:,1:2:end) = joints(:, obj.jointIndices);
                states(:,2:2:end) = jointsVel(:, obj.jointIndices);
            else % format: first column of SLstates reserved for reward. also, bias won't be stored in state       
                dimExternal = obj.dimState - 2 * obj.dimJoints;
                allStates = [joints jointsVel SLstates(:, 2:dimExternal+1)]; 
                states = allStates(:, obj.usedStates(2:end) > 0);
            end
            nextStates = states(2:end,:);
            states = states(1:end-1,:);
                        
            %%% setting the actions
            switch (obj.controlMethod)
                case Environments.SL.SLControlType.TorqueControl
                    actions = torque(1:size(states,1), obj.controlledJointsId);
                case Environments.SL.SLControlType.InverseDynamicsControl
                    actions = jointsDesAcc(1:size(states,1), obj.controlledJointsId);
            end
            
            endEffPositions = cart(1:end-1, obj.cartIndices);
            endEffOrientations = cart(1:end-1, obj.cartOrientationIndices);
            
            obj.isInit = false;
            
            if (size(states,1) < obj.numTimeSteps)
                numLocalSteps = size(states,1);
                states = [states; NaN(obj.numTimeSteps - numLocalSteps, size(states,2))];
                actions = [actions; NaN(obj.numTimeSteps - numLocalSteps, size(actions,2))];
                nextStates = [nextStates; NaN(obj.numTimeSteps - numLocalSteps, size(nextStates,2))];
                endEffPositions = [endEffPositions; NaN(obj.numTimeSteps - numLocalSteps, size(endEffPositions,2))];
                endEffOrientations = [endEffOrientations; NaN(obj.numTimeSteps - numLocalSteps, size(endEffOrientations,2))];
                SLstates = [SLstates; NaN(obj.numTimeSteps - numLocalSteps, size(SLstates,2))];                                                    
            end
            
            varargout = obj.robotTask.getAdditionalDataEntries(SLstates);                        
        end               
        
        function [stateBuffer ttw ] = getStateBufferForSL(obj, state, action)
            stateBuffer = 0;
            ttw = 0;
        end
        
        function [] = registerSLReturnAsReward(obj)
            obj.dataManager.addDataAlias('returns', 'SLreturns');
        end        
        
        function [contexts] = getRobotContext(obj, numElements, varargin)
            
            assert(~isempty(obj.robotTask), 'You need to assign a SLtask to your environment');
            if (obj.realBot)
                start = 'n';
                while(~strcmp(start,'y'))
                    message = ['Do you really REALLY really want to start ?!(y/n)\n'];
                    start = input(message, 's');
                end
            end
            
            contexts = obj.robotTask.initializeRobotTask(varargin{:});
         
            
            obj.isInit = true;
        end
        
        function [initState] = getInitStateForSL(obj)
            initState = zeros(1, 10);
        end
        
        function reward = getRewardFromSL(obj, state, action, r, SLreturnstate, joints, torques, cart, SLstates)
            reward = r;
        end
        
        function valid = isValidLastEpisode(obj)
            if (obj.realBot)
                if (~obj.validLastStep)
                    fprintf('Last Episode was not valid, restarting...\n');
                    valid = obj.validLastEpisode;
                else
                    validStr = 'l';
                    while(~strcmp(validStr,'y') && ~strcmp(validStr,'n'))
                        message = ['Valid Experiment ?!(y/n)\n'];
                        validStr = input(message, 's');
                    end
                    valid = strcmp(validStr,'y');
                end
            else
                valid = obj.validLastEpisode;
            end
        end
    end
end
