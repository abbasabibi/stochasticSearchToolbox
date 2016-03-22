classdef Walls < Common.IASObject
    %WALLS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        walls       %[xCenter, yCenter, width, height, angle, isActive] Nx6 Vector
        width 
        height
        paddleWidth     = 4;
        
        paddleIdx
        outIdx
        topIdx
        wallThickness   = 2;
        paddleCollision = false;
        outCollision    = false;
        hasCollision    = false;
        
        newStage        = false;
        topHitPos       = 0;
        ballInitHeight
        
%         rewardSignal
        
        wallHandles     = [];
        bricksIdx       = [];
        
        goalPos         = [-2; 2];
        
        enablePlotting  = false;
    end
    
    methods
        function obj = Walls(width, height)
            obj.width   = width;
            obj.height  = height;
        end
        
        
        %%
        function createPlayingField(obj)
            top     = obj.height/2;
            down    = -top;
            right   = obj.width/2;
            left    = -right;
            
            %[xCenter, yCenter, width, height, angle, isActive] Nx6 Vector
            obj.walls(1,:)  = [0, down, obj.wallThickness,  obj.width, pi/2, 1];               %Bottom wall
            obj.walls(2,:)  = [0, top, obj.wallThickness,  obj.width, -pi/2, 1];               %Top wall
            obj.walls(3,:)  = [left, 0, obj.wallThickness, obj.height, 0, 1];                  %Left wall
            obj.walls(4,:)  = [right, 0, obj.wallThickness, obj.height, pi, 1];                %Right wall
            obj.walls(5,:)  = [0, down+obj.wallThickness+1, 1, obj.paddleWidth, pi/2, 1];      %Paddle 
            
            obj.paddleIdx   = 5; 
            obj.outIdx      = 1;      
            obj.topIdx      = 2;
            
            obj.ballInitHeight = top - 3 * obj.wallThickness - 1;
            
        end
        
        %%
        function createBrickLine(obj, numBricks)
            numWalls    = size(obj.walls,1);
            posTop      = obj.height/2 - 2 * obj.wallThickness;
            widthBrick  = obj.width / numBricks;            
            for i = 1 : numBricks
                posX    = -obj.width/2 + widthBrick/2 + (i-1) * widthBrick;
                obj.walls(numWalls + i,:)  = [posX, posTop, obj.wallThickness,  widthBrick, -pi/2, 1];
            end
            obj.bricksIdx = [numWalls+1 : numWalls + numBricks];
        end
        
        %%
        function setPaddlePos(obj, pos, angle)
            obj.walls(obj.paddleIdx,1) = pos - obj.walls(obj.paddleIdx,3);
            obj.walls(obj.paddleIdx,5) = angle;
        end
        
        %%
        function [contact, collisionIdx] = checkCollisions(obj, ball)
            obj.paddleCollision = false;
            obj.outCollision    = false;
            obj.hasCollision    = false;
%             obj.rewardSignal    = -0.1;
            collisionIdx = 0;
            
%             for i = 1 : size(obj.walls,1)
            contact             = false;
            i                   = 1;
            while (i <=size(obj.walls,1) && ~contact )
                theta   = obj.walls(i,5);
                R       = [cos(theta), -sin(theta); sin(theta), cos(theta)];
                center  = [obj.walls(i,1); obj.walls(i,2)];   
                p1      = [obj.walls(i,1:2)]' + [0; obj.walls(i,4)];
                p2      = [obj.walls(i,1:2)]' - [0; obj.walls(i,4)];
                p1      = R * (p1 - center) + center;
                p2      = R * (p2 - center) + center;

                N       = [cos(theta); sin(theta)];
                NInv    = [N(2); N(1)];
              

                dist    = ball.pos(1) * (p2(2)-p1(2)) - ball.pos(2) * (p2(1)-p1(1)) + p2(1)*p1(2) - p2(2)*p1(1);
                dist    = abs(dist) / sqrt( ((p2(2)-p1(2))^2 + (p2(1)-p1(1))^2 ) );
                intersect = dist <= obj.wallThickness/2;
                contact = intersect &&  norm(ball.pos - center) < obj.walls(i,4)/2;
                if( contact && obj.walls(i,6)==1 )
                   newVel  = ball.vel - 2 * N * (ball.vel' * N);
%                     newVel  = newVel / norm(newVel) * norm(ball.vel);
                    ball.setVel(newVel *1.5); %Get out of infinite contacts
                    collisionIdx = i;
                    
%                     
%                     if(i == obj.paddleIdx) 
%                         obj.paddleCollision = true;
%                         obj.hasCollision    = true;
%                     end
%                     if(i == obj.outIdx)
%                         obj.outCollision    = true;
%                         obj.hasCollision    = true;
% %                         ball.setPos( [(rand -0.5) .*  obj.width; obj.ballInitHeight] )
%                         obj.rewardSignal    = -1000  - 10 * abs(ball.pos(1) - obj.walls(obj.paddleIdx,1));
%                     end
%                     if(i == obj.topIdx)
%                         oppDist = abs(ball.pos(1) - (opponentX - obj.opponentWidth) );
%                         if( oppDist > obj.opponentWidth/2 + 0.5 ) 
%                             obj.rewardSignal    = 100;
%                         else
%                             obj.rewardSignal    = - 10 * exp(-oppDist); 
%                         end
% %                         obj.topHitPos       = ball.pos(1);
% %                         goalDiff            = abs(obj.goalPos - ball.pos(1));
% %                         obj.rewardSignal    = - 10 * min(goalDiff);
%                     end
                end
                i = i+1;
            end
            
            
            
            if(obj.enablePlotting)
                ball.plot();
            end
            
        end
        
        
        %%
        function setPaddlePosRot(obj, pos, theta)
            obj.walls(obj.paddleIdx,1) = pos;
            obj.walls(obj.paddleIdx,5) = theta;
            
            if(obj.enablePlotting) 
                obj.plotField();
            end
        end
        
        %%
        function plotField(obj)
            for i = 1 : length(obj.wallHandles)
                if(ishandle(obj.wallHandles(i)) )
                    delete(obj.wallHandles(i));
                end
            end

            for i = 1 : size(obj.walls,1)
                left    = obj.walls(i,1) - obj.walls(i,3)/2;
                right   = obj.walls(i,1) + obj.walls(i,3)/2;
                down    = obj.walls(i,2) - obj.walls(i,4)/2;
                up      = obj.walls(i,2) + obj.walls(i,4)/2;
                
                x = [left, right, right, left ];
                y = [down, down, up, up];
                
                color = [0.7, 0.3, 0];
                if(obj.walls(i,6) == 0)
                    color = [0.3, 0.3, 0.3];
                end
                obj.wallHandles(i) = patch(x, y, zeros(1,4), color);
                rotate(obj.wallHandles(i), [0,0,1], obj.walls(i,5) * 180/pi, [obj.walls(i,1), obj.walls(i,2), 0] );
            end
         
            axis([-obj.width/2, obj.width/2, -obj.height/2, obj.height/2])
            pause(0.01)

        end
        
        %%
        function isNewStage = checkIsNewStage(obj, ball)
            isNewStage = false;
            
            %If ball is moving up above limit we change to new stage. 
            if(~obj.isNewStage && bal.pos(2) > obj.ballInitHeight && ball.vel(2) > 0 )
                obj.isNewStage  = true;
                isNewStage      = true;
            end
            
            %If ball is moving below limit we reset newStage
            if(obj.isNewStae && ball.pos(2) < obj.ballInitHeight && ball.vel(2) < 0 )
                obj.isNewStage  = false;
            end         
            
            
        end
        
    end
    
end

