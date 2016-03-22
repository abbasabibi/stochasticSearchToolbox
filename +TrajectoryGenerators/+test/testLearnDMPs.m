clear variables;
close all;
Common.clearClasses;


sampler = Sampler.EpisodeWithStepsSampler();

dataManager = sampler.getEpisodeDataManager();
sampler.getStepSampler.setIsActiveSampler(Sampler.IsActiveStepSampler.IsActiveNumSteps(dataManager));


environment = Sampler.test.EnvironmentSequentialTest(dataManager, dataManager.getSubDataManager());

sampler.setContextSampler(environment);
sampler.setActionPolicy(environment);
sampler.setTransitionFunction(environment);
sampler.setRewardFunction(environment);
sampler.setInitialStateSampler(environment);


numBasis = 25;

settings = Common.Settings();
settings.setProperty('useTau', true);
settings.setProperty('numBasis', numBasis);
settings.setProperty('useWeights', false);
settings.setProperty('numTimeSteps', 400);

t = 0.01:0.01:4;
ImTraj = sin ( t*pi);
ImTraj = ImTraj .* exp(-t);
ImTraj = ImTraj';

trajectoryGenerator = TrajectoryGenerators.DynamicMovementPrimitives(dataManager, 3);

numJoints = 3;

dataManager.finalizeDataManager();

dataManager.addDataEntry('steps.jointPositions', numJoints);

trData = dataManager.getDataObject([1 length(ImTraj)]); %FIXME on the states

trData.setDataEntry('jointPositions', [ImTraj,ImTraj,ImTraj]);

taus = rand(trData.getNumElements('Tau'),1) * 0.4 + 0.8;
trData.setDataEntry('Tau', taus);

sampler.numSamples = 1;
sampler.setParallelSampling(true);
sampler.createSamples(trData);

imitationLearner = TrajectoryGenerators.ImitationLearning.DMPsImitationLearner(dataManager, trajectoryGenerator, 'jointPositions');
imitationLearner.updateModel(trData);

referenceTrajectory = trajectoryGenerator.callDataFunctionOutput('getReferenceTrajectory', trData, 1);

figure;
plot(referenceTrajectory);
hold all;
plot(trData.getDataEntry('jointPositions'), '--');
