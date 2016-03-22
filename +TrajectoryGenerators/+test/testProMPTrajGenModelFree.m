clear variables;
close all;
Common.clearClasses;

settings = Common.Settings();
settings.setProperty('dt', 0.001);
settings.setProperty('numBasis', 55);
settings.setProperty('numTimeSteps', 1000);
settings.setProperty('widthFactorBasis', 1.4);
settings.setProperty('Noise_std', 2);


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

trajectoryGenerator = TrajectoryGenerators.ProMPs(dataManager, numJoints);
distributionLearner = Learner.SupervisedLearner.LinearGaussianMLLearner(dataManager, trajectoryGenerator.distributionW);
distributionLearner.regularizationRegression = 1e-12; 

gainGenerator = TrajectoryGenerators.ProMPsCtl(dataManager, trajectoryGenerator, environment);

trajectoryGenerator.initObject();

sampler.addParameterPolicy(trajectoryGenerator.phaseGenerator,'generatePhaseD');
sampler.addParameterPolicy(trajectoryGenerator.phaseGenerator,'generatePhaseDD');
sampler.addParameterPolicy(trajectoryGenerator.basisGenerator,'generateBasisD');
sampler.addParameterPolicy(trajectoryGenerator.basisGenerator,'generateBasisDD');

ctrTraj = TrajectoryGenerators.TrajectoryTracker.TimeVarLinearController(dataManager, numJoints, gainGenerator);

sampler.setActionPolicy(ctrTraj);

imitationLearner = TrajectoryGenerators.ImitationLearning.LinearTrajectoryImitationLearner(dataManager, trajectoryGenerator, 'jointPositions');
imitationLearnerDistribution = TrajectoryGenerators.ImitationLearning.ParameterDistributionImitationLearner...
                             (dataManager, imitationLearner, distributionLearner, trajectoryGenerator);
                         
sampler.addParameterPolicy(gainGenerator,'updateModel');

trajectoryGenerator.addDataManipulationFunction('getExpectationAndSigma', {'basis', 'basisD','context'}, ...
                                              {'referenceMean','referenceStd'});
sampler.setInitialStateSampler(trajectoryGenerator);

dataManager.finalizeDataManager();

%%% From file
load('+TrajectoryGenerators/+test/promp_test_im.mat')
nSamples = length(traj.newData);
trLength = size(traj.newData{1},1);

trData = dataManager.getDataObject([nSamples trLength]);
sampleData = dataManager.getDataObject(0);


figure;hold all;
for i = 1:nSamples
    plot(traj.newData{i}(:,1));
    trData.setDataEntry('jointPositions', traj.newData{i}(:,1:2:end), i);
end

sampler.numSamples = 174;
sampler.setParallelSampling(true);

imitationLearnerDistribution.updateModel(trData);

tic
sampler.createSamples(sampleData);
toc

% trajectoryGenerator.plotStateDistribution(trData)


[meanValues, stdValues, figureHandles] = Plotter.PlotterData.plotTrajectoriesMeanAndStd(trData,'jointPositions', 1:4, [], {'r'});
[meanValues, stdValues, figureHandles] = Plotter.PlotterData.plotTrajectoriesMeanAndStd(sampleData,'jointPositions', 1:4, figureHandles, {'b'});

