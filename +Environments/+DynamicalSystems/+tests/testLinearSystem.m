clear variables;
close all;

sampler = Sampler.EpisodeWithStepsSampler();

dataManager = sampler.getEpisodeDataManager();
dataManager.addDataEntry('contexts', 1, -1, 1);

stepSampler = sampler.getStepSampler();
environment = Environments.DynamicalSystems.LinearSystem(sampler, 1);

contextSampler = Sampler.InitialSampler.InitialContextSamplerStandard( sampler);
initialStateSampler = Sampler.InitialSampler.InitialStateSamplerStandard(sampler);
initialStateSampler.setInitStateFromContext(true);
rewardFunction = Environments.DynamicalSystems.tests.TestRewardFunction(dataManager);
returnFunction = RewardFunctions.ReturnForEpisode.ReturnSummedReward( sampler);

sampler.setTransitionFunction(environment);
sampler.setContextSampler(contextSampler);
sampler.setInitialStateSampler(initialStateSampler);
sampler.setRewardFunction(rewardFunction);
sampler.setReturnFunction(returnFunction);

environment.initObject();

dataManager.finalizeDataManager();
newData = dataManager.getDataObject(10);
newData2 = dataManager.getDataObject(0);


sampler.numSamples = 1000;
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