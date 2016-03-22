clear variables;
close all;

settings = Common.IASParameters();


sampler = Sampler.EpisodeWithStepsSampler(settings);

dataManager = sampler.getEpisodeDataManager();
environment = Sampler.test.EnvironmentSequentialTest(dataManager, dataManager.getSubDataManager());
rewardFunction = RewardFunctions.test.TimeDependentRewardTest(settings, sampler);
returnFunction = RewardFunctions.ReturnForEpisode.ReturnSummedReward(settings, sampler); 

sampler.setContextSampler(environment);
sampler.setActionPolicy(environment);
sampler.setTransitionFunction(environment);
sampler.setRewardFunction(rewardFunction);
sampler.setReturnFunction(returnFunction);
sampler.setInitialStateSampler(environment);



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