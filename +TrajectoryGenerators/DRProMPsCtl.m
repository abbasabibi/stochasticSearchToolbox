classdef DRProMPsCtl < TrajectoryGenerators.ProMPsCtl
    
    %     properties
    %         trajDistrib
    %         env
    %     end
    
    properties(AbortSet, SetObservable)
        
        %         estimateNoise = true;
        %         fullNoiseMatrix = false;
        %
        %         numCtl = 0;
        %         numTimeSteps = 100;
        %         dt = 0.01;
        %
        %         Kp_t = [];
        %         Kd_t = [];
        %         k_t = [];
        %         Sigma_sdt = [];
        %
        %         A = [];
        %         B = [];
        %         c = [];
        %         SysActionNoise = [];
        
    end
    
    methods
        
        function obj = DRProMPsCtl(dataManager, trajDistrib, env)
            obj=obj@TrajectoryGenerators.ProMPsCtl(dataManager, trajDistrib, env)
            %             obj@TrajectoryGenerators.TrajectoryTracker.IFbGainsProvider();
            %             obj@Data.DataManipulator(dataManager);
            
            %             obj.trajDistrib = trajDistrib;
            %             obj.env = env;
            %             obj.numCtl = env.dimAction;
            %
            %             [f, f_q, f_u, obj.SysActionNoise] = env.getLinearizedContinuousTimeDynamics();
            %
            %             obj.c = [ f(1:2:end,1); f(2:2:end,1) ];
            %
            %             obj.A = [ f_q(1:2:end,:); f_q(2:2:end,:) ];
            %             obj.A = [ obj.A(:,1:2:end), obj.A(:,2:2:end) ];
            %
            %             obj.B = [ f_u(1:2:end,:); f_u(2:2:end,:) ];
            %
            %             obj.linkProperty('dt');
            %             obj.linkProperty('numTimeSteps');
            %             obj.linkProperty('estimateNoise');
            %
            %             obj.addDataManipulationFunction('getFeedbackGains', {}, ...
            %                       {''}, Data.DataFunctionType.PER_EPISODE, false );
            %             obj.setTakesData('getFeedbackGains', true);
            %
            %             obj.addDataManipulationFunction('updateModel', {}, ...
            %                       {}, Data.DataFunctionType.ALL_AT_ONCE, false );
            %             obj.setTakesData('updateModel', true);
        end
        
        %% Interface implementation
        
        function [] =  updateModel ( obj, data)
            [ Kp_t1, Kd_t1, k_t1, Sigma_sdt1 ] = obj.getFeedbackGains ( data, 1, :); %basis the same
            obj.Kp_t = Kp_t1;
            obj.Kd_t = Kd_t1;
            obj.k_t  = k_t1;
            obj.Sigma_sdt = Sigma_sdt1;
        end
        
        function  [Kp_t, Kd_t, k_t, Sigma_u]  = getFeedbackGainsForT (obj, tms)
            idxPos = ((1:obj.trajDistrib.numJoints)-1)*obj.numTimeSteps;
            idxVel = idxPos + obj.trajDistrib.numJoints * obj.trajDistrib.numTimeSteps;
            idxPosL = ((1:obj.trajDistrib.redDimension)-1)*obj.numTimeSteps;
            idxVelL = idxPosL + obj.trajDistrib.redDimension * obj.trajDistrib.numTimeSteps;
            
            t = tms(1); %TODO
            Om=obj.trajDistrib.ProjectionMatrix;
            Omi=pinv(Om);
            Om2=kron(eye(2),Om);
            Om2i=pinv(Om2);
            
            Kp_t = obj.Kp_t(idxPos+t,:);
            Kd_t = obj.Kd_t(idxPos+t,:);
            k_t  = obj.k_t(idxPos+t);  %TODO
            Sigma_sdt_t = obj.Sigma_sdt([idxPosL idxVelL]+t,:);
            % Sigma_sdt = B * dt * Sigma_u/dt * B' * dt
            % Sigma_u = B-1 Sigms_s B-T / dt
            % Sigma_u / dt = B-1 Sigms_s B-T / dt^2 (to scale to timestep)
            Sigma_u = obj.B \ Om2*Sigma_sdt_t*Om2' / obj.B' / obj.dt^2 ;
            
        end
        
        
        function [Kp_t, Kd_t, k_t, Sigma_sdt] = getFeedbackGains (obj, data, varargin)
            [mu_t, Sigma_t,mu_x,Sigma_x ] = obj.trajDistrib.callDataFunctionOutput('getStateDistributionLatent',data, varargin{:});
            [mu_td, Sigma_td_half,mu_xd,Sigma_xd_half] = obj.trajDistrib.callDataFunctionOutput('getStateDistributionDLatent',data, varargin{:});
            Om=obj.trajDistrib.ProjectionMatrix;
            Sigma_sdt = obj.compSigmaSdt (Sigma_x);
            % getCtlGains provides the gains for all timesteps!!
            [K_t, k_t] = obj.getCtlGains (mu_x, mu_xd, Sigma_x, Sigma_xd_half, Sigma_sdt);
            % as we will be multiplying the gains with the full state
            % observations, we postmultiply by the pseudoinverse, as
            % x=pinv(Om)*y.
            Kp_t = K_t(:,1:obj.trajDistrib.numJoints);
            Kd_t = K_t(:,(1:obj.trajDistrib.numJoints)+obj.trajDistrib.numJoints);
            
        end
        
        %%
        
        function Sigma_sdtNew_diag = boundToSysNoise (obj,Sigma_sdt_diag)
            Om=obj.trajDistrib.ProjectionMatrix;
            
            Bhat = obj.B(obj.trajDistrib.numJoints+1:end,:);
            
            %  Bhat * dt * SysActionNoise/dt * Bhat' * dt
            SysNoise = pinv(Om)*Bhat * obj.SysActionNoise * Bhat' .* obj.dt*Om;
            
            % Sigma_sdt = Bhat * dt * Sigma_u/dt * Bhat' * dt
            
            if (obj.estimateNoise)
                Sigma_sdtNew_diag = max(0, Sigma_sdt_diag - diag(SysNoise) );
                Sigma_sdtNew_diag = Sigma_sdtNew_diag + diag(SysNoise);
            else
                Sigma_sdtNew_diag = diag(SysNoise);
            end
            
        end
        
        
        function Sigma_sdt = compSigmaSdt(obj,Sigma_t_all)
            
            idxPos = ((1:obj.trajDistrib.redDimension)-1)*obj.trajDistrib.numTimeSteps;
            idxVel = idxPos + obj.trajDistrib.numTimeSteps * obj.trajDistrib.redDimension;
            idx_off = [ idxPos, idxVel];
            
            Sigma_sdt = zeros(2*obj.trajDistrib.redDimension*obj.trajDistrib.numTimeSteps,2*obj.trajDistrib.redDimension);
            Sigmask = (1:obj.trajDistrib.redDimension)+obj.trajDistrib.redDimension;
            Sigmask = size(Sigma_sdt,1) * (Sigmask - 1);
            for t=1:(obj.trajDistrib.numTimeSteps-1)
                
                idx = idx_off + t;
                Sigma_t    = Sigma_t_all(idx,idx);
                Sigma_t1   = Sigma_t_all(idx+1,idx+1);
                Sigma_t_t1 = Sigma_t_all(idx,idx+1);
                
                % Sigma_u(idx,:) = Sigma_t1 - Sigma_t_t1' / Sigma_t * Sigma_t_t1;
                tmp = diag(Sigma_t1 - Sigma_t_t1' / Sigma_t * Sigma_t_t1);
                tmp = tmp(length(tmp)/2+1:end);
                
                tmp = obj.boundToSysNoise(tmp);
                Sigma_sdt( (idxVel+t)+Sigmask  ) = tmp;
                
            end
            Sigma_sdt(idx+1,:) = Sigma_sdt(idx,:);
            
        end
        
        function [K_t_all, k_t_all] = getCtlGains (obj, mu_x_all, mu_xd_all, Sigma_x_all, Sigma_xd_half_all, Sigma_u_all)
            % provides the matrix Kt in the lower dimensionality state
            % space, premultiplied by Omega to project it to the full space
            idxPos = ((1:obj.trajDistrib.redDimension)-1)*obj.numTimeSteps;
            idxVel = idxPos + obj.numTimeSteps * obj.trajDistrib.redDimension;
            idx_off = [idxPos, idxVel];
            
            idxCtl_off = ((1:obj.numCtl)-1)*obj.numTimeSteps;
            
            K_t_all = zeros(obj.numTimeSteps*obj.trajDistrib.numJoints,2*obj.trajDistrib.numJoints);
            k_t_all = zeros(obj.numTimeSteps*obj.trajDistrib.numJoints,1);
            Om=obj.trajDistrib.ProjectionMatrix;
            Omi=pinv(Om);
            Om2=kron(eye(2),Om);
            Om2i=pinv(Om2);
            for t=1:(obj.numTimeSteps)
                
                idx = idx_off + t;
                
                Sigma_t = Sigma_x_all(idx,idx);
                
                Sigma_u       = Sigma_u_all(idx,:);
                Sigma_td_half = Sigma_xd_half_all(idx,idx);
                
                mu_x   = mu_x_all(idx);
                mu_xd  = mu_xd_all(idx);
                
                M = Om2*Sigma_td_half - obj.A*Om2* Sigma_t - 0.5 *Om2*Sigma_u / obj.dt;
                
                K_t = Om'*(obj.B \ M / Sigma_t);
                k_t1 = Omi*(obj.B \ (  Om2*mu_xd-(obj.A*Om2+obj.B*Om*K_t)*mu_x-obj.c));  %faster than the prev two ways
                
                idxCtl = idxCtl_off + t;
                Nkernel=1000*eye(obj.numCtl); %HEURISTIC
                %Also, we add a term which is pushing the state towards the
                %latent space (i.e., tries to eliminate y-P(y), where P is the projection of y to the latent space.
                
                K_t_all(idxCtl,:) = Om*K_t*pinv(Om2)-kron([1 1],Nkernel*(eye(obj.numCtl)-Om*pinv(Om)));
                k_t_all(idxCtl,1) = Om*k_t1;
                
            end
        end
        
    end
    
end
