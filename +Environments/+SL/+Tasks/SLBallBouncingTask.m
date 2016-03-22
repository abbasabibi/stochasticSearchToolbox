classdef SLBallBouncingTask < Environments.SL.SLRobotTask
    
    properties       
    end       
        
    methods
        function obj = SLBallBouncingTask(dataManager, robot)
            obj = obj@Environments.SL.SLRobotTask(dataManager, robot);          
          
            obj.dataManager.addDataAlias('BallPos', 'SLstates', 1:3);
            obj.dataManager.addDataAlias('BallVel', 'SLstates', 4:6);
            
            obj.dataManager.addDataAlias('CupPos', 'SLstates', 7:9);
            
            
        end                                          
        
        function initState = getInitStateForSL(obj)
            initState = zeros(1, 10);            
        end
                
    end        
end
