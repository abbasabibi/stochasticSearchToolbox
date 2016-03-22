clear variables;
close all;

%settings = Common.IASParameters();

sampler = Sampler.EpisodeSampler(settings);

rewardCenter = randn(1, 7);
rewardDistance = randn(7, 7);
rewardDistance = rewardDistance' * rewardDistance;

environment = Environments.BanditEnvironments.SquaredReward(settings, sampler, 2, 5, rewardCenter, rewardDistance);

%Note: The policy is still a hack, as they were not implemented yet
policy = Sampler.test.EnvironmentTest(sampler.getDataManagerForSampler());

sampler.setContextSampler(environment);
sampler.setParameterPolicy(policy);
sampler.setReturnFunction(environment);

dataManager = sampler.getEpisodeDataManager();
dataManager.finalizeDataManager();
newData = dataManager.getDataObject(10);
newData2 = dataManager.getDataObject(0);


sampler.numSamples = 100;
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