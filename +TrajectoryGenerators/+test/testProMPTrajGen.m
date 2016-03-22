clear variables;
close all;
Common.clearClasses;


sampler = Sampler.EpisodeWithStepsSampler();

dataManager = sampler.getEpisodeDataManager();
sampler.getStepSampler.setIsActiveSampler(Sampler.IsActiveStepSampler.IsActiveNumSteps(dataManager));

numJoints = 4;
environment = Environments.DynamicalSystems.LinearSystem(sampler, numJoints);
environment.masses = [17.5000   17.5000   26.2500    8.7500];

dataManager.setRange('actions',-1e10*ones(1,numJoints),1e10*ones(1,numJoints));
dataManager.setRestrictToRange('actions', false);
environment.initObject();

sampler.setTransitionFunction(environment);

settings = Common.Settings();

dt = 0.01;
Ts = 1;
numTimeSteps = Ts / dt;

settings.setProperty('dt', dt);
settings.setProperty('numBasis', 100);
settings.setProperty('numTimeSteps', numTimeSteps);
settings.setProperty('widthFactorBasis', 1);
settings.setProperty('Noise_std', 2);


trajectoryGenerator = TrajectoryGenerators.ProMPs(dataManager, numJoints);
distributionLearner = Learner.SupervisedLearner.LinearGaussianMLLearner(dataManager, trajectoryGenerator.distributionW);
distributionLearner.regularizationRegression = 1e-8; 

% ProMP gain
gainGenerator = TrajectoryGenerators.ProMPsCtl(dataManager, trajectoryGenerator, environment);
trajectoryGenerator.initObject();

sampler.addSamplerFunctionToPool('ParameterPolicy', 'generatePhaseD', trajectoryGenerator.phaseGenerator);
sampler.addSamplerFunctionToPool('ParameterPolicy', 'generatePhaseDD', trajectoryGenerator.phaseGenerator);
sampler.addSamplerFunctionToPool('ParameterPolicy', 'generateBasisD', trajectoryGenerator.basisGenerator);
sampler.addSamplerFunctionToPool('ParameterPolicy', 'generateBasisDD', trajectoryGenerator.basisGenerator);

ctrTraj = TrajectoryGenerators.TrajectoryTracker.TimeVarLinearController(dataManager, numJoints, gainGenerator);
sampler.setActionPolicy(ctrTraj);

imitationLearner = TrajectoryGenerators.ImitationLearning.LinearTrajectoryImitationLearner(dataManager, trajectoryGenerator, 'jointPositions');
imitationLearnerDistribution = TrajectoryGenerators.ImitationLearning.ParameterDistributionImitationLearner...
                             (dataManager, imitationLearner, distributionLearner, trajectoryGenerator);
                         
sampler.addSamplerFunctionToPool('ParameterPolicy','updateModel',gainGenerator);

dataManager.finalizeDataManager();

%%% From file
load('+TrajectoryGenerators/+test/promp_test_im.mat')

nSamples = length(traj.newData);
trLength = size(traj.newData{1},1);

%nSamples = 30;
%trLength = 1000;

trData = dataManager.getDataObject([nSamples numTimeSteps]);
sampleData = dataManager.getDataObject(0);

t = 1:trLength;
figure;hold all;

leaveOut = size(traj.newData{1}, 1) / numTimeSteps;

for i = 1:nSamples
    z = randn(2,1);
    
    %jointPositions = [cos(t / trLength * 2 *pi  + 0.5) * z(1),   ]
    trData.setDataEntry('jointPositions', traj.newData{i}(1:leaveOut:end,1:2:end), i);
    trData.setDataEntry('jointVelocities', traj.newData{i}(1:leaveOut:end,2:2:end), i);

end

startDistribution = Distributions.Gaussian.GaussianLinearInFeatures(dataManager, 'states', '', 'initStateDistribution');
meanInit = mean(trData.getDataEntry('states', :, 1));
covInit = cov(trData.getDataEntry('states', :, 1));
startDistribution.setBias(meanInit);
startDistribution.setCovariance(covInit + eye(8) *10^-8);

sampler.setInitialStateSampler(startDistribution, 'sampleFromDistribution');


sampler.numSamples = 100;
sampler.setParallelSampling(true);

imitationLearnerDistribution.updateModel(trData);

tic
sampler.createSamples(sampleData);
toc

% trajectoryGenerator.plotStateDistribution(trData)


[meanValues, stdValues, figureHandles] = Plotter.PlotterData.plotTrajectoriesMeanAndStd(trData,'jointPositions', 1:4, [], {'r'});
[meanValues, stdValues, figureHandles] = Plotter.PlotterData.plotTrajectoriesMeanAndStd(sampleData,'jointPositions', 1:4, figureHandles, {'b'});

