%

if ~exist('process_noise','var')
    process_noise = 1;
end

if ~exist('numEpisodes','var')
    numEpisodes = 1000;
end

if ~exist('numSamplesPerEpisode','var')
    numSamplesPerEpisode = 30;
end

if ~exist('isPeriodic','var')
    isPeriodic = false;
end

if ~exist('settings','var')
    settings = Common.Settings();
end

% sampler settings
settings.setProperty('Noise_std', process_noise);
settings.setProperty('Noise_mode', 0);
settings.setProperty('dt',1e-1);
settings.setProperty('numSamplesEpisodes',numEpisodes);
settings.setProperty('numInitialSamplesEpisodes',numEpisodes);
settings.setProperty('numTimeSteps',numSamplesPerEpisode);

% create sampler
sampler = Sampler.EpisodeWithStepsSampler();

% get dataManager from sampler
dataManager = sampler.getEpisodeDataManager();

% add context sampler
dataManager.addDataEntry('contexts', 2, [.1*pi, -.5*pi], [.4*pi, .5*pi]);
settings.setProperty('InitialContextDistributionType', 'Uniform');
initialContextSampler = Sampler.InitialSampler.InitialContextSamplerStandard(sampler);

environment = Environments.DynamicalSystems.Pendulum(sampler, isPeriodic);
environment.friction = 1.;
environment.masses = 5;

featureEndEffector = Environments.Misc.PlanarKinematicsEndEffPositionFeature(dataManager, environment);

sampler.setContextSampler(initialContextSampler);
sampler.setInitialStateSampler(environment);
sampler.setTransitionFunction(environment);

environment.initObject();
sampler.finalizeSampler();
sampler.setParallelSampling(true);

dataManager.addDataEntry('steps.obsPoints',1);
dataManager.addDataAlias('theta', 'states', 1);
dataManager.addDataAlias('nextTheta', 'nextStates', 1);

current_data_pipe = {'theta', 'endEffPositions'};
