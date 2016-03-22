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


numBasis = 5;

settings = Common.Settings();
settings.setProperty('useTau', 1);
settings.setProperty('numBasis', numBasis);
settings.setProperty('numTimeSteps', 100);
settings.setProperty('useWeights', 1);

phaseGenerator = TrajectoryGenerators.PhaseGenerators.DMPPhaseGenerator(dataManager);
basisGenerator = TrajectoryGenerators.BasisFunctions.DMPBasisGenerator(dataManager,phaseGenerator);

sampler.addParameterPolicy(phaseGenerator,'generatePhase');
sampler.addParameterPolicy(basisGenerator,'generateBasis');

numJoints = 3;
linTraj = TrajectoryGenerators.LinearTrajectoryGenerator(dataManager,numJoints);
sampler.addParameterPolicy(linTraj,'getReferenceTrajectory');

dataManager.finalizeDataManager();
newData = dataManager.getDataObject(10);

taus = rand(newData.getNumElements('Tau'),1) * 0.4 + 0.8;
newData.setDataEntry('Tau', taus);

weights = rand(10,numJoints * numBasis) * 12 + 0.8;
newData.setDataEntry('Weights', weights );


sampler.numSamples = 10;
sampler.setParallelSampling(false);


fprintf('Generating Data\n');
tic
sampler.createSamples(newData);
toc




