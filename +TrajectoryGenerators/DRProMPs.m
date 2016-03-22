classdef DRProMPs < TrajectoryGenerators.ProMPs
    properties
        % properties
        redDimension % reduced dimensionality for the DR-ProMP
        ProjectionMatrix % Linear projection matrix for the DR-ProMP. It is the Identity matrix for the full dimension
        SystemNoise % Sy matrix of the ProMP
        isDRProMPInitialized % indicates if all the ProMP parameters are already initialized from data
        %  TrainingData % data corresponing to rollouts used for the last update
        ComputeLikelihood % indicates if we want to compute the likelihood at each iteration (computationaly costly-ish)
        
        
    end
    methods
          function obj = DRProMPs(dataManager, numJoints, r,P)
            obj=obj@TrajectoryGenerators.ProMPs(dataManager, r );
            obj.redDimension=r;
            obj.ProjectionMatrix=P;
            obj.isDRProMPInitialized=0;
            obj.numJoints=numJoints;
            obj.ComputeLikelihood=0;
            
            obj.registerTrajectoryFunction(); 
            obj.registerMappingInterfaceDistribution();
            obj.setCallType('sampleFromDistribution',Data.DataFunctionType.PER_EPISODE);
            obj.addDataManipulationFunction('getStateDistributionLatent', {'basis', 'basisD', 'context'}, ...
                {'mu_t', 'Sigma_t','mu_x', 'Sigma_x'}, Data.DataFunctionType.PER_EPISODE );
            
            obj.addDataManipulationFunction('getStateDistributionDLatent', {'basis', 'basisD', 'basisDD', 'context'}, ...
                {'mu_td', 'Sigma_td_half','mu_xd', 'Sigma_xd_half'}, Data.DataFunctionType.PER_EPISODE );
            
        end
        
       function [Phi_t] = getBasisMatrixLatent(obj, basis1D)
            r = obj.redDimension * obj.numTimeSteps;
            c = obj.numBasis * obj.redDimension;
            Phi_t = zeros (r,c);       
            for j = 1:obj.redDimension                
                idx_i = (j-1)*obj.numTimeSteps+1:j*obj.numTimeSteps;
                idx_j = (j-1)*obj.numBasis+1:j*obj.numBasis;                
                Phi_t( idx_i, idx_j  ) = basis1D;
            end
        end
        
        
        
        function [refState] = sampleFromDistribution(obj, numEl, vargin, context) %TODO
            %TODO proper demuxing THIS IS NOT TESTED, PROBABLY NOT WORKING
            basis1D   = vargin(:,1:obj.numBasis);
            basis1Dd  = vargin(:,(1:obj.numBasis)+obj.numBasis);
            
            basis   = obj.getBasisMatrixLatent(basis1D);
            basisd  = obj.getBasisMatrixLatent(basis1Dd);
            wVec = obj.distributionW.sampleFromDistribution(1);
            refState = [basis;basisd] *wVec';
            len = obj.numTimeSteps*obj.numJoints;
            refState = [ reshape(refState(1:len),[],obj.numJoints); ...
                reshape(refState((1:len)+len),[],obj.numJoints); ];
            %             figure;plot(refState(1:obj.numTimeSteps,:));
            %             figure;plot(refState((1:obj.numTimeSteps)+obj.numTimeSteps,:));
        end
        
        
        function [mean, sigma,mx,Sx] = getExpectationAndSigmaLatent(obj, basis, basisD, context)
            [mean, sigma,mx,Sx] = obj.getStateDistributionLatent(basis, basisD, context );
        end
        
        function getDataProbabilities(~, varargin)
            error('ProMPs: getDataProbabilities to implement');
        end
        
    end
    
    methods(Access=protected)
        
        function [] = registerMappingInterfaceDistribution(obj)
            obj.registerMappingInterfaceDistribution@Distributions.TrajectoryDistribution();
            obj.addDataManipulationFunction('getExpectationAndSigmaLatent', {'basis', 'basisD','context'}, ...
                {'referenceMean','referenceStd'});
        end
    end
    
    
    
    methods
        
        
        %% Returns the state distribution format[ pos vel ]!
        function [mu_t, Sigma_t, mu_x,Sigma_x] = getStateDistributionLatent(obj, basis, basisD, context )
            
            % adapted from the upper class ProMP
            Proj=obj.ProjectionMatrix;
            ProjN=kron(Proj,eye(2*obj.numTimeSteps));
            %[mu_x, Sigma_x] = getStateDistribution(obj, basis, basisD, context );
            w_mu = obj.distributionW.getExpectation( 1, context)';         
            w_cov = obj.distributionW.getCovariance;            
            Phi_t  = [ obj.getBasisMatrixLatent(basis); 
                       obj.getBasisMatrixLatent(basisD) ];
            %this would be the same: Phi_t=[kron(eye(obj.numJoints),basis);kron(eye(obj.numJoints),basisD)];
            mu_x = Phi_t * w_mu;            
            Sigma_x = Phi_t * w_cov * Phi_t';     
            mu_t=ProjN*mu_x;
            Sigma_t = ProjN*Sigma_x*ProjN';
        end
        
        
        function std_t=getStdDeviationTrajectory(obj,basis)
            std_t=[];
            Proj=obj.ProjectionMatrix;
            w_cov = obj.distributionW.getCovariance;
            r=obj.redDimension;
            for t=1:obj.numTimeSteps
                Phi_t=kron(eye(r),basis(t,:));
                std_t=[std_t;diag(Proj*Phi_t * w_cov * Phi_t'*Proj')'];
            end
        end
        function mean_t=getMeanTrajectory(obj,basis)
            mean_t=[];
            Proj=obj.ProjectionMatrix;
            w_mu = obj.distributionW.getExpectation( 1, [])';
            r=obj.redDimension;
            for t=1:obj.numTimeSteps
                Phi_t=kron(eye(r),basis(t,:));
                mean_t=[mean_t;Proj*Phi_t * w_mu];
            end
        end
        
        function [mu_td, Sigma_td_half,mu_xd,Sigma_xd_half] = getStateDistributionDLatent(obj, basis, basisD, basisDD, context)
            % adapted from the upper class ProMP
            Proj=obj.ProjectionMatrix;
            ProjN=kron(Proj,eye(2*obj.numTimeSteps));
            w_mu = obj.distributionW.getExpectation( 1, context)';
            w_cov = obj.distributionW.getCovariance;            
            Phi_t  = [ obj.getBasisMatrixLatent(basis);
                       obj.getBasisMatrixLatent(basisD) ];                  
            Phi_td = [ obj.getBasisMatrixLatent(basisD);
                       obj.getBasisMatrixLatent(basisDD) ]; 
            mu_xd = Phi_td * w_mu;    
            Sigma_xd_half = Phi_td * w_cov * Phi_t';    
            mu_td=ProjN*mu_xd;
            Sigma_td_half = ProjN*Sigma_xd_half*ProjN';
        end
        
        
        
    end
    
end

