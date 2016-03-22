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
settings.setProperty('useTau', 1);
settings.setProperty('numBasis', numBasis);
settings.setProperty('useWeights', false);
settings.setProperty('numTimeSteps', 400);

t = 0.01:0.01:4;
ImTraj = sin ( t*2*pi)+ 0.2*sin ( t*4*pi);
ImTraj = cumsum(abs(ImTraj))/max(cumsum(abs(ImTraj)))+ImTraj;
ImTraj = ImTraj';

trajectoryGenerator = TrajectoryGenerators.LinearTrajectoryGenerator(dataManager, 3);

% 
% 
% sampler.addParameterPolicy(basisGenerator,'generateBasis');
% 
numJoints = 3;
% dmps = TrajectoryGenerators.DynamicMovementPrimitives(dataManager,numJoints);
% sampler.addParameterPolicy(dmps,'getReferenceTrajectory');


dataManager.finalizeDataManager();

dataManager.addDataEntry('steps.ImTraj', numJoints);


trData = dataManager.getDataObject([1 length(ImTraj)]); %FIXME on the states
trData.setDataEntry('ImTraj', [ImTraj, ImTraj * 2, ImTraj * 3]);


imitationLearner = TrajectoryGenerators.ImitationLearning.LinearTrajectoryImitationLearner(dataManager, trajectoryGenerator, 'ImTraj');
imitationLearner.updateModel(trData);

referenceTrajectory = trajectoryGenerator.callDataFunctionOutput('getReferenceTrajectory', trData, 1);

figure;
plot(referenceTrajectory(:,1));
hold all;
plot(ImTraj);