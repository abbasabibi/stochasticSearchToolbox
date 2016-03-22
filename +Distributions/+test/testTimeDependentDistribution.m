clear variables;
close all;

settings = Common.IASParameters();

sampler = Sampler.EpisodeWithStepsSampler(settings);

dataManager = sampler.getEpisodeDataManager();
dataManager.addDataEntry('contexts', 1, -1, 1);

stepSampler = sampler.getStepSampler();
environment = Environments.DynamicalSystems.LinearSystem(settings, sampler, 1);

contextSampler = Sampler.InitialSampler.InitialContextSamplerStandard(settings, sampler);
initialStateSampler = Sampler.InitialSampler.InitialStateSamplerStandard(settings, sampler);
initialStateSampler.setInitStateFromContext(true);
rewardFunction = Environments.DynamicalSystems.tests.TestRewardFunction(settings, sampler);
returnFunction = RewardFunctions.ReturnForEpisode.ReturnSummedReward(settings, sampler);

sampler.setTransitionFunction(environment);
sampler.setContextSampler(contextSampler);
sampler.setInitialStateSampler(initialStateSampler);
sampler.setRewardFunction(rewardFunction);
sampler.setReturnFunction(returnFunction);

environment.initObject();

distributionInitializer = @Distributions.Gaussian.GaussianActionPolicy;

timeDependentDistribution = Distributions.TimeDependent.ComposedTimeDependentDistribution(dataManager, distributionInitializer, sampler.getStepSampler().getNumSamples());
timeDependentDistribution.initObject();

weights = randn(timeDependentDistribution.dimOutput, timeDependentDistribution.dimInput);
bias =  randn(timeDependentDistribution.dimOutput,1);

timeDependentDistribution.initObject();

for i = 1:length(timeDependentDistribution.distributionPerTimeStep)
    timeDependentDistribution.distributionPerTimeStep{i}.setWeightsAndBias(weights, bias * i * 100);
end

sampler.setActionPolicy(timeDependentDistribution);
dataManager.finalizeDataManager();
newData = dataManager.getDataObject(10);
newData2 = dataManager.getDataObject(0);


sampler.numSamples = 1000;
sampler.setParallelSampling(true);
fprintf('Generating Data\n');
tic
sampler.createSamples(newData);
toc

dataProbabilities = timeDependentDistribution.callDataFunctionOutput('getDataProbabilities', newData);

learner = Learner.SupervisedLearner.TimeDependentLearner(dataManager, timeDependentDistribution, @Learner.SupervisedLearner.LinearGaussianMLLearner, 10);
learner.updateModel(newData);