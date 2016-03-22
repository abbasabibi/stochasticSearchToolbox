classdef SLBeerPongTask < Environments.SL.SLRobotTask
    
    properties       
    end       
    
    properties (SetObservable, AbortSet)
        bounceNoise = 0;
        actionCosts = 0;
    end
        
    methods
        function obj = SLBeerPongTask(dataManager, robot)
            obj = obj@Environments.SL.SLRobotTask(dataManager, robot);          
            obj.registerOptionalParameter('InitialCupPositionX', false, 1, -[0.2], [0.2], 'contexts');            
            obj.registerOptionalParameter('InitialCupPositionY', false, 1, -[0.2], [0.2], 'contexts');            
            obj.setIfNotEmpty('InitialCupPositionX', 0);            
            obj.setIfNotEmpty('InitialCupPositionY', 0);            
                       
            obj.dataManager.addDataAlias('BallPos', 'SLstates', 1:3);
            obj.dataManager.addDataAlias('BallVel', 'SLstates', 4:6);
            
            obj.dataManager.addDataAlias('CupPos', 'SLstates', 7:9);
            
            obj.linkProperty('bounceNoise', 'BeerPongBounceNoise');
            obj.linkProperty('actionCosts', 'actionCosts');
            
        end                                          
        
        function initState = getInitStateForSL(obj)
            initState = zeros(1, 10);            
            initState(1) = obj.InitialCupPositionX;
            initState(2) = obj.InitialCupPositionY;
            initState(3) = obj.actionCosts;
            initState(4) = obj.bounceNoise;            
        end
                
    end        
end
