classdef Pendulum < Environments.DynamicalSystems.ContinuousTimeDynamicalSystem & Environments.Misc.PlanarForwardKinematics
    
    properties(SetObservable, AbortSet)
       periodicRange = [-0.5 * pi, 1.5 * pi]; 
       maxTorque = 30;
       NoiseState = 0;
       
       stateMinRange   = [-pi, -20];
       stateMaxRange   = [pi, 20];
       actionMaxRange  = 500;
    end
    
    properties
        masses
        inertias
        g
        sim_dt
        
        isPeriodic
        friction
    end
    
    methods
        function obj = Pendulum(sampler, isPeriodic)
            obj = obj@Environments.Misc.PlanarForwardKinematics(sampler, 1);
            obj = obj@Environments.DynamicalSystems.ContinuousTimeDynamicalSystem(sampler, 1);
            
            obj.linkProperty('periodicRange');
            obj.linkProperty('maxTorque');
            obj.linkProperty('NoiseState');
            obj.linkProperty('stateMinRange', 'pendulumStateMinRange');
            obj.linkProperty('stateMaxRange', 'pendulumStateMaxRange');
            obj.linkProperty('actionMaxRange', 'pendulumActionMaxRange')
            
            
            obj.registerPlanarKinematicsFunctions();
            
            obj.lengths 	= 0.5;
            obj.masses 	= 10;
            
            obj.isPeriodic = isPeriodic;
            if (isPeriodic)
                obj.dataManager.setPeriodicity('states', [true, false]);
%                obj.dataManager.setRange('states', [-pi, -50], [pi, 50]);
            else
%                obj.dataManager.setRange('states', [-2*pi, -50], [2*pi, 50]);
            end
            
            obj.dataManager.setRange('states', obj.stateMinRange, obj.stateMaxRange);
            obj.dataManager.setRange('actions', -obj.actionMaxRange, obj.actionMaxRange);

            obj.dataManager.finalizeDataManager();
            
            %action - friction
            % 30 - 0.3 seemed to work but was not enough
            % 0.3 at speed of 18 would be 5.4 - compared to 30 action
            % 1.0 at speed of 18 would be 18 - need at least 40 action?
            
%             maxaction = 30; %35; % was 30
%             obj.dataManager.setRange('actions', -maxaction, maxaction);
            
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
%             action = bsxfun(@max, bsxfun(@min, action, obj.maxRangeAction), obj.minRangeAction);
            action = bsxfun(@max, bsxfun(@min, action, obj.maxTorque), -obj.maxTorque);
            %action = action + (randn(size(action))-0.5) * obj.NoiseState;
            
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
            
        end
        
    end
    
end
