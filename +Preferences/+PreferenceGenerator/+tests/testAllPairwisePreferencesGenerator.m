clear variables;
close all;

settings = Common.Settings();
settings.setProperty('numTimeSteps', 100);   
settings.setProperty('gamma', 0.95);

sampler = Sampler.EpisodeWithStepsSampler();

dataManager = sampler.getEpisodeDataManager();

environment = Environments.Gridworld.SimpleWorld(sampler);

sampler.getStepSampler.setIsActiveSampler(Sampler.IsActiveStepSampler.IsActiveNumSteps(dataManager));

sampler.setContextSampler(environment);
sampler.setActionPolicy(environment);
sampler.setTransitionFunction(environment);
sampler.setRewardFunction(environment);
sampler.setInitialStateSampler(environment);

sampler.setReturnFunction(RewardFunctions.ReturnForEpisode.ReturnSummedReward(sampler));

tabFeatures = FeatureGenerators.TabularFeatures(dataManager, 'states');

featureEx = FeatureGenerators.FeatureExpectations(dataManager,'statesTabular');

returns = Preferences.RankingGenerator.RewardSumRanker(dataManager, 'returns');

prefs = Preferences.PreferenceGenerator.AllPairwisePreferencesGenerator(dataManager,'returnsranks',5);

dataManager.finalizeDataManager();
newData = dataManager.getDataObject(10);
newData2 = dataManager.getDataObject(0);


sampler.numSamples = 5;

sampler.setParallelSampling(true);
fprintf('Generating Data 1\n');
tic
sampler.createSamples(newData);
toc

newData.getDataEntry('returnsrankspreferences')