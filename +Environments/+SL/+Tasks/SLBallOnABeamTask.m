classdef SLBallOnABeamTask < Environments.SL.SLRobotTask
    
    properties       
    end       
        
    methods
        function obj = SLBallOnABeamTask(dataManager, robot)
            obj = obj@Environments.SL.SLRobotTask(dataManager, robot);   
            dataManager.addDataEntry('parameters', 2, [0 0], [0.2 0.1]);

            obj.registerOptionalParameter('InitialBallPos', false, 2, -ones(1,1), ones(1,1), 'contexts');
            obj.registerOptionalParameter('InitialBallVel', false, 2, -ones(1,1), ones(1,1), 'contexts');
            
            obj.setIfNotEmpty('InitialBallPos', 0.2);
            obj.setIfNotEmpty('InitialBallVel', 0);
                       
            obj.dataManager.addDataAlias('BallPos', 'SLstates', 1:3);
            obj.dataManager.addDataAlias('BallVel', 'SLstates', 4:6);            
        end                                          
        
        function initState = getInitStateForSL(obj)
            initState = zeros(1, 10);            
            initState(1) = obj.InitialBallPos;
            initState(2) = obj.InitialBallVel;
        end
                
    end        
end
