classdef RandomEventPendulum < Environments.DynamicalSystems.ContinuousTimeDynamicalSystem & Environments.Misc.PlanarForwardKinematics
    
    properties
        masses
        inertias
        g
        sim_dt
        
        isPeriodic
        friction
        
        lowGProb = 1/30;
        lowGCounter = 0
    end
    
    methods
        function obj = RandomEventPendulum(sampler, isPeriodic)
            obj = obj@Environments.Misc.PlanarForwardKinematics(sampler, 1);
            obj = obj@Environments.DynamicalSystems.ContinuousTimeDynamicalSystem(sampler, 1);
            
            obj.registerPlanarKinematicsFunctions();
            
            obj.lengths 	= 0.5;
            obj.masses 	= 10;
            
            obj.isPeriodic = isPeriodic;
            if (isPeriodic)
                obj.dataManager.setPeriodicity('states', [true, false]);
                obj.dataManager.setRange('states', [-pi, -50], [pi, 50]);
            else
                obj.dataManager.setRange('states', [-2*pi, -50], [2*pi, 50]);
            end
            
            %action - friction
            % 30 - 0.3 seemed to work but was not enough
            % 0.3 at speed of 18 would be 5.4 - compared to 30 action
            % 1.0 at speed of 18 would be 18 - need at least 40 action?
            
            maxaction = 30; %35; % was 30
            obj.dataManager.setRange('actions', -maxaction, maxaction);
            
            % around pivot:
            obj.inertias = obj.masses.*(obj.lengths.^2 )./3.0;
            % around com
            % obj.inertias = obj.masses.*(obj.lengths.^2 + 0.0001)./12.0; %0.0001 is width squared
            obj.g 		= 9.81;
            obj.sim_dt 	= 1e-4;
            obj.friction = 0.2; %1.5; % was 0.3
            
        end
        
        
        function [xnew] = getExpectedNextStateContTime(obj, dt, x, action, varargin)
            %limit applied torque
            action = bsxfun(@max, bsxfun(@min, action, obj.maxRangeAction), obj.minRangeAction);
            
            %calculate no. of simulateion steps
            nSteps = dt/obj.sim_dt;
            
            if(nSteps~=round(nSteps))
                warning('pendel:dt', 'dt does not match up')
                nSteps = round(nSteps);
            end
            
%             if length(obj.lowGCounter) ~= size(x,1)
%                 obj.lowGCounter = zeros(size(x,1),1);
%             end
%             
%             obj.lowGCounter(rand(size(x,1),1) < obj.lowGProb) = 4;
            m = size(x,1);
            switchVel = rand(m,1) < obj.lowGProb;
            x(switchVel,2) = -x(switchVel,2);
            
            g_ = ones(size(x,1),1) * obj.g;
%             g_(obj.lowGCounter > 0) = .25 * obj.g;
%             obj.lowGCounter = obj.lowGCounter - 1;
            
            c = g_ * obj.lengths*obj.masses/obj.inertias;
            %action = 25 * ones(size(action));
            for i = 1:nSteps
                %symplectic euler
                velNew = x(:,2) + obj.sim_dt * (c  .*sin(x(:,1)) + action/obj.inertias - x(:,2)* obj.friction );
                x = [x(:,1) + obj.sim_dt * velNew, velNew];
            end
            xnew = x;
            
        end
        
    end
    
end
