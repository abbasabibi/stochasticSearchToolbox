Common.clearClasses
clear variables
clc

% obsPointsIdx = [1:5,20];
obsPointsIdx = [1:30];

process_noise = 1;

numEpisodes = 100;

Filter.test.setup.DoublePendulumSampler;
Filter.test.setup.NoisePreprocessor;
window_prepro_input = {current_data_pipe{:}, 'states'};
Filter.test.setup.WindowPreprocessor;

ukf = Filter.WindowPredictionUnscentedKalmanFilter(dataManager,environment,2,1);
ukf.windowSize = 4;
ukf.setObservationModelWeightsBiasAndCov([1 0],0,obs_noise);
ukf.initFiltering({'endEffPositionsNoisy', 'obsPoints'}, {'filteredMu', 'filteredVar'}, 2);
ukf.alphaSquared = 1e-6;
ukf.kappa = 0;
ukf.beta = 2;
ukf.obs_sigma = .00001;
ukf.useLinearObservationModel = false;
ukf.observationFunction = @(mean,noise) environment.getForwardKinematics(mean(1:2:end)) + noise';

data = dataManager.getDataObject([100,30]);

sampler.createSamples(data);
noisePrepro.preprocessData(data);
windowsPrepro.preprocessData(data);

obsPoints = false(numSamplesPerEpisode,1);
obsPoints(obsPointsIdx) = true;
data.setDataEntry('obsPoints',repmat(obsPoints,numEpisodes,1));

ukf.callDataFunction('initializeMeanAndCov',data,:,1);

%%
ukf.callDataFunction('filterData',data);

%%
filteredMu = data.getDataEntry('filteredMu');
groundtruth = data.getDataEntry('statesWindows');
valid = logical(data.getDataEntry('statesWindowsValid'));

squared_error = (filteredMu(valid,1:2:8) - groundtruth(valid,1:2:8)).^2;
mse = sum(squared_error,1) / size(squared_error,1);