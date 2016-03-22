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


 

settings = Common.Settings();
settings.setProperty('useTau', 1);
settings.setProperty('numBasis', 5);
settings.setProperty('numTimeSteps', 100);

phaseGenerator = TrajectoryGenerators.PhaseGenerators.DMPPhaseGenerator(dataManager);
basisGenerator = TrajectoryGenerators.BasisFunctions.DMPBasisGenerator(dataManager,phaseGenerator);

sampler.addParameterPolicy(phaseGenerator,'generatePhase');
sampler.addParameterPolicy(basisGenerator,'generateBasis');

dataManager.finalizeDataManager();
newData = dataManager.getDataObject(10);

taus = rand(newData.getNumElements('Tau'),1) * 0.4 + 0.8;
newData.setDataEntry('Tau', taus);

sampler.numSamples = 10;
sampler.setParallelSampling(true);


fprintf('Generating Data\n');
tic
sampler.createSamples(newData);
toc




