classdef SLCastingTask < Environments.SL.SLRobotTask
    
    properties       
    end       
        
    methods
        function obj = SLCastingTask(dataManager, robot)
            obj = obj@Environments.SL.SLRobotTask(dataManager, robot);          
            obj.registerOptionalParameter('InitialCupPosition', false, 2, -ones(1,2), ones(1,2), 'contexts');            
            obj.setIfNotEmpty('InitialCupPosition', [0 0]);            
                       
            obj.dataManager.addDataAlias('BallPos', 'SLstates', 1:3);
            obj.dataManager.addDataAlias('BallVel', 'SLstates', 4:6);
            
            obj.dataManager.addDataAlias('CupPos', 'SLstates', 7:9);
        end                                          
        
        function initState = getInitStateForSL(obj)
            initState = zeros(1, 10);            
            initState(1:2) = obj.InitialCupPosition;
        end
                
    end        
end
