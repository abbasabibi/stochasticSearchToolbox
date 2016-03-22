clear variables;
close all;

settings = Common.Settings.createNewSettings();
settings.setProperty('Noise_std', 1.0);
settings.setProperty('InitialStateDistributionMinRange', [pi - pi, -2]);
settings.setProperty('InitialStateDistributionMaxRange', [pi + pi, 2]);
settings.setProperty('InitialStateDistributionType', 'Uniform');
settings.setProperty('dt', 0.025);
settings.setProperty('initSigmaActions', 1.0);

sampler = Sampler.EpisodeWithStepsSampler();

dataManager = sampler.getEpisodeDataManager();
stepSampler = sampler.getStepSampler();
stepSampler.isActiveSampler.numTimeSteps = 40;

environment = Environments.DynamicalSystems.Pendulum(sampler, true);

initialStateSampler = Sampler.InitialSampler.InitialStateSamplerStandard(sampler);
actionCost = 0.001;
stateCost = [10 0; 0 0];

rewardFunction = RewardFunctions.QuadraticRewardFunctionSwingUp(dataManager);
rewardFunction.setStateActionCosts(stateCost, actionCost);
returnFunction = RewardFunctions.ReturnForEpisode.ReturnSummedReward(dataManager);

actionPolicy = Distributions.Gaussian.GaussianActionPolicy(dataManager);

sampler.setTransitionFunction(environment);
sampler.setInitialStateSampler(initialStateSampler);
sampler.setActionPolicy(actionPolicy);
sampler.setRewardFunction(rewardFunction);
sampler.setReturnFunction(returnFunction);

environment.initObject();
actionPolicy.initObject();

sampler.finalizeSampler();
data = dataManager.getDataObject(10);

sampler.numSamples = 1000;
sampler.setParallelSampling(true);
fprintf('Generating Data\n');
tic
sampler.createSamples(data);
toc


s = data.getDataEntry('states',1,:);
size(s)
s(1,:)
ns= size(s,1);
h = figure(1);
colorMap = [linspace(1,0,ns); linspace(0,0,ns); linspace(0,1,ns)]';
environment.animate(s, h, 1, colorMap)

save('pendulumData.mat');
