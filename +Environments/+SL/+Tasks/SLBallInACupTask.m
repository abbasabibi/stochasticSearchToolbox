classdef SLBallInACupTask < Environments.SL.SLRobotTask
    
    properties       
    end       
        
    methods
        function obj = SLBallInACupTask(dataManager, robot)
            obj = obj@Environments.SL.SLRobotTask(dataManager, robot);          
            obj.registerOptionalParameter('InitialBallAngle', false, 2, -ones(1,2), ones(1,2), 'contexts');
            obj.registerOptionalParameter('InitialBallVelocity', false, 2, -ones(1,2), ones(1,2), 'contexts');
            
            obj.setIfNotEmpty('InitialBallAngle', [0 0]);
            obj.setIfNotEmpty('InitialBallVelocity', [0 0]);
                       
            obj.dataManager.addDataAlias('BallPos', 'SLstates', 1:3);
            obj.dataManager.addDataAlias('BallVel', 'SLstates', 4:6);
            
            obj.dataManager.addDataAlias('CupPos', 'SLstates', 7:9);
        end                                          
        
        function initState = getInitStateForSL(obj)
            initState = zeros(1, 10);            
            initState(1:2) = obj.InitialBallAngle;
            initState(3:4) = obj.InitialBallVelocity;
        end
                
    end        
end
