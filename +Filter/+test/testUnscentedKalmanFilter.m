Common.clearClasses
clear variables
clc

obsPointsIdx = [1:30];

process_noise = 1;

numSamplesPerEpisode = 30;
numEpisodes = 100;

Filter.test.setup.PendulumSampler;
Filter.test.setup.NoisePreprocessor;

ukf = Filter.UnscentedKalmanFilter(dataManager,environment,2,1);
ukf.setObservationModelWeightsBiasAndCov([1 0],0,obs_noise);
ukf.initFiltering({'thetaNoisy', 'obsPoints'}, {'filteredMu', 'filteredVar'}, {1});
ukf.alphaSquared = 1e-6;
ukf.kappa = 0;
ukf.beta = 2;
ukf.obs_sigma = .01;
ukf.useLinearObservationModel = true;
ukf.update_obs_model = false;

data = dataManager.getDataObject([100,30]);

sampler.createSamples(data);
noisePrepro.preprocessData(data);

obsPoints = false(numSamplesPerEpisode,1);
obsPoints(obsPointsIdx) = true;
data.setDataEntry('obsPoints',repmat(obsPoints,numEpisodes,1));

ukf.callDataFunction('initializeMeanAndCov',data,:,1);

%%
for i = 21:40
    ukf.callDataFunction('filterData',data,i);
    dataStruct = data.getDataStructure();
    hold off;
    Plotter.shadedErrorBar([],dataStruct.steps(i).filteredMu(:,1),2*sqrt(dataStruct.steps(i).filteredVar(:,1)),'-k',1);
    hold on;
    %plot(testDataStruct.steps(1).filteredMu);
    plot(dataStruct.steps(i).thetaNoisy(:,1))
    plot(dataStruct.steps(i).states(:,1),':');
    pause
end

%%
ukf.callDataFunction('filterData',data);

filteredMu = data.getDataEntry('filteredMu');
groundtruth = data.getDataEntry('states');

squared_error = (filteredMu(:,1) - groundtruth(:,1)).^2;
mse = sum(squared_error(:)) / length(squared_error(:));