classdef Ball < Common.IASObject
    %BALL Summary of this class goes here
    %   Detailed explanation goes here
    
    
    properties
        pos     = [0; 0];
        vel     = [0; 0];
        ballHandle = [];
        dt      = 1;
        
        ballTraj = [];
    end
    
    methods
        function obj = Ball()
            obj.ballTraj    = obj.pos;
        end
        
        function setPos(obj, pos)
            obj.pos = pos;
        end
        
        function setVel(obj, vel)
            obj.vel = vel;
        end
        
        function updatePos(obj)
            obj.pos         = obj.pos + obj.vel * obj.dt;
            obj.ballTraj    = [obj.ballTraj, obj.pos];
        end
        
        function plot(obj, drawTraj, field)
            hold on
            if(~exist('drawTraj','var') )
                drawTraj = false;
            end
            
            
            if(~drawTraj)
                delete(obj.ballHandle);
                obj.ballHandle = plot(obj.pos(1), obj.pos(2), 'ro', 'MarkerSize', 5, 'LineWidth', 3);
                pause(0.01)
            else
                if(field.hasCollision )
                    for i = 1 : length(obj.ballHandle)
                        delete(obj.ballHandle(i));                         
                    end
                    obj.ballHandle  = [];
                    for i = 1 : size(obj.ballTraj,2)
                        obj.ballHandle(i) = plot(obj.ballTraj(1,i), obj.ballTraj(2,i), 'ro', 'MarkerSize', 5, 'LineWidth', 3);
                    end
                    obj.ballTraj    = [];
                    
                    pause(0.01)
%                     pause
                end
            end
            
            
        end
        
        
    end
    
end

