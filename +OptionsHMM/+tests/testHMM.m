clear variables;
close all;


sampler = Sampler.EpisodeWithStepsSampler();

dataManager = sampler.getEpisodeDataManager();
sampler.getStepSampler.setIsActiveSampler(Sampler.IsActiveStepSampler.IsActiveNumSteps(dataManager));


environment = OptionsHMM.tests.EnvironmentHMM(sampler);
contextSampler = Sampler.InitialSampler.InitialContextSamplerStandard(sampler);
contextSampler.InitialContextDistributionType = 'Uniform';

sampler.setContextSampler(contextSampler);
% sampler.setActionPolicy(environment);
sampler.setTransitionFunction(environment);
sampler.setInitialStateSampler(environment);

policy = Distributions.Gaussian.GaussianActionPolicy(dataManager);
sampler.setActionPolicy(policy);

% set weights of action policy 
% take traj data from old version and set data entries
% 
% 


dataManager.finalizeDataManager();
environment.initObject();

newData = dataManager.getDataObject(10);


sampler.numSamples = 1000;
sampler.setParallelSampling(true);

sampler.createSamples(newData);



