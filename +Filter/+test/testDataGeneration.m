clear variables;
close all;
settings = Common.Settings();
settings.setProperty('Noise_std', 1.0);
settings.setProperty('Noise_mode', 0);
settings.setProperty('dt',1e-2);
settings.setProperty('numSamplesEpisodes',100);
settings.setProperty('numTimeSteps',200);
obs_noise = .001;
window_size = 4;
pca_size = 4;

% create sampler
sampler = Sampler.EpisodeWithStepsSampler();

% get dataManager from sampler
dataManager = sampler.getEpisodeDataManager();


% add context sampler
dataManager.addDataEntry('contexts', 2, [-.25*pi, -2*pi], [.25*pi, 2*pi]);
settings.setProperty('InitialContextDistributionType', 'Uniform');
initialContextSampler = Sampler.InitialSampler.InitialContextSamplerStandard(sampler);

%stepSampler = sampler.getStepSampler();

environment = Environments.DynamicalSystems.Pendulum(sampler, false);
environment.friction = 5;

sampler.setContextSampler(initialContextSampler);
sampler.setInitialStateSampler(environment);
sampler.setTransitionFunction(environment);

environment.initObject();
sampler.finalizeSampler();

% add preprocessor
obsNoisePrepro = DataPreprocessors.AdditiveGaussianNoisePreprocessor(dataManager,obs_noise,'states');
windowsPrepro = DataPreprocessors.GenerateDataWindowsPreprocessor(dataManager,window_size,'noisy_states');

% add feature Generator
pcaFeatures = FeatureGenerators.LinearTransformFeatures(dataManager, 'noisy_states_windows_1', 'pca_features', ':', pca_size, false);
pcaFeatureLearner = FeatureGenerators.FeatureLearner.PrimaryComponentsAnalysis(pcaFeatures);

data = dataManager.getDataObject([100,400]);

%sampler.numSamples = 1000;
sampler.setParallelSampling(true);
fprintf('Generating Data\n');
tic
sampler.createSamples(data);
toc

states = data.getDataEntry3D('states');

obsNoisePrepro.preprocessData(data);
windowsPrepro.preprocessData(data);

pcaFeatureLearner.callDataFunction('updateModel', data);
pcaFeatures.callDataFunction('generateFeatures', data);