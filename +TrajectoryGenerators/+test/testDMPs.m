clear variables;
close all;
Common.clearClasses;


sampler = Sampler.EpisodeWithStepsSampler();

dataManager = sampler.getEpisodeDataManager();
dataManager.addDataEntry('contexts', 1, -1, 1);
sampler.getStepSampler.setIsActiveSampler(Sampler.IsActiveStepSampler.IsActiveNumSteps(dataManager));

%contextSampler = Sampler.InitialSampler.InitialContextSamplerStandard(sampler);
%initialStateSampler = Sampler.InitialSampler.InitialStateSamplerStandard(sampler);
%initialStateSampler.setInitStateFromContext(true);

numJoints = 3;
environment = Environments.DynamicalSystems.LinearSystem(sampler, numJoints);

%sampler.setContextSampler(contextSampler);
sampler.setTransitionFunction(environment);
%sampler.setInitialStateSampler(initialStateSampler);


numBasis = 5;

settings = Common.Settings();
settings.setProperty('useTau', 1);
settings.setProperty('useGoalPos', 1);
settings.setProperty('numBasis', numBasis);
settings.setProperty('useWeights', true);
settings.setProperty('numTimeSteps', 100);

phaseGenerator = TrajectoryGenerators.PhaseGenerators.DMPPhaseGenerator(dataManager);
basisGenerator = TrajectoryGenerators.BasisFunctions.DMPBasisGenerator(dataManager,phaseGenerator);

dmps = TrajectoryGenerators.DynamicMovementPrimitives(dataManager,numJoints);
sampler.addParameterPolicy(dmps,'getReferenceTrajectory');

controller = TrajectoryGenerators.TrajectoryTracker.LinearTrajectoryTracker(dataManager, numJoints);
sampler.setActionPolicy(controller);

dataManager.finalizeDataManager();
numSamples = 100;
newData = dataManager.getDataObject(numSamples);

taus = rand(newData.getNumElements('Tau'),1) * 0.4 + 0.8;
newData.setDataEntry('Tau', taus);

weights = randn(numSamples,numJoints * numBasis) * 12 + 0.8;
newData.setDataEntry('Weights', weights );

goal = randn(numSamples,numJoints) * 0.05;
newData.setDataEntry('GoalPos', goal );

sampler.numSamples = 100;
sampler.setParallelSampling(true);


%% First check the reference Trajectories of the DMPs
fprintf('Generating Data\n');
tic
sampler.createSamples(newData);
toc

figure;
plot(newData.getDataEntry3D('phase')');

figure;
plot(newData.getDataEntry('basis',1));

figure;
for i = 1:10
    plot(newData.getDataEntry('referencePos', i, :));
    hold all;
end
    
%% Now test the controlls

figure;
plot(newData.getDataEntry('jointPositions', 1, :));
hold all;
plot(newData.getDataEntry('referencePos', 1, :), '-.');

figure;
plot(newData.getDataEntry('actions', 1, :));

%Elapsed time is 2.659517 seconds.
%Elapsed time is 2.646153 seconds.
%Elapsed time is 2.646107 seconds.

