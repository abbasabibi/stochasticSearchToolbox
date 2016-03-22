%

if ~exist('process_noise','var')
    process_noise = 1e-2;
end

if ~exist('numEpisodes','var')
    numEpisodes = 1000;
end

if ~exist('numSamplesPerEpisode','var')
    numSamplesPerEpisode = 30;
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
dataManager.addDataEntry('contexts', 4, [-0.4*pi, -0*pi, -0.2 * pi, -0.*pi], [-.3*pi, 0.*pi, 0.2*pi, 0.*pi]);
settings.setProperty('InitialContextDistributionType', 'Uniform');
initialContextSampler = Sampler.InitialSampler.InitialContextSamplerStandard(sampler);

dataManager.addDataEntry('steps.obsPoints',1);

environment = Environments.DynamicalSystems.DoubleLink(sampler);
environment.friction = 0.5;
environment.masses = 5;

featureEndEffector = Environments.Misc.PlanarKinematicsEndEffPositionFeature(dataManager, environment);

sampler.setContextSampler(initialContextSampler);
sampler.setInitialStateSampler(environment);
sampler.setTransitionFunction(environment);

environment.initObject();
sampler.finalizeSampler();
sampler.setParallelSampling(true);

% dataManager.finalizeDataManager();
% 
% data = dataManager.getDataObject(0);
% sampler.createSamples(data);
% Plotter.PlotterData.plotTrajectories(data, 'endEffPositions')

dataManager.addDataEntry('steps.obsPoints',1);

current_data_pipe = {'endEffPositions'};
