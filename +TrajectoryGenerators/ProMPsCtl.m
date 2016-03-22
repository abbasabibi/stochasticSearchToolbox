classdef ProMPsCtl < TrajectoryGenerators.TrajectoryTracker.IFbGainsProvider & Data.DataManipulator & Learner.Learner
    
    properties
        trajDistrib
        env
    end
    
    properties(AbortSet, SetObservable)
        
        estimateNoise = true;
        fullNoiseMatrix = false;
        
        numCtl = 0;        
        numTimeSteps = 100;
        dt = 0.01;
        
        Kp_t = [];
        Kd_t = [];
        k_t = [];
        Sigma_sdt = [];
        
        A = [];
        B = [];
        c = [];
        SysActionNoise = [];
        
        ctlPinvThresh=1e-3;
        
    end
    
    methods (Static)
        
        function obj = createFromTrial(trial)
            gainProvider = TrajectoryGenerators.ProMPsCtl(trial.dataManager, trial.trajectoryGenerator, trial.transitionFunction);
            obj = TrajectoryGenerators.TrajectoryTracker.TimeVarLinearController(trial.dataManager, trial.numJoints, gainProvider);
        end
    end
    
    
    methods
        
        function obj = ProMPsCtl(dataManager, trajDistrib, env)
            obj@TrajectoryGenerators.TrajectoryTracker.IFbGainsProvider();
            obj@Data.DataManipulator(dataManager);
            
            obj.trajDistrib = trajDistrib;
            obj.env = env;
            obj.numCtl = env.dimAction;
            
            [f, f_q, f_u, obj.SysActionNoise] = env.getLinearizedContinuousTimeDynamics();
            
            obj.c = [ f(1:2:end,1); f(2:2:end,1) ];
            
            obj.A = [ f_q(1:2:end,:); f_q(2:2:end,:) ];
            obj.A = [ obj.A(:,1:2:end), obj.A(:,2:2:end) ];
            
            obj.B = [ f_u(1:2:end,:); f_u(2:2:end,:) ];  
            
            obj.linkProperty('ctlPinvThresh');
            obj.linkProperty('dt');
            obj.linkProperty('numTimeSteps');
            obj.linkProperty('estimateNoise');
            
            obj.addDataManipulationFunction('getFeedbackGains', {}, ...
                      {''}, Data.DataFunctionType.PER_EPISODE, false );                                                        
            obj.setTakesData('getFeedbackGains', true);
            
            obj.addDataManipulationFunction('updateModel', {}, ...
                      {}, Data.DataFunctionType.ALL_AT_ONCE, false );                                                        
            obj.setTakesData('updateModel', true);
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
            idxPos = ((1:obj.numCtl)-1)*obj.numTimeSteps;
            idxVel = idxPos + obj.trajDistrib.numTimeSteps * obj.trajDistrib.numJoints;
            
            t = tms(1); %TODO
            
            Kp_t = obj.Kp_t(idxPos+t,:);
            Kd_t = obj.Kd_t(idxPos+t,:);
            k_t  = obj.k_t(idxPos+t);  %TODO
            Sigma_sdt_t = obj.Sigma_sdt([idxPos idxVel]+t,:);
            
            % Sigma_sdt = B * dt * Sigma_u/dt * B' * dt 
            % Sigma_u = B-1 Sigms_s B-T / dt
            % Sigma_u / dt = B-1 Sigms_s B-T / dt^2 (to scale to timestep)
            Sigma_u = obj.B \ Sigma_sdt_t / obj.B' / obj.dt^2 ...
                                            - obj.SysActionNoise / obj.dt ;
        end
            
        
        function [Kp_t, Kd_t, k_t, Sigma_sdt] = getFeedbackGains (obj, data, varargin)
            
            [mu_t, Sigma_t ] = obj.trajDistrib.callDataFunctionOutput('getExpectationAndSigma',data, varargin{:});
            [mu_td, Sigma_td_half] = obj.trajDistrib.callDataFunctionOutput('getStateDistributionD',data, varargin{:});
            Sigma_sdt = obj.compSigmaSdt (Sigma_t);            
            [K_t, k_t] = obj.getCtlGains (mu_t, mu_td, Sigma_t, Sigma_td_half, Sigma_sdt);
% if ~exist('Ks0.mat')
%     sa.K_t = K_t; sa.k_t = k_t;
%     sa.mu_t = mu_t; sa.mu_td = mu_td; sa.Sigma_t = Sigma_t; sa.Sigma_td_half = Sigma_td_half;
%     sa.Sigma_sdt = Sigma_sdt;
%     save('Ks0.mat', 'sa');
% else
%     load('Ks0.mat');
%     sa.K_t = [sa.K_t K_t];
%     sa.k_t = [sa.k_t k_t];
%     sa.mu_t = [sa.mu_t mu_t];
%     sa.mu_td = [sa.mu_td mu_td];
%     sa.Sigma_t = [sa.Sigma_t Sigma_t];
%     sa.Sigma_td_half = [sa.Sigma_td_half Sigma_td_half];
%     sa.Sigma_sdt = [sa.Sigma_sdt Sigma_sdt];
%     save('Ks0.mat', 'sa');
% end
    
            Kp_t = K_t(:,1:obj.trajDistrib.numJoints);
            Kd_t = K_t(:,(1:obj.trajDistrib.numJoints)+obj.trajDistrib.numJoints);
            
        end
        
        %%  
        
        function Sigma_sdtNew_diag = boundToSysNoise (obj,Sigma_sdt_diag)
            
            Bhat = obj.B(obj.trajDistrib.numJoints+1:end,:);
          
            %  Bhat * dt * SysActionNoise/dt * Bhat' * dt 
            SysNoise = Bhat * obj.SysActionNoise * Bhat' .* obj.dt;
            
            % Sigma_sdt = Bhat * dt * Sigma_u/dt * Bhat' * dt 
            
            if (obj.estimateNoise)
                Sigma_sdtNew_diag = max(0, Sigma_sdt_diag - diag(SysNoise) );
                Sigma_sdtNew_diag = Sigma_sdtNew_diag + diag(SysNoise);
            else
                Sigma_sdtNew_diag = diag(SysNoise);
            end
           
        end
        
        
        function Sigma_sdt = compSigmaSdt(obj,Sigma_t_all)
            
            idxPos = ((1:obj.trajDistrib.numJoints)-1)*obj.trajDistrib.numTimeSteps;
            idxVel = idxPos + obj.trajDistrib.numTimeSteps * obj.trajDistrib.numJoints;
            idx_off = [ idxPos, idxVel];
            
            Sigma_sdt = zeros(2*obj.trajDistrib.numJoints*obj.trajDistrib.numTimeSteps,2*obj.trajDistrib.numJoints);
            Sigmask = (1:obj.trajDistrib.numJoints)+obj.trajDistrib.numJoints;
            Sigmask = size(Sigma_sdt,1) * (Sigmask - 1); 
            for t=1:(obj.trajDistrib.numTimeSteps-1)
                
                idx = idx_off + t;
                Sigma_t    = Sigma_t_all(idx,idx);
                Sigma_t1   = Sigma_t_all(idx+1,idx+1);
                Sigma_t_t1 = Sigma_t_all(idx,idx+1);
                
                % Sigma_u(idx,:) = Sigma_t1 - Sigma_t_t1' / Sigma_t * Sigma_t_t1;
              %  tmp = diag(Sigma_t1 - Sigma_t_t1' / Sigma_t * Sigma_t_t1);
              tmp = diag(Sigma_t1 - Sigma_t_t1' * pinv( Sigma_t, obj.ctlPinvThresh) * Sigma_t_t1);
              tmp = tmp(length(tmp)/2+1:end);
                
                tmp = obj.boundToSysNoise(tmp);
                Sigma_sdt( (idxVel+t)+Sigmask  ) = tmp;
                
            end            
            Sigma_sdt(idx+1,:) = Sigma_sdt(idx,:);
            
        end
        
        function [K_t_all, k_t_all] = getCtlGains (obj, mu_x_all, mu_xd_all, Sigma_t_all, Sigma_td_half_all, Sigma_u_all)
                        
            idxPos = ((1:obj.trajDistrib.numJoints)-1)*obj.numTimeSteps;            
            idxVel = idxPos + obj.numTimeSteps * obj.trajDistrib.numJoints;
            idx_off = [idxPos, idxVel];
            
            idxCtl_off = ((1:obj.numCtl)-1)*obj.numTimeSteps;
            
            %%%%%%%
            % u1_t1 =  P1_t1 P2_t1 P3_t1 D1_t1 D2_t1 D3_t1
            % u1_t2 =  P1_t2 P2_t2 P3_t2 D1_t2 D2_t2 D3_t2
            % u2_t1 =  P1_t1 P2_t1 P3_t1 D1_t1 D2_t1 D3_t1
            % u2_t2 =  P1_t2 P2_t2 P3_t2 D1_t2 D2_t2 D3_t2
            %                 ....
            K_t_all = zeros(obj.numTimeSteps*obj.numCtl,2*obj.trajDistrib.numJoints);
            k_t_all = zeros(obj.numTimeSteps*obj.numCtl,1);
            
            for t=1:(obj.numTimeSteps)
                
                idx = idx_off + t;
                
                Sigma_t = Sigma_t_all(idx,idx);
            
                Sigma_u       = Sigma_u_all(idx,:);
                Sigma_td_half = Sigma_td_half_all(idx,idx);
                
                mu_x   = mu_x_all(idx);
                mu_xd  = mu_xd_all(idx);
            
                % M_temp = Sigma_td_half;
                % M_temp = (M_temp + M_temp') / 2;
                % M_temp(obj.numJoints+1:end,obj.numJoints+1:end) = M_temp(obj.numJoints+1:end,obj.numJoints+1:end)';
                M = Sigma_td_half - obj.A * Sigma_t - 0.5 * Sigma_u / obj.dt;
                
                % M(obj.numJoints+1:end,obj.numJoints+1:end) = M(obj.numJoints+1:end,obj.numJoints+1:end)';
                % M(obj.numJoints+1:end,obj.numJoints+1:end) = 0.5*(M(obj.numJoints+1:end,obj.numJoints+1:end)'+M(obj.numJoints+1:end,obj.numJoints+1:end));
                
                % M(obj.numJoints+1:end,obj.numJoints+1:end) = tril(...
                %  (M(obj.numJoints+1:end,obj.numJoints+1:end)'+M(obj.numJoints+1:end,obj.numJoints+1:end)))...
                %  -diag(diag(M(obj.numJoints+1:end,obj.numJoints+1:end)));
                
               % K_t = (obj.B \ M / Sigma_t);
                 K_t = (obj.B \ M ) * pinv(Sigma_t, obj.ctlPinvThresh);
                 
                % K_t(:,obj.numJoints+1:end) = K_t(:,obj.numJoints+1:end)';
                
                % B_hat = B(obj.trajDistrib.numJoints+1:end, :);
                % tmp = mu_xd-(A+B*K_t)*mu_x-c;
                % k_t = B_hat \ tmp(obj.trajDistrib.numJoints+1:end, :);
                % k_t = B_hat \ [ zeros(obj.trajDistrib.numJoints), eye(obj.trajDistrib.numJoints) ] * (mu_xd-(A+B*K_t)*mu_x-c);                
                k_t1 = obj.B \ (mu_xd-(obj.A+obj.B*K_t)*mu_x-obj.c);  %faster than the prev two ways
                
                idxCtl = idxCtl_off + t;
                K_t_all(idxCtl,:) = K_t;
                k_t_all(idxCtl,1) = k_t1;
            
            end
            
        end
 
    end

end
