clear variables;
close all;

settings = Common.IASParameters();

sampler = Sampler.EpisodeSampler(settings);
environment = Sampler.test.EnvironmentTest(sampler.getEpisodeDataManager());

sampler.setContextSampler(environment);
sampler.setParameterPolicy(environment);
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