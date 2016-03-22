Common.clearClasses
clear variables
clc

obsPointsIdx = [1:5,35];
% obsPointsIdx = [1:35];
numSamplesPerEpisode = 35;

process_noise = 1;

numEpisodes = 100;

Filter.test.setup.PendulumSampler;
obs_noise = 1e-3;
Filter.test.setup.NoisePreprocessor;

eks = Smoother.ExtendedKalmanSmoother(dataManager,environment,2,2);
eks.setObservationModelWeightsBiasAndCov([1 0;0 1],[0; 0],obs_noise * eye(2));
eks.initSmoothing({'endEffPositionsNoisy', 'obsPoints'}, {'smoothedMu', 'smoothedVar'}, {2});
eks.initFiltering({'endEffPositionsNoisy', 'obsPoints'}, {'filteredMu', 'filteredVar'}, {2});

data = dataManager.getDataObject([100,35]);

sampler.createSamples(data);
noisePrepro.preprocessData(data);

obsPoints = false(numSamplesPerEpisode,1);
obsPoints(obsPointsIdx) = true;
data.setDataEntry('obsPoints',repmat(obsPoints,numEpisodes,1));

eks.callDataFunction('initializeMeanAndCov',data,:,1);

% load('+Experiments/data/evalWindowPrediction/SwingDown_stateAliasAdder_noisePreprocessorConfigurator_windowPreprocessorConfigurator_observationPointsPreprocessorConfigurator_gkkfConfigurator/GkkfRegPendulumSwingDown_201502201728_01/eval001/trial001/trial.mat');

%%
eks.outputFullCov = true;
for i = 1:20
%     i = 1;
    figure(1);
    clf;
    hold on;
    [smoothedMu, smoothedVar] = eks.callDataFunctionOutput('smoothData', data, i);
    dataStruct = data.getDataStructure();
    plot(dataStruct.steps(i).endEffPositions(1:numSamplesPerEpisode,1),dataStruct.steps(i).endEffPositions(1:numSamplesPerEpisode,2),'b')
    plot(dataStruct.steps(i).endEffPositionsNoisy(1:numSamplesPerEpisode,1),dataStruct.steps(i).endEffPositions(1:numSamplesPerEpisode,2),'g')
    plot(dataStruct.steps(i).endEffPositions(obsPointsIdx,1),dataStruct.steps(i).endEffPositions(obsPointsIdx,2),'+r');
%     Plotter.shadedErrorBar([],dataStruct.steps(i).smoothedMu(:,1),2*sqrt(dataStruct.steps(i).smoothedVar(:,1)),'-k',1);
    for j = 1:1:numSamplesPerEpisode
        Plotter.Gaussianplot.plotgauss2d(smoothedMu(j,:)',squeeze(smoothedVar(j,:,:)),'k');
    end
    plot(smoothedMu(:,1),smoothedMu(:,2),'k');
    plot(smoothedMu(obsPointsIdx,1),smoothedMu(obsPointsIdx,2),'+b');
%     plot(dataStruct.steps(i).states(:,1),':');
    pause
end

%%
eks.callDataFunction('filterData',data);

filteredMu = data.getDataEntry('filteredMu');
groundtruth = data.getDataEntry('states');

squared_error = (filteredMu(:,1) - groundtruth(:,1)).^2;
mse = sum(squared_error(:)) / length(squared_error(:));