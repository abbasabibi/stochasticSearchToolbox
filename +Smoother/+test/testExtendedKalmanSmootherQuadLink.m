Common.clearClasses
clear variables
clc

obsPointsIdx = [1:5];
% obsPointsIdx = [1:5,34,35];
% obsPointsIdx = [1:35];
numSamplesPerEpisode = 43;

process_noise = .1;

numEpisodes = 100;

Filter.test.setup.QuadLinkSampler;
obs_noise = 1e-3;
Filter.test.setup.NoisePreprocessor;

window_prepro_input = {'endEffPositions'};
Filter.test.setup.WindowPreprocessor;

eks = Filter.WindowPredictionExtendedKalmanFilter(dataManager,environment,8,2);
eks.setObservationModelWeightsBiasAndCov([1 0;0 1],[0;0],obs_noise);
eks.windowSize = 4;
eks.stabilizeInitialLinearization = true;
% eks.initSmoothing({'endEffPositionsNoisy', 'obsPoints'}, {'smoothedMu', 'smoothedVar'}, {2});
eks.initFiltering({'endEffPositionsNoisy', 'obsPoints'}, {'filteredMu', 'filteredVar'}, {2});

dataManager.finalizeDataManager();

data = dataManager.getDataObject([100,35]);

sampler.createSamples(data);
noisePrepro.preprocessData(data);
windowsPrepro.preprocessData(data);

obsPoints = false(numSamplesPerEpisode,1);
obsPoints(obsPointsIdx) = true;
data.setDataEntry('obsPoints',repmat(obsPoints,numEpisodes,1));

eks.callDataFunction('initializeMeanAndCov',data,:,1);

% load('+Experiments/data/evalWindowPrediction/SwingDown_stateAliasAdder_noisePreprocessorConfigurator_windowPreprocessorConfigurator_observationPointsPreprocessorConfigurator_gkkfConfigurator/GkkfRegPendulumSwingDown_201502201728_01/eval001/trial001/trial.mat');

%%
eks.outputFullCov = true;
for i = [5 20]
    i
    figure(1);
    clf;
    hold on;
    eks.initialMean = data.dataStructure.steps(i).states(1,:)';
    [smoothedMu, smoothedVar] = eks.callDataFunctionOutput('filterData', data, i, 1:35);
    dataStruct = data.getDataStructure();
    plot(dataStruct.steps(i).endEffPositions(1:numSamplesPerEpisode,1),dataStruct.steps(i).endEffPositions(1:numSamplesPerEpisode,2),'b')
    plot(dataStruct.steps(i).endEffPositionsNoisy(1:numSamplesPerEpisode,1),dataStruct.steps(i).endEffPositions(1:numSamplesPerEpisode,2),'g')
    plot(dataStruct.steps(i).endEffPositions(obsPointsIdx,1),dataStruct.steps(i).endEffPositions(obsPointsIdx,2),'+r');
%     Plotter.shadedErrorBar([],dataStruct.steps(i).smoothedMu(:,1),2*sqrt(dataStruct.steps(i).smoothedVar(:,1)),'-k',1);
    for j = 1:1:numSamplesPerEpisode
        Plotter.Gaussianplot.plotgauss2d(smoothedMu(j,1:2)',squeeze(smoothedVar(j,1:2,1:2)),'k');
    end
    plot(smoothedMu(:,1),smoothedMu(:,2),'k');
    plot(smoothedMu(obsPointsIdx,1),smoothedMu(obsPointsIdx,2),'+b');
%     plot(dataStruct.steps(i).states(:,1),':');
    pause
end

%%
error_ind = false(1,numEpisodes);
for i = 1:numEpisodes
    try
        eks.callDataFunction('filterData',data,i);
    catch E
        error_ind(i) = true;
    end
end

filteredMu = data.getDataEntry('filteredMu',not(error_ind));
groundtruth = data.getDataEntry('endEffPositionsWindows',not(error_ind));
valid = logical(data.getDataEntry('endEffPositionsWindowsValid',not(error_ind)));

filteredMu = filteredMu(valid,:);
groundtruth = groundtruth(valid,:);

squared_error = (reshape(filteredMu,[],2,4) - reshape(groundtruth,[],2,4)).^2;
euclidean_dists = sqrt(sum(squared_error,2));
med = squeeze(sum(euclidean_dists,1) / size(euclidean_dists,1));
