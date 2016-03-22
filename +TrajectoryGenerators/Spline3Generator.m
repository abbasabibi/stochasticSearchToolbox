classdef Spline3Generator < TrajectoryGenerators2.TrackedTrajectoryGenerator
    
   
    methods
        
        function obj = Spline3Generator(settings, numJoints)
            
            obj = obj@TrajectoryGenerators2.TrajectoryGenerator(settings, numJoints);
            
        end
        
        
        function result = generateTrajectory(obj, initJointState,  context, action)
            % initJointState = [ pos; vel ] 2*DOF
            % action         = [ pos; vel ] 2*DOF
            
            %             dt = 1/ demo{i}.freq;
            %             hit_idx = demo{i}.tth_steps;
            %             t_end = hit_idx /  demo{i}.freq;
            
            
            y = [ initJointState; action ];
            
            
            t_end = obj.dt * obj.numTrajectorySteps;
            
            
            for j=1:obj.numJoints
                
                t = [ [ zeros(1,3),    1  ];
                    [ zeros(1,2), 1, 0  ];
                    [   t_end^3,   t_end^2,   t_end, 1  ];
                    [ 3*t_end^2,   2*t_end,       1, 0  ];
                    %[ 6*t_end  ,         2,       0, 0  ];
                    ];
                
                
                %                 y = [ initJointPos(j), initJointVel(j), finalJointPos(j), finalJointVel(j) ]';
                
                
                coeff(:,j) = t \ y(:,j); %(t'*t)^-1*t'*y
                
            end
            
            
            %             t = linspace(0,t_end,hit_idx)';
            obj.computeTime();
            t = obj.time';
            
            t_vec = [ t.^3, t.^2, t, ones(size(t,1),1) ];
            t_vecd = [ 3*t.^2, 2*t, ones(size(t,1),1), zeros(size(t,1),1) ];
            
            
            for j=1:obj.numJoints
                
                yGen(:,j)  = t_vec*coeff(:,j);
                yGend(:,j) = t_vecd*coeff(:,j);
                
            end
            
            result = { yGen, yGend };
            
        end
        
        
        
    end
    
end

