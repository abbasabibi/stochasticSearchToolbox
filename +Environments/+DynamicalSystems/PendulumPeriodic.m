classdef PendulumPeriodic < Environments.DynamicalSystems.ContinuousTimeDynamicalSystem & Environments.Misc.PlanarForwardKinematics
    
    properties
        masses
		inertias
		g
		sim_dt

        friction
    end
    
    properties (SetObservable,AbortSet)
        maxTorque = 30;
    end
    
    methods
        function obj = PendulumPeriodic(sampler)                   
           obj = obj@Environments.Misc.PlanarForwardKinematics(sampler, 1); 
           obj = obj@Environments.DynamicalSystems.ContinuousTimeDynamicalSystem(sampler, 1);            
           
           obj.linkProperty('maxTorque');
        
           obj.registerPlanarKinematicsFunctions();
           
		   obj.lengths 	= 0.5;
		   obj.masses 	= 10;

		   
           
           obj.dataManager.setRange('states', [-0.5*pi, -20], [1.5*pi, 20]);
           obj.dataManager.setPeriodicity('states',[true,false])
           obj.dataManager.setRange('nextStates', [-0.5*pi, -20], [1.5*pi, 20]);
           obj.dataManager.setPeriodicity('nextStates',[true,false])
           %action - friction
           % 30 - 0.3 seemed to work but was not enough
           % 0.3 at speed of 18 would be 5.4 - compared to 30 action
           % 1.0 at speed of 18 would be 18 - need at least 40 action?
           
%            maxaction = obj.maxTorque; %35; % was 30
%            obj.dataManager.setRange('actions', -maxaction, maxaction);
                
		   % around pivot:
           obj.inertias = obj.masses.*(obj.lengths.^2 )./3.0; 
           % around com
           % obj.inertias = obj.masses.*(obj.lengths.^2 + 0.0001)./12.0; %0.0001 is width squared
		   obj.g 		= 9.81;
		   obj.sim_dt 	= 1e-4;
           obj.friction = 0.3; %1.5; % was 0.3

        end
        
        
        function [xnew] = getExpectedNextStateContTime(obj, dt, x, action, varargin)
            %limit applied torque
            action = bsxfun(@max, bsxfun(@min, action, obj.maxTorque), -obj.maxTorque); 
            
            %calculate no. of simulateion steps
            nSteps = dt/obj.sim_dt;
            
            if(nSteps~=round(nSteps))
                warning('pendel:dt', 'dt does not match up')
                nSteps = round(nSteps);
            end
            
            c = obj.g * obj.lengths*obj.masses/obj.inertias;
            
            %action = 25 * ones(size(action));
            for i = 1:nSteps
                %symplectic euler
                velNew = x(:,2) + obj.sim_dt * (c  *sin(x(:,1)) + action/obj.inertias - x(:,2)* obj.friction );
                x = [x(:,1) + obj.sim_dt * velNew, velNew];
            end
            xnew = x;

            xnew(:,1) = mod(x(:,1)+0.5*pi, 2*pi)-0.5*pi;
            
            %xnew(:,1) = mod(x(:,1)+pi, 2*pi)-pi;
        end


    end
    
end
