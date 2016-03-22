clear variables;
close all;

settings = Common.Settings.createNewSettings();

settings.setProperty('Noise_std', 1.0);
settings.setProperty('InitialContextDistributionWidth', 1.0);
settings.setProperty('InitialContextDistributionType', 'Uniform');


sampler = Sampler.EpisodeWithStepsSampler();

dataManager = sampler.getEpisodeDataManager();
dataManager.addDataEntry('contexts', 8, -[pi, 0, pi * 0.2, 0, pi * 0.2, 0, pi* 0.2, 0], [pi, 0, pi * 0.2, 0, pi * 0.2, 0, pi * 0.2, 0]);
stepSampler = sampler.getStepSampler();
environment = Environments.DynamicalSystems.QuadLink(sampler);
%environment.enableTransitionProbabilities(true);

contextSampler = Sampler.InitialSampler.InitialContextSamplerStandard(sampler);
rewardFunction = Environments.DynamicalSystems.tests.TestRewardFunction(dataManager);
returnFunction = RewardFunctions.ReturnForEpisode.ReturnSummedReward(dataManager);

sampler.setTransitionFunction(environment);
sampler.setContextSampler(contextSampler);
sampler.setInitialStateSampler(environment);
sampler.setRewardFunction(rewardFunction);
sampler.setReturnFunction(returnFunction);

environment.initObject();

sampler.finalizeSampler();
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

save('+Environments/+DynamicalSystems/+tests/quadLinkTrajectories.mat', 'newData2', 'dataManager');
