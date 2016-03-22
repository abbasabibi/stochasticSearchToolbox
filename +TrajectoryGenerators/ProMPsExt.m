classdef ProMPMovementGeneratorExt < TrajectoryGenerators.ProbabilisticMovementPrimitiveMovementGenerator 
    
    
    properties
       
        extObsProvider;
        
        joint_pmp;
        
        cond_pmps = {};
        cond_pmps_times = [];
        
    end

    
    methods
        
        
        function obj = ProMPMovementGeneratorExt(settings, transitionFunction, pmp, extObsProvider)
            

            st_pmp = TrajectoryGenerators.ProbabilisticMovementPrimitives(settings, pmp.numJoints-extObsProvider.extDim, pmp.basisFunction, ...
               pmp.phaseFunction );
           
            idx_end = pmp.settings.parameterStructure.numBasis * (pmp.numJoints-extObsProvider.extDim);
            st_pmp.setDistribution (pmp.MuA(1:idx_end), pmp.SigmaA(1:idx_end,1:idx_end),false,false );
           
            obj = obj@TrajectoryGenerators.ProbabilisticMovementPrimitiveMovementGenerator(settings, transitionFunction, st_pmp);
            
            obj.registerParameters(settings);
            obj.extObsProvider = extObsProvider;
            
            
            obj.joint_pmp = pmp;
            
        end   
        
        
        function [obj] = updateModel(obj, data)
            
            obj.joint_pmp.updateModel(data);
            
            numBasis = obj.pmp.settings.parameterStructure.numBasis;            
            idx_end = numBasis * obj.numJoints;
            
            obj.pmp.setDistribution (obj.joint_pmp.MuA(1:idx_end), obj.joint_pmp.SigmaA(1:idx_end,1:idx_end),false,false ); 
            
            if (obj.precalculateGains)
                obj.updatePreCalcGains(); 
            end
            
        end
        

    
        function [outArgs] = generateTrajectory(obj, startQ, context, action)
            
%             outArgs = obj.generateTrajectory@TrajectoryGenerators.ProbabilisticMovementPrimitiveMovementGenerator(startQ, context, action);
%             
%             return
  
            q = zeros(length(obj.pmp.getPhase()), obj.dynamicalSystem.dimState);
            u = zeros(length(obj.pmp.getPhase()) - 1, obj.dynamicalSystem.dimAction);   
            offsets = zeros(obj.dynamicalSystem.dimAction,length(obj.pmp.getPhase())-1);
            pdGains = zeros(obj.dynamicalSystem.dimAction, 2*obj.dynamicalSystem.dimAction, length(obj.pmp.getPhase()) -1);
            q(1, :) = startQ;
            Sigma_u = zeros(obj.numJoints, length(obj.pmp.getPhase()));
            
            Sig_t_eig = zeros(length(obj.pmp.getPhase()), obj.dynamicalSystem.dimState);
            
            numBasis = obj.pmp.settings.parameterStructure.numBasis;
            idx_end = numBasis * obj.numJoints;
            
            persistent trCount;
            if ( isempty(trCount) )
                trCount = 0;
            end
            
            trCount = trCount + 1;
            fprintf('Simulating %d traj\n',trCount);
            
            obj.cond_pmps = {};
            obj.cond_pmps_times = [];
            obj.extObsProvider.initObsProvider();%obj.pmp.getPhase(),obj.pmp.phaseFunction.phaseTimeStep); % test
            
            
            phase = obj.pmp.getPhase();
            
            cond_pmp =obj.joint_pmp;
            
            for n = 1:(length(phase)-1)
                
                
                [cond_y cond_sigma cond_mask cond_t] = obj.extObsProvider.getNewObs( phase(n) );
                
                
                
                if ( ~isempty(cond_y) )
                    
                    mask = [  zeros( 2*obj.numJoints , 1); cond_mask; ];
                    
                    

                    
                    for i=1:length(cond_y)
                        
                        cond_pmp = cond_pmp.conditionTrajectory( cond_t{i}, cond_y{i}, cond_sigma{i}, mask);
                        
                    end
                    
                    
                    obj.pmp.setDistribution (cond_pmp.MuA(1:idx_end), cond_pmp.SigmaA(1:idx_end,1:idx_end) );
                    
                    obj.cond_pmps{end+1} = {cond_pmp};
                    obj.cond_pmps_times(end+1) = phase(n);
                    
                    
                    if (obj.precalculateGains)
                        % obj.updatePreCalcGains(1,(length(obj.pmp.getPhase())-1));
                        obj.updatePreCalcGains(n,n+obj.extObsProvider.extProvFreq+10); % FIXME
                    end
                    
                end

                
                [ q, u, offsets(:,n), pdGains(:,:,n), Sig_t_eig(n,:), Sigma_u(:,n) ] = simulateStep (obj, q, u, n);

            end
            
            
            
            time = obj.phaseTimeStep:obj.phaseTimeStep:(length(obj.pmp.getPhase()) * obj.phaseTimeStep);
            outArgs = {{q}, {u}, {time}, {offsets}, {pdGains}, {Sig_t_eig}, {Sigma_u} };
            
                        
            obj.pmp.setDistribution (obj.joint_pmp.MuA(1:idx_end), obj.joint_pmp.SigmaA(1:idx_end,1:idx_end),false,false ); 
            
            if (obj.precalculateGains)
                obj.updatePreCalcGains();
            end
            

        end
    end
 
end
