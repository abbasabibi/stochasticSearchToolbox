Common.clearClasses
clear variables
clc

% obsPointsIdx = [1:5,20];
obsPointsIdx = [1:30];

process_noise = 1;

numSamplesPerEpisode = 30;
numEpisodes = 100;

Filter.test.setup.PendulumSampler;
Filter.test.setup.NoisePreprocessor;

ekf = Filter.ExtendedKalmanFilter(dataManager,environment,2,1);
ekf.setObservationModelWeightsBiasAndCov([1 0],0,obs_noise);
ekf.update_obs_model = false;
ekf.initFiltering({'thetaNoisy', 'obsPoints'}, {'filteredMu', 'filteredVar'}, {1});

data = dataManager.getDataObject([100,30]);

sampler.createSamples(data);
noisePrepro.preprocessData(data);

obsPoints = false(numSamplesPerEpisode,1);
obsPoints(obsPointsIdx) = true;
data.setDataEntry('obsPoints',repmat(obsPoints,numEpisodes,1));

ekf.callDataFunction('initializeMeanAndCov',data,:,1);

% load('+Experiments/data/evalWindowPrediction/SwingDown_stateAliasAdder_noisePreprocessorConfigurator_windowPreprocessorConfigurator_observationPointsPreprocessorConfigurator_gkkfConfigurator/GkkfRegPendulumSwingDown_201502201728_01/eval001/trial001/trial.mat');

%%
for i = 21:40
    ekf.callDataFunction('filterData',data,i);
%     [gkkfMu,gkkfVar] = trial.filterLearner.filter.callDataFunctionOutput('filterData',data,i);
    dataStruct = data.getDataStructure();
    hold off;
    Plotter.shadedErrorBar([],dataStruct.steps(i).filteredMu(:,1),2*sqrt(dataStruct.steps(i).filteredVar(:,1)),'-k',1);
    hold on;
%     Plotter.shadedErrorBar([],gkkfMu(:,1),2*sqrt(gkkfVar(:,1)),'-r',1);
    %plot(testDataStruct.steps(1).filteredMu);
    plot(dataStruct.steps(i).thetaNoisy(:,1))
    plot(dataStruct.steps(i).states(:,1),':');
    pause
end

%%
ekf.callDataFunction('filterData',data);

filteredMu = data.getDataEntry('filteredMu');
groundtruth = data.getDataEntry('states');

squared_error = (filteredMu(:,1) - groundtruth(:,1)).^2;
mse = sum(squared_error(:)) / length(squared_error(:));