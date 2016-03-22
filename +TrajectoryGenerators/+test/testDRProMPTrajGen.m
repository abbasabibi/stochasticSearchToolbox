clear variables;
close all;
Common.clearClasses;

useDRpromp=1;


%% create sampler
sampler = Sampler.EpisodeWithStepsSampler();
dataManager = sampler.getEpisodeDataManager();
sampler.getStepSampler.setIsActiveSampler(Sampler.IsActiveStepSampler.IsActiveNumSteps(dataManager));

%% define robot and environment
numJoints = 4;
environment = Environments.DynamicalSystems.LinearSystem(sampler, numJoints);
aux= [17.5000   17.5000   26.2500    8.7500   8.7500];
environment.masses = aux(1:numJoints);

%%  Action bounds and environment init
dataManager.setRange('actions',-1e10*ones(1,numJoints),1e10*ones(1,numJoints));
dataManager.setRestrictToRange('actions', false);
environment.initObject();
sampler.setTransitionFunction(environment);

%% algorithmic parameters
numTimeSteps=200;
numBasis=50;
settings = Common.Settings();
settings.setProperty('dt', 0.001);
settings.setProperty('numBasis', numBasis);
settings.setProperty('numTimeSteps', numTimeSteps);
settings.setProperty('widthFactorBasis', 1);
settings.setProperty('Noise_std', 2);

%% generate trajectory
reducedDimension=numJoints;
if useDRpromp==1
    trajectoryGenerator = TrajectoryGenerators.DRProMPs(dataManager, numJoints,reducedDimension,eye(numJoints,reducedDimension));
else
    trajectoryGenerator = TrajectoryGenerators.ProMPs(dataManager, numJoints);
    
end
distributionLearner = Learner.SupervisedLearner.LinearGaussianMLLearner(dataManager, trajectoryGenerator.distributionW);
distributionLearner.regularizationRegression = 1e-8;

%% ProMP gain
if useDRpromp==1
    gainGenerator = TrajectoryGenerators.DRProMPsCtl(dataManager, trajectoryGenerator, environment);
else
    gainGenerator = TrajectoryGenerators.ProMPsCtl(dataManager, trajectoryGenerator, environment);
end

trajectoryGenerator.initObject();
sampler.addSamplerFunctionToPool('ParameterPolicy', 'generatePhaseD', trajectoryGenerator.phaseGenerator);
sampler.addSamplerFunctionToPool('ParameterPolicy', 'generatePhaseDD', trajectoryGenerator.phaseGenerator);
sampler.addSamplerFunctionToPool('ParameterPolicy', 'generateBasisD', trajectoryGenerator.basisGenerator);
sampler.addSamplerFunctionToPool('ParameterPolicy', 'generateBasisDD', trajectoryGenerator.basisGenerator);
ctrTraj = TrajectoryGenerators.TrajectoryTracker.TimeVarLinearController(dataManager, numJoints, gainGenerator);
sampler.setActionPolicy(ctrTraj);
%imitationLearner = TrajectoryGenerators.ImitationLearning.LinearTrajectoryImitationLearner(dataManager, trajectoryGenerator, 'jointPositions');

if useDRpromp==1
    imitationLearner = TrajectoryGenerators.ImitationLearning.LinearLatentTrajectoryImitationLearner(dataManager, trajectoryGenerator, 'jointPositions');
else
    imitationLearner = TrajectoryGenerators.ImitationLearning.LinearTrajectoryImitationLearner(dataManager, trajectoryGenerator, 'jointPositions');
    
end

imitationLearnerDistribution = TrajectoryGenerators.ImitationLearning.ParameterDistributionImitationLearner...
    (dataManager, imitationLearner, distributionLearner, trajectoryGenerator);
sampler.addSamplerFunctionToPool('ParameterPolicy','updateModel',gainGenerator);
%sampler.addParameterPolicy(gainGenerator,'updateModel');
dataManager.finalizeDataManager();

sampleData = dataManager.getDataObject(0);
loadDataFromFile=1;
if loadDataFromFile==1
    %% From file
    load('+TrajectoryGenerators/+test/promp_test_im.mat')
    nSamples = length(traj.newData);
    trLength = size(traj.newData{1},1);
    trData = dataManager.getDataObject([nSamples numTimeSteps]);
    figure;hold all;
    for i = 1:nSamples
   %     plot(traj.newData{i}(1:10:end,1));
        trData.setDataEntry('jointPositions', traj.newData{i}(1:trLength/numTimeSteps:end,1:2:end), i);
    end
else
    %% customly generated
    trData = dataManager.getDataObject([50 100]);
    for i = 1:50
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
        aux=[ImTraj,ImTraj2,ImTraj3,ImTraj4,ImTraj5];
        trData.setDataEntry('jointPositions',aux(:,1:numJoints) , i);
    end
end

startDistribution = Distributions.Gaussian.GaussianLinearInFeatures(dataManager, 'states', '', 'initStateDistribution');
meanInit = mean(trData.getDataEntry('states', :, 1));
covInit = cov(trData.getDataEntry('states', :, 1));
startDistribution.setBias(meanInit);
startDistribution.setCovariance(covInit + eye(8) *10^-8);

sampler.setInitialStateSampler(startDistribution, 'sampleFromDistribution');


sampler.setParallelSampling(true);
% we copy the raw data.
datacopy=trData;




sampler.numSamples = 100;
sampler.setParallelSampling(true);
if useDRpromp==1
    imitationLearnerDistribution.imitationLearnerTrajectory.EMiterations=50;
    imitationLearnerDistribution.imitationLearnerTrajectory.SubSamplingFactor=4;
    imitationLearnerDistribution.imitationLearnerTrajectory.trajectoryGenerator.ComputeLikelihood=0;
    %imitationLearnerDistribution.updateModel(trData);
    imitationLearnerDistribution.imitationLearnerTrajectory.updateModel(trData);
else
    imitationLearnerDistribution.updateModel(trData);
end


d=trajectoryGenerator.numJoints;
if useDRpromp==1
%% and now we plot results
mw=imitationLearnerDistribution.trajectoryGenerator.distributionW.getMean;
Sy=imitationLearnerDistribution.trajectoryGenerator.SystemNoise;
Om=imitationLearnerDistribution.trajectoryGenerator.ProjectionMatrix;
r=imitationLearnerDistribution.trajectoryGenerator.redDimension;

else
    mw=imitationLearnerDistribution.trajectoryGenerator.distributionW.getMean;
    Om=eye(d);
    Sy=zeros(d);
    r=d;
end


Sw=imitationLearnerDistribution.trajectoryGenerator.distributionW.getCovariance;
Nt=imitationLearnerDistribution.trajectoryGenerator.numTimeSteps;

dt=trajectoryGenerator.dt;
T=(0:dt:(Nt-1)*dt)';
basis=trData.getDataEntry('basis',1);
GGT=[];
for i=1:Nt
    GGT=[GGT;kron(eye(r),basis(i,:))];
end
Nk=trData.dataStructure.numElements;

md=zeros(Nt,d);
% for i=1:Nt
%         
%         phit=GGT((i-1)*r+1:i*r,:);
%         md(i,:)=(Om*phit*mw)';
%         Si=Om*phit*Sw*phit'*Om';
%         dup(i,:)=md(i,:)+2*sqrt(diag(Si))';
%         ddwn(i,:)=md(i,:)-2*sqrt(diag(Si))';        
% end  
% for j=1:d      
%     figure(j)
%     title(strcat('joint ',int2str(j)))
%     hold on
%     plot(T(1:size(md,1)),md(:,j),'r','LineWidth',2)
%     plot(T(1:size(dup,1)),dup(:,j),'r','LineWidth',1)
%     plot(T(1:size(ddwn,1)),ddwn(:,j),'r','LineWidth',1)
%     px=[T',fliplr(T')]; % make closed patch      
%     py=[dup(:,j)', fliplr(ddwn(:,j)')];
%     patch(px,py,1,'FaceColor','r','EdgeColor','none');
%     alpha(.2); % make patch transparent
% end
% for i=1:Nk
%     da=datacopy.getDataEntry('jointPositions',i);
%    for j=1:d
%       figure(j)
%       hold on
%       plot(T,da(:,j),'Color',[0.5 0.5 0.5]);
% 
%    end
% end




%% GENERATE NEW SAMPLES
sampler.createSamples(sampleData);

% trajectoryGenerator.plotStateDistribution(trData)

save test1.mat
[meanValues1, stdValues1, figureHandles] = Plotter.PlotterData.plotTrajectoriesMeanAndStd(trData,'jointPositions', 1:4, [], {'r'});
[meanValues2, stdValues2, figureHandles] = Plotter.PlotterData.plotTrajectoriesMeanAndStd(sampleData,'jointPositions', 1:4, figureHandles, {'b'});
close all
Pratio=size(meanValues2,1)/size(meanValues1,1);
for i=1:numJoints
    figure(i)
    Plotter.shadedErrorBar((1:size(meanValues1, 1))*Pratio, meanValues1(:, i), 2 * stdValues1(:, i),'r',0.5,false,false);
    hold on
    Plotter.shadedErrorBar(1:size(meanValues2, 1), meanValues2(:, i), 2 * stdValues2(:, i),'b',0.5,false,false);
end