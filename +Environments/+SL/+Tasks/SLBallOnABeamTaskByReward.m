classdef SLBallOnABeamTaskByReward < Environments.SL.SLRobotTask
    
    properties
        usedStates;
        controlledJoints;
        lengthSupraStep;
        nbSupraSteps;
        nbGainRows; %number of gains per row
        dimControl;
    end
    
    methods
        function obj = SLBallOnABeamTaskByReward(dataManager, robot)
            obj = obj@Environments.SL.SLRobotTask(dataManager, robot);   

            obj.nbSupraSteps = Common.Settings().getProperty('nbSupraSteps'); 
            obj.lengthSupraStep = Common.Settings().getProperty('lengthSupraStep');
            obj.usedStates = Common.Settings().getProperty('usedStates');
            obj.controlledJoints = Common.Settings().getProperty('controlledJoints');
            obj.nbGainRows = sum(obj.usedStates);
            obj.dimControl = sum(obj.controlledJoints);
            
            obj.registerOptionalParameter('InitialBallPos', false, 2, -ones(1,1), ones(1,1), 'contexts');
            obj.registerOptionalParameter('InitialBallVel', false, 2, -ones(1,1), ones(1,1), 'contexts');
            obj.setIfNotEmpty('InitialBallPos', 0.2);
            obj.setIfNotEmpty('InitialBallVel', 0);            
            obj.dataManager.addDataAlias('BallPos', 'SLstates', 1:3);
            obj.dataManager.addDataAlias('BallVel', 'SLstates', 4:6);            
        end                                          
        
        function initState = getInitStateForSL(obj)
            initState = zeros(1, 100);            
            initState(1) = obj.InitialBallPos;
            initState(2) = obj.InitialBallVel;%state 3 is for ball acceleration (= 0)
            initState(4) = obj.lengthSupraStep; 
            initState(5) = obj.nbSupraSteps;
            initState(6) = obj.nbGainRows;
            initState(7) = obj.dimControl;
            ind = 8;
            initState(ind:ind+size(obj.usedStates, 2)-1) = obj.usedStates;
            ind = ind + size(obj.usedStates, 2); 
            initState(ind:ind+size(obj.controlledJoints, 2)-1) = obj.controlledJoints;
        end
                
    end        
end
