



%% --------------------------------------------------------------------------------------
%% --------------------------------- DEPRECATED!!!
%% ----------------------------------------------------------------------------------------




clear variables;
close all;
Common.clearClasses;
sampler = Sampler.EpisodeWithStepsSampler();
dataManager = sampler.getEpisodeDataManager();
sampler.getStepSampler.setIsActiveSampler(Sampler.IsActiveStepSampler.IsActiveNumSteps(dataManager));
numJoints = 5;
environment = Environments.DynamicalSystems.LinearSystem(sampler, numJoints);
sampler.setTransitionFunction(environment);
settings = Common.Settings();
settings.setProperty('dt', 0.01);
settings.setProperty('numBasis', 20);
settings.setProperty('numTimeSteps', 100);
settings.setProperty('widthFactorBasis', 1);



% we create the DRProMP
trajectoryGenerator = TrajectoryGenerators.DRProMPs(dataManager, numJoints,numJoints-2,eye(numJoints,numJoints-2));
trajectoryGenerator.SystemNoise=eye(numJoints)*0.2;
distributionLearner = Learner.SupervisedLearner.LinearGaussianMLLearner(dataManager, trajectoryGenerator.distributionW);
distributionLearner.regularizationRegression = 1e-8;

sampler.addSamplerFunctionToPool('ParameterPolicy', 'generatePhaseD', trajectoryGenerator.phaseGenerator);
sampler.addSamplerFunctionToPool('ParameterPolicy', 'generatePhaseDD', trajectoryGenerator.phaseGenerator);
sampler.addSamplerFunctionToPool('ParameterPolicy', 'generateBasisD', trajectoryGenerator.basisGenerator);
sampler.addSamplerFunctionToPool('ParameterPolicy', 'generateBasisDD', trajectoryGenerator.basisGenerator);
% 
% sampler.addParameterPolicy(trajectoryGenerator.phaseGenerator,'generatePhaseD');
% sampler.addParameterPolicy(trajectoryGenerator.phaseGenerator,'generatePhaseDD');
% sampler.addParameterPolicy(trajectoryGenerator.basisGenerator,'generateBasisD');
% sampler.addParameterPolicy(trajectoryGenerator.basisGenerator,'generateBasisDD');
dataManager.finalizeDataManager();

%% we create the linear latent trajectory imitation learner
imitationLearner = TrajectoryGenerators.ImitationLearning.LinearLatentTrajectoryImitationLearner(dataManager, trajectoryGenerator, 'jointPositions');
%imitationLearner = TrajectoryGenerators.ImitationLearning.LinearTrajectoryImitationLearner(dataManager, trajectoryGenerator, 'jointPositions');
imitationLearnerDistribution = TrajectoryGenerators.ImitationLearning.ParameterDistributionImitationLearner                             (dataManager, imitationLearner, distributionLearner, trajectoryGenerator);
imitationLearnerDistribution.setAddInitialSigma(true);
trajectoryGenerator.initObject();


%% Generate Initial Trajectory.
%We generate 3 randomized variables and two more which are linear combinations of the first two
trData = dataManager.getDataObject([20 100]);
for i = 1:20
    t = 0.01:0.01:1;
    z = 0.3*randn(1);
    ImTraj = sin ( t*pi) * (1 + z);
    ImTraj = ImTraj .* exp(-t) + 0.02 * randn(size(t));
    ImTraj = ImTraj';
    ImTraj2 = cos ( t*pi/2) * (1 + z);
    ImTraj2 = ImTraj2 .* exp(-t) + 0.02 * randn(size(t));
    ImTraj2 = ImTraj2';
    ImTraj3 = 2*( t.^2/4-t/2) * (1 + z);
    ImTraj3 = ImTraj3 .* exp(-t) + 0.02 * randn(size(t));
    ImTraj3 = ImTraj3';
    ImTraj4=ImTraj3*0.2+ImTraj-0.5*ImTraj2;
    ImTraj5=ImTraj3-ImTraj;
    trData.setDataEntry('jointPositions', [ImTraj,ImTraj2,ImTraj3,ImTraj4,ImTraj5], i);
end
%sampler.setParallelSampling(true);
% we copy the raw data.
datacopy=trData;


%% DR-ProMP Learning
%initialize. There is a variable called "isDRProMPInitialized" that is
%initially set to 0, when the model is first updated, it fits the
%DR-ProMP from the data with a PCA and least squares approach, and sets
%isDRProMPInitialized=1
% we use the updatemodel function in the
% LinearLatentTrajectoryImitationLearner instead of the one in the upper
% class because it only computes the weights of a trajectory, and we want
% to actually compute all of them toghether. This might be changed to make
% it more consistent with other functionalities.
imitationLearnerDistribution.imitationLearnerTrajectory.updateModel(trData);
% USE ONLY imitationLearnerTrajectory.updateModel(trData);rename as imitationLearnerDistribution?
%% However, we need the old model for the expectation step, so we either
%pass the old promp model as an input or we leave it as it is now.


% TODO: still a couple of numerical optimizations, the most costly thing
% is the pseudoinverse of the "Gamma" matrix. other matlab opensource codes for
% the pinv function are more efficient.
% TODO: when the data is too large (many DoF, many timesteps, many basis),
% we shoud sub-sample and keep some of the timesteps, but not all
% TODO: Implement the controller for DR-ProMP, with added noise if we need it for
% learning
% TODO: The plotting functionalities in the DRProMP class need to be
% working with the standard ones

%% and now we plot results
mw=imitationLearnerDistribution.trajectoryGenerator.distributionW.getMean;
Sy=imitationLearnerDistribution.trajectoryGenerator.SystemNoise;
Om=imitationLearnerDistribution.trajectoryGenerator.ProjectionMatrix;
Sw=imitationLearnerDistribution.trajectoryGenerator.distributionW.getCovariance;
Nt=imitationLearnerDistribution.trajectoryGenerator.numTimeSteps;
d=trajectoryGenerator.numJoints;
dt=trajectoryGenerator.dt;
T=(0:dt:(Nt-1)*dt)';
r=imitationLearnerDistribution.trajectoryGenerator.redDimension;
basis=trData.getDataEntry('basis',1);
GGT=[];
for i=1:Nt
    GGT=[GGT;kron(eye(r),basis(i,:))];
end
Nk=trData.dataStructure.numElements;

md=zeros(Nt,d);
for i=1:Nt
        
        phit=GGT((i-1)*r+1:i*r,:);
        md(i,:)=(Om*phit*mw)';
        Si=Om*phit*Sw*phit'*Om';
        dup(i,:)=md(i,:)+sqrt(diag(Si))';
        ddwn(i,:)=md(i,:)-sqrt(diag(Si))';        
end  
for j=1:d      
    figure(j)
    title(strcat('joint ',int2str(j)))
    hold on
    plot(T(1:size(md,1)),md(:,j),'r','LineWidth',2)
    plot(T(1:size(dup,1)),dup(:,j),'r','LineWidth',1)
    plot(T(1:size(ddwn,1)),ddwn(:,j),'r','LineWidth',1)
    px=[T',fliplr(T')]; % make closed patch      
    py=[dup(:,j)', fliplr(ddwn(:,j)')];
    patch(px,py,1,'FaceColor','r','EdgeColor','none');
    alpha(.2); % make patch transparent
end
for i=1:Nk
    da=datacopy.getDataEntry('jointPositions',i);
   for j=1:d
      figure(j)
      hold on
      plot(T,da(:,j),'Color',[0.5 0.5 0.5]);

   end
end




