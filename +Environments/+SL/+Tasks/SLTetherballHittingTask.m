classdef SLTetherballHittingTask < Environments.SL.SLRobotTask
    
    properties       
    end       
        
    methods
        function obj = SLTetherballHittingTask(dataManager, robot)
            obj = obj@Environments.SL.SLRobotTask(dataManager, robot);          
            obj.registerOptionalParameter('TargetPosition', false, 3, -ones(1,3), ones(1,3), 'contexts');            
            obj.setIfNotEmpty('TargetPosition', [0 0 0]);            
                       
            obj.dataManager.addDataAlias('BallPos', 'SLstates', 1:3);
            obj.dataManager.addDataAlias('BallVel', 'SLstates', 4:6);
            
            obj.dataManager.addDataAlias('TargetPosition', 'SLstates', 7:9);
        end                                          
        
        function initState = getInitStateForSL(obj)
            initState = zeros(1, 10);            
            initState(1:3) = obj.TargetPosition;
        end
                
    end        
end
