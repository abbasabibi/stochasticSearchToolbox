classdef Pong < Environments.TransitionFunction 
    
    properties 
        numContext  = 6; %start pos and vel
        
        fieldWidth      = 20;
        fieldHeight     = 20;
        
        maxAngle        = pi/4;
%         maxSpeed        = 1;
        
        goalPos         = [0, 5];
        
        initialState    = [0, 0];
        
        opponentWidth   = 4;
        
        
        ball
        field
        rewardSignal

    end
    
    methods
        function obj =  Pong(sampler, fieldWidth, fieldHeight, dimAdditionalStates)
            
            if(~exist('dimAdditionalStates', 'var') )
                dimAdditionalStates = 1; %OpponentX
            end           
            
            obj = obj@Environments.TransitionFunction(sampler, 5 + dimAdditionalStates, 2); %sampler, dimState, dimAction
            
            obj.numContext = 5 + dimAdditionalStates;
            
            if(exist('fieldWidth', 'var') )
                obj.fieldWidth  = fieldWidth;
                obj.fieldHeight = fieldHeight;
            end
            
            level = obj.dataManager.getDataManagerDepth('steps') - 1;

            obj.dataManager.addDataEntryForDepth(level,'parameters', 2);
            obj.dataManager.addDataEntryForDepth(level,'contexts', obj.numContext);            
            
            
            obj.dataManager.addDataEntry('steps.rewards', 1, -1, 1);
            obj.dataManager.addDataEntry('steps.ballPos', 2);
            obj.dataManager.addDataEntry('steps.ballVel', 2);
            
            obj.addDataManipulationFunction('transitionFunction', {'states', 'parameters'}, {'nextStates'});
            obj.addDataManipulationFunction('sampleContext', {}, {'contexts'});
            obj.addDataManipulationFunction('sampleInitState', {'contexts'}, {'states'});
            obj.addDataManipulationFunction('isActiveStep', {'states', 'nextStates'}, {'isActive'});
            

            obj.ball = Environments.Pong.Ball();
            obj.ball.setVel(rand(2,1))
            obj.ball.setVel( obj.ball.vel / norm(obj.ball.vel) )            

            obj.field   = Environments.Pong.Walls(obj.fieldWidth, obj.fieldHeight);
            obj.field.createPlayingField();
            
            
            maxAction   = [obj.fieldWidth/2, obj.maxAngle];
            obj.dataManager.setRange('parameters', -maxAction , maxAction );
            
            %[posX, posY, velX, velY, reward, opponentX]
            maxState    = [obj.fieldWidth/2, obj.fieldHeight/2, -1, 1, 10, 10];
            obj.dataManager.setRange('states', -maxState, maxState);
            obj.dataManager.setRange('nextStates', -maxState, maxState);
            
            maxContext = [obj.fieldWidth, obj.field.ballInitHeight, 10, -1, 0, obj.fieldWidth]; %[posX, posY, velX, velY, reward, opponentX]
            minContext = [-obj.fieldWidth, obj.field.ballInitHeight, -10, -1, 0, -obj.fieldWidth]; %[posX, posY, velX, velY, reward, opponentX]
            obj.dataManager.setRange('contexts', minContext , maxContext);
            
%             obj.field.enablePlotting = true;
            
        end
        
        
        %%
        function [nextState] = transitionFunction(obj, state, action, varagin)  
            nextState = zeros(size(state));
            for i = 1 : size(state,1)
                obj.ball.setPos(state(i, 1:2)');
                
                obj.ball.setVel(state(i, 3:4)');
%                 velX = -sin(state(i,3));
%                 velY = -cos(state(i,3));
%                 obj.ball.setVel([velX; velY]);
                
                
                obj.ball.vel = obj.ball.vel / norm(obj.ball.vel);
                obj.field.setPaddlePosRot(action(i, 1), action(i, 2) + pi/2 );
                
                
                [hasContact, collisionIdx]  = obj.field.checkCollisions(obj.ball );
                state(i,:)                  = obj.rewardFunction(hasContact, collisionIdx, state(i,:));
                
                obj.ball.updatePos();
                
                if(obj.ball.pos(1) < -obj.fieldWidth/2 || obj.ball.pos(1) > obj.fieldWidth/2 || ...
                        obj.ball.pos(2) < - obj.fieldHeight/2 || obj.ball.pos(2) > obj.fieldHeight /2)
                    obj.ball.pos = rand(2,1);
                    %This basically shouldn't happen
                end
                
                nextState(i,:)      = [obj.ball.pos' , obj.ball.vel', obj.rewardSignal, state(i,6:end)];
                
                
%                 a = obj.ball.vel;
%                 y = [0;-1];
%                 angle = mod(atan2(a(1)*y(2)-y(1)*a(2),a(2)*y(1)+a(2)*y(2)),2*pi);
%                 nextState(i,:)      = [obj.ball.pos' , angle, 0, obj.field.rewardSignal, state(i,6:end)];
                
            end
%             plot(nextState(1,1), nextState(1,2),'ro');
%             axis([-10 10 -10 10])
%             pause(0.01)
            
        end
        
        
        %%
        function state = rewardFunction(obj, hasContact, collisionIdx, state)
            obj.rewardSignal = -0.1;
            opponentX        = state(6);
            
            if(hasContact)                
                if(collisionIdx == obj.field.outIdx)
                    obj.rewardSignal    = -1000  - 10 * abs(obj.ball.pos(1) - obj.field.walls(obj.field.paddleIdx,1));
                end
                if(collisionIdx == obj.field.topIdx)
                    oppDist = abs(obj.ball.pos(1) - (opponentX - obj.opponentWidth) );
                    if( oppDist > obj.opponentWidth/2 + 0.5 )
                        obj.rewardSignal    = 100;
                    else
                        obj.rewardSignal    = - 10 * exp(-oppDist);
                    end
                end
            end
        end
        
        
        %%
        function value = isActiveStep(obj, states, nextStates)
              value = ~(states(:,2) > obj.field.ballInitHeight  & nextStates(:,2) <= obj.field.ballInitHeight);
        end
        
        
        %%
        function value = toReserve(obj)
            value = 50;
        end
        
    end
    
end

