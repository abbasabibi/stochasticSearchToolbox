clear variables;
close all;

sampler = Sampler.EpisodeWithStepsSampler();


dataManager = sampler.getEpisodeDataManager();

isActive = Sampler.IsActiveStepSampler.IsActiveFixedGamma(dataManager);
isActive.resetProb= 0.02;

sampler.getStepSampler.setIsActiveSampler(isActive)

environment = Sampler.test.EnvironmentSequentialTest(dataManager, dataManager.getSubDataManager());

sampler.setContextSampler(environment);
sampler.setActionPolicy(environment);
sampler.setTransitionFunction(environment);
sampler.setRewardFunction(environment);
sampler.setInitialStateSampler(environment);



dataManager.finalizeDataManager();
newData = dataManager.getDataObject(10);
newData2 = dataManager.getDataObject(0);


sampler.numSamples = 10;
sampler.setParallelSampling(true);
fprintf('Generating Data\n');
tic
sampler.createSamples(newData);
toc

fprintf('Merging Data\n');
tic
newData2.mergeData(newData);
toc   

fprintf('Generating Data 2nd time\n');
tic
sampler.createSamples(newData);
toc

fprintf('Merging Data\n');
tic
newData2.mergeData(newData);
toc