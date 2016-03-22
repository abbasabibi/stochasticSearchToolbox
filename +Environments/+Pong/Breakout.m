classdef Breakout < Environments.Pong.Pong
    
    properties 
        numBricks;

    end
    
    methods
        function obj =  Breakout(sampler, fieldWidth, fieldHeight, numBricks)
            
            obj = obj@Environments.Pong.Pong(sampler,fieldWidth,fieldHeight, numBricks); %sampler, dimState, dimAction
            
            obj.numBricks = numBricks;
            
            %[posX, posY, velX, velY, reward, bricksActive]
            maxState    = [obj.fieldWidth/2, obj.fieldHeight/2, -1, -1, 10, ones(1,numBricks)];
            minState    = [-obj.fieldWidth/2, -obj.fieldHeight/2, 1, -0.1, 10, ones(1,numBricks)];
            obj.dataManager.setRange('states', minState, maxState);
            obj.dataManager.setRange('nextStates', minState, maxState);
%             
%             maxContext = [obj.fieldWidth, obj.field.ballInitHeight, 10, -1, 0, ones(1,numBricks)]; %[posX, posY, velX, velY, reward, opponentX]
%             minContext = [-obj.fieldWidth, obj.field.ballInitHeight, -10, -1, 0, ones(1,numBricks)]; %[posX, posY, velX, velY, reward, opponentX]
%             
            maxContext = [10, obj.field.ballInitHeight, 2, -1, 0, ones(1,numBricks)]; %[posX, posY, velX, velY, reward, opponentX]
            minContext = [-10, obj.field.ballInitHeight, -2, -1, 0, ones(1,numBricks)]; %[posX, posY, velX, velY, reward, opponentX]
            obj.dataManager.setRange('contexts', minContext , maxContext);
            
            
            obj.field.createBrickLine(numBricks);
        end
        
        
        %%
        function [nextState] = transitionFunction(obj, states, actions)  
            for i = 1 : size(states,1)
                for k = 1 : obj.numBricks
                    obj.field.walls(obj.field.bricksIdx(k),6) = states(i,5+k);
                end
            end
            
            nextState = obj.transitionFunction@Environments.Pong.Pong(states,actions);
        end
        
        %%
        function state = rewardFunction(obj, hasContact, collisionIdx, state)
            obj.rewardSignal    = -0.1;            
            bricksActive        = state(6:end);
            
            if(hasContact)                
                if(collisionIdx == obj.field.outIdx)
                    obj.rewardSignal    = -10000  - 100 * abs(obj.ball.pos(1) - obj.field.walls(obj.field.paddleIdx,1));
                end                
                if( sum(obj.field.bricksIdx==collisionIdx) )
                    stateIdx = collisionIdx - min(obj.field.bricksIdx) + 6;
                    state(stateIdx) = 0;
                end
            end
            
            obj.rewardSignal    = obj.rewardSignal - 1 * sum(bricksActive);
        end
        
       
        
    end
    
end

