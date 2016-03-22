classdef LinearLatentTrajectoryImitationLearner < Learner.Learner
    % LinearLatentTrajectoryDistriutionLearner
    
    properties(AbortSet, SetObservable)
        imitationLearningRegularization = 10^-6;
        useWeights;
    end
    
    properties
        trajectoryGenerator
        phaseGenerator
        setFixedParameters
        trajectoryName
        EMiterations
        ComputeLikelihood
        SubSamplingFactor
    end
    
    methods
        
        function obj = LinearLatentTrajectoryImitationLearner(dataManager, trajectoryGenerator, trajectoryName, setFixedParameters)
            obj = obj@Learner.Learner();
            obj.linkProperty('imitationLearningRegularization');
            obj.linkProperty('useWeights');           
            obj.trajectoryGenerator = trajectoryGenerator;
            obj.phaseGenerator = trajectoryGenerator.phaseGenerator;            
            if (exist('trajectoryName', 'var'))
                obj.trajectoryName = trajectoryName;
            else
                obj.trajectoryName = 'jointPositions';
            end           
            if (~exist('setFixedParameters', 'var'))
                setFixedParameters = true;
            end
            obj.setFixedParameters = setFixedParameters;
            obj.EMiterations=10;
            obj.ComputeLikelihood=1;
            obj.SubSamplingFactor=4;
        end
        
        function [basisMDOF] = getBasisFunctionsMultiDOF(obj, basis)
            redDimension = obj.trajectoryGenerator.redDimension;
            basisMDOF = zeros(size(basis) * redDimension);            
            for i = 1:redDimension
                basisMDOF((1:size(basis,1)) + (i-1) * size(basis,1), (1:size(basis,2)) + (i-1) * size(basis,2)) = basis;
            end
        end
        
        function [targetFunction] = getTargetFunctionForImitation(obj, q, qd, qdd)
            %  Proj=obj.trajectoryGenerator.ProjectionMatrix;
            %       targetFunction = pinv(ProjectionMatrix)*q(:);
            targetFunction = q(:);
        end
        
        function [] = setMetaParametersFromTrajectory(obj, q, qd, qdd)
            obj.phaseGenerator.setMetaParametersFromTrajectory(q); %timesteps and endtime
        end
        
        function [Yd, Ydd] = getDiffVelocitiesAndAccelerations(obj, Y)
            Yd  = (Y(2:end,:) - Y(1:end-1,:)) / obj.trajectoryGenerator.dt;
            Yd = ([Yd; Yd(end,:) ]);          
            Ydd = (Yd(2:end,:) - Yd(1:end-1,:)) / obj.trajectoryGenerator.dt;
            Ydd = ([Ydd; Ydd(end,:) ]);
        end
        
        
        function Yk=getYk(obj,data,k)
            [numTimesteps,d]=size(data.getDataEntry('jointPositions',1));
            dataSubsample=numTimesteps/obj.trajectoryGenerator.numTimeSteps;
            numTimesteps=numTimesteps/dataSubsample/obj.SubSamplingFactor;
            Yk=zeros(numTimesteps*d,1);
            Yaux=data.getDataEntry('jointPositions',k); 
            Yaux=Yaux(1:obj.SubSamplingFactor:end,:);
            for i=1:numTimesteps
                Yk((i-1)*d+1:i*d,1)= Yaux((i-1)*dataSubsample+1,:)';
            end
      %      TrainingData(:,k)=Yk;
        end
        
        
        function [WK,Sk,TrainingData]=ExpectationStepProMP(obj,data)
            basis = data.getDataEntry('basis',1);
            Ndemos=data.dataStructure.numElements;
            %njoints=obj.trajectoryGenerator.numJoints;
            ntimesteps=obj.trajectoryGenerator.numTimeSteps/obj.SubSamplingFactor;
            %basisMDOF = obj.getBasisFunctionsMultiDOF(basis);
            r=obj.trajectoryGenerator.redDimension;
            Nf=obj.trajectoryGenerator.numBasis;
            TrainingData=zeros(obj.trajectoryGenerator.numTimeSteps/obj.SubSamplingFactor*obj.trajectoryGenerator.numJoints,Ndemos);

            basisMDOF=zeros(r*ntimesteps,r*Nf);
            for i=1:ntimesteps
                basisMDOF((i-1)*r+1:i*r,:)=kron(eye(r),basis((i-1)*obj.SubSamplingFactor+1,:));
            end
            SY=kron(eye(ntimesteps),obj.trajectoryGenerator.SystemNoise);
            Om=obj.trajectoryGenerator.ProjectionMatrix;
            OmN=kron(eye(ntimesteps),Om);
            mw=obj.trajectoryGenerator.distributionW.getMean;
            Sw=obj.trajectoryGenerator.distributionW.getCovariance;
            Gamma=SY+OmN*basisMDOF*Sw*basisMDOF'*OmN';
            GammaInverse=pinv(Gamma);
            CC=OmN*basisMDOF*Sw;
            ZZ=OmN*basisMDOF;
            Smk=Sw-CC'*GammaInverse*CC;
            Sk=(Smk+Smk')/2;
            dataindexes=[];
%             for i=1:ntimesteps            
%                 dataindexes=[dataindexes (i-1)*obj.trajectoryGenerator.numJoints*obj.SubSamplingFactor+1:(i-1)*obj.trajectoryGenerator.numJoints*obj.SubSamplingFactor+obj.trajectoryGenerator.numJoints];
%             end
            for k=1:Ndemos
                TrainingData(:,k)=getYk(obj,data,k); %this also stores the Yk in the ProMP data
% <<<<<<< Updated upstream
%                 wmeank=mw+ CCGammaInverse*TrainingData(dataindexes,k)-CC'* ZZ*mw;
% =======
                wmeank=mw+CC'*GammaInverse*(TrainingData(:,k)-ZZ*mw);
% >>>>>>> Stashed changes
                WK(:,k)=wmeank;
            end
%             CC=OmN*basisMDOF*Sw;
%             ZZ=OmN*basisMDOF;
%             CCGammaInverse= CC' / Gamma;
%             Smk=Sw - CCGammaInverse * CC;
%             Sk=(Smk+Smk')/2;
%             for k=1:Ndemos
%                % Ykaux=getYk(obj,data,k);
%                 TrainingData(:,k)=getYk(obj,data,k); %this also stores the Yk in the ProMP data
%                 wmeank=mw+ CCGammaInverse*TrainingData(:,k)-CC'* ZZ*mw;
%                 WK(:,k)=wmeank;
%             end
        end
        
        function [Om_new,mw_new,Sw_new,Sy_new]=MaximizationStepProMP(obj,data,WK,Sk,pk,basis,TrainingData)
            % pk is a column matrix with weights, normalized to 1!!
            pk=pk/(sum(pk)+1e-10); %just in case
            Ndemos=data.dataStructure.numElements;
            njoints=obj.trajectoryGenerator.numJoints;
            rjoints=obj.trajectoryGenerator.redDimension;
            ntimesteps=obj.trajectoryGenerator.numTimeSteps/obj.SubSamplingFactor;
            nbasis=obj.trajectoryGenerator.numBasis;
            %% new weights
            mw_new=zeros(rjoints*nbasis,1);
            for k=1:Ndemos
                mw_new=mw_new+pk(k,1)*WK(:,k);
            end
            %% new covariance
            Sw_new=Sk+eye(size(Sk))*1e-10;
            SKM=zeros(rjoints*nbasis); %auxiliar matrix
            for k=1:Ndemos
                mk=WK(:,k);
                Sw_new=Sw_new+pk(k,1)*(mk-mw_new)*(mk-mw_new)';
                SKM=SKM+(Sk+mk*mk')*pk(k,1);
            end
            %% new Projection matrix
            if njoints==rjoints
                Om_new=eye(njoints);
            else
                S1=zeros(rjoints,rjoints);
                S2=zeros(njoints,rjoints);
                for i=1:ntimesteps
                    phit=kron(eye(rjoints),basis((i-1)*obj.SubSamplingFactor+1,:));
                    S1=S1+phit*SKM*phit';
                    for k=1:Ndemos
                        ytk=TrainingData((i-1)*obj.trajectoryGenerator.numJoints+1:(i-1)*obj.trajectoryGenerator.numJoints+obj.trajectoryGenerator.numJoints,k);
                        S2=S2+pk(k,1)*ytk*(WK(:,k)'*phit');
                    end
                    
                end
                Om_new=S2*pinv(S1);
            end
            %% System noise
            S4=zeros(njoints,njoints);
            S5=zeros(njoints,njoints);
            S6=zeros(njoints,njoints);
            for i=1:ntimesteps
                phit=kron(eye(rjoints),basis(i,:));
                for k=1:Ndemos
                        ytk=TrainingData((i-1)*obj.trajectoryGenerator.numJoints+1:(i-1)*obj.trajectoryGenerator.numJoints+obj.trajectoryGenerator.numJoints,k);
                    Om_phi_mu=Om_new*phit*WK(:,k);
                    S4=S4+pk(k,1)*ytk*(ytk-Om_phi_mu)';
                    S5=S5+pk(k,1)*Om_phi_mu*(Om_phi_mu-ytk)';
                    
                end
                S6=S6+sum(pk)*Om_new*phit*Sk*phit'*Om_new';
            end
            Sy_new=(S4+S5+S6)/sum(pk)/ntimesteps;
            % we regularize in case a small numerical error prevents it
            % from being positive definite.
            Sy_new=real((Sy_new+Sy_new')/2)+eye(njoints)*1e-10;
            Sw_new=real((Sw_new+Sw_new')/2)+eye(size(Sw_new))*1e-6;
            %% Assign final values
            obj.trajectoryGenerator.ProjectionMatrix=Om_new;
            obj.trajectoryGenerator.SystemNoise=Sy_new;
            obj.trajectoryGenerator.distributionW.setBias(mw_new)
            %obj.trajectoryGenerator.Weights=mw_new; %take out, use the ones on the distributionW.bias
            % weights are usually used only to simple trajectory
            obj.trajectoryGenerator.distributionW.setCovariance(Sw_new+eye(size(Sw_new))*1e-4);
            %            obj.trajectoryGenerator.distributionW.setBias(mw_new);
            
            
        end
        
        
        
        
        function  []=InitializeDRProMPfromData(obj,data,basis)
            %% initialize variables
            Ndemos=data.dataStructure.numElements;
            r=obj.trajectoryGenerator.redDimension;
            Nt=obj.trajectoryGenerator.numTimeSteps;
            Nf=obj.trajectoryGenerator.numBasis;
            d=obj.trajectoryGenerator.numJoints;
            Sy=zeros(d);
            Y0aux=data.getDataEntry('jointPositions',1);
            dataRatio=size(Y0aux,1)/obj.trajectoryGenerator.numTimeSteps;
            %% perform PCA to get Om
            if r==d
                Om=eye(d);
            else
                Yall=[];
                for k=1:Ndemos
                    Yaux=data.getDataEntry('jointPositions',k);
                    Yall=[Yall;Yaux(1:dataRatio:end,:)];
                end
                [U,S,V]=svd(Yall-ones(size(Yall,1),1)*mean(Yall));
                Om=V(:,1:r);
                clear U S V Yall;
            end
            %% initialize mw
            %store weights of demos here
            WK=zeros(obj.trajectoryGenerator.numBasis*r,Ndemos);
            % get basis functions in proper shape
            Phi_t=zeros(r*Nt,r*Nf);
            for i=1:Nt
                Phi_t((i-1)*r+1:i*r,:)=kron(eye(r),basis(i,:));
            end
            %compute pseudoinverse
            Phi_t_inverse=(Phi_t' * Phi_t + obj.imitationLearningRegularization * eye(size(Phi_t,2))) \ Phi_t';
            for k=1:Ndemos
                %get trajectory in full space
                
                Yaux=data.getDataEntry('jointPositions',k);
                Yk=Yaux(1:dataRatio:end,:);                             
                Sy=Sy+cov(Yk)/Ndemos;
                %get trajectory in latent space
                Xk=Yk*pinv(Om)';
                Xkcolumn=reshape(Xk',[r*Nt,1]);
                %get weights
                WK(:,k)=Phi_t_inverse*Xkcolumn;
            end
            mw=mean(WK')';
            %initialize Sw
            Sw=eye(r*Nf)*10e-10;
            WK2=WK-mean(WK')'*ones(1,Ndemos);
            for k=1:Ndemos
                Sw=Sw+WK2(:,k)*WK2(:,k)'/Ndemos;
            end
            %% Store everything
            obj.trajectoryGenerator.ProjectionMatrix=Om;
            obj.trajectoryGenerator.SystemNoise=Sy;
            obj.trajectoryGenerator.distributionW.setCovariance(Sw);
            %obj.trajectoryGenerator.Weights = mw;
            obj.trajectoryGenerator.distributionW.setBias(mw);
            obj.trajectoryGenerator.isDRProMPInitialized=1;
        end
        
        
        function L = LogLikelihoodDRProMP(obj,data,basis,pk,WK,Sk)
            %we need priors Wk
            pk=pk/(sum(pk)+1e-10); %just in case
            Ndemos=data.dataStructure.numElements;
            r=obj.trajectoryGenerator.redDimension;
            Nt=obj.trajectoryGenerator.numTimeSteps;
            Nf=obj.trajectoryGenerator.numBasis;
            d=obj.trajectoryGenerator.numJoints;
            cholSw=obj.trajectoryGenerator.distributionW.cholA;
            Sw=cholSw*cholSw';
            mw=obj.trajectoryGenerator.distributionW.bias;
            Sy=obj.trajectoryGenerator.SystemNoise;
            Om=obj.trajectoryGenerator.ProjectionMatrix;
            L=-1/2*(log(2*pi)+sum(log(eig(Sw)))+Nt*log(2*pi*det(Sy)))*sum(pk);
            Swi=pinv(Sw);
            Syi=pinv(Sy);
            for k=1:Ndemos
                mk=WK(:,k);
                Yk=data.getDataEntry('jointPositions',k);
                L=L-0.5*(trace(Swi*Sk)+(mk-mw)'*Swi*(mk-mw))*pk(k,1);
                for i=1:Nt
                    ytk=Yk(i,:)';
                    phit=kron(eye(r),basis(i,:));
                    L=L-0.5*(ytk-Om*phit*mk)'*Syi*(ytk-Om*phit*mk)*pk(k,1);
                end
            end
            
        end
        
        
        function [] = learnTrajectory(obj, data)
            %% if the promp hasnt been initialized, we fit the parameters from the demonstration.
            targetTrajectory = data.getDataEntry(obj.trajectoryName, 1);
            dataRatio=floor(size(targetTrajectory,1)/obj.trajectoryGenerator.numTimeSteps);
            [targetTrajectoryD, targetTrajectoryDD] =  obj.getDiffVelocitiesAndAccelerations(targetTrajectory(1:dataRatio:end,:));
            obj.setMetaParametersFromTrajectory(targetTrajectory(1:dataRatio:end,:), targetTrajectoryD, targetTrajectoryDD);
            basis = data.getDataEntry('basis', 1);
            % if its still not initialized, we can initialize it with PCA
            % and so
            if obj.trajectoryGenerator.isDRProMPInitialized==0
                InitializeDRProMPfromData(obj,data,basis);
                obj.trajectoryGenerator.ProjectionMatrix
                
            end            
            % if we already have initial values, we do EM.
% <<<<<<< Updated upstream
            
% =======
% >>>>>>> Stashed changes
            if obj.trajectoryGenerator.redDimension<obj.trajectoryGenerator.numJoints
                for iterations=1:obj.EMiterations
                    %iterations
                    Ndemos=data.dataStructure.numElements;
                    pk=ones(Ndemos,1)/Ndemos;
                    [WK,Sk,TrainingData]=ExpectationStepProMP(obj,data);
                    [Om_new,mw_new,Sw_new,Sy_new]=MaximizationStepProMP(obj,data,WK,Sk,pk,basis,TrainingData);
                    %compute likelihood?
                    if obj.trajectoryGenerator.ComputeLikelihood==1
                        Likelihood = LogLikelihoodDRProMP(obj,data,basis,pk,WK,Sk)
                    end
                end
            end
        end
        
        function obj = updateModel(obj, data)
            obj.learnTrajectory(data);
        end
    end
    
end