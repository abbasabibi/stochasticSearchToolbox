clear variables;
close all;

settings = Common.Settings();
settings.setProperty('numTimeSteps', 100);   
settings.setProperty('dynamicProgramC', 0.01);  
settings.setProperty('discountFactor', 0.95);

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

features = FeatureGenerators.TabularFeatures(dataManager, 'states');

featureEx = FeatureGenerators.FeatureExpectations(dataManager,'statesTabular');

returns = Preferences.RankingGenerator.RewardSumRanker(dataManager, 'returns');

prefs = Preferences.PreferenceGenerator.AllPairwisePreferencesGenerator(dataManager,'returnsranks',20);

utilityFuncCalc = Preferences.UtilityCalculator.IRLAlike(dataManager,'statesTabular');
utilityCalc = Preferences.UtilityCalculator.UtilityCalculator(dataManager,utilityFuncCalc);

dataManager.finalizeDataManager();
newData = dataManager.getDataObject(10);
newData2 = dataManager.getDataObject(10);

sampler.numSamples = 10;

sampler.setParallelSampling(true);
fprintf('Generating Data 1\n');
tic
sampler.createSamples(newData);
toc

utilityCalc.preprocessData(newData);
utilityFuncCalc.getUtilitiyFunction()

sampler.setParallelSampling(true);
fprintf('Generating Data 2\n');
tic
sampler.createSamples(newData2);
toc
newData.mergeData(newData2);

utilityCalc.preprocessData(newData);
utilityFuncCalc.getUtilitiyFunction()