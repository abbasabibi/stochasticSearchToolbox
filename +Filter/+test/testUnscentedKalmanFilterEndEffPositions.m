Common.clearClasses
clear variables
clc

numSamplesPerEpisode = 35;
% obsPointsIdx = [1:5 35];
obsPointsIdx = [1:35];

process_noise = 1;

numEpisodes = 100;

Filter.test.setup.QuadLinkSampler;
% Filter.test.setup.DoublePendulumSampler;
obs_noise = 1e-3;
Filter.test.setup.NoisePreprocessor;

window_prepro_input = {'endEffPositions'};
Filter.test.setup.WindowPreprocessor;

ukf = Filter.UnscentedKalmanFilter(dataManager,environment,8,2);
ukf.setObservationModelWeightsBiasAndCov([1 0;0 1],[0;0],obs_noise * eye(2));
% ukf.windowSize = 4;
ukf.stabilizeInitialLinearization = true;
ukf.initFiltering({'endEffPositionsNoisy', 'obsPoints'}, {'filteredMu', 'filteredVar'}, {2});
ukf.observationFunction = @(mean, noise) environment.getForwardKinematics(mean) + noise;
ukf.alphaSquared = 1e-2;
ukf.kappa = 0;
ukf.beta = 2;
ukf.obs_sigma = .001 * eye(2);
ukf.useLinearObservationModel = false;

data = dataManager.getDataObject([100,35]);

sampler.createSamples(data);
noisePrepro.preprocessData(data);
windowsPrepro.preprocessData(data);

obsPoints = false(numSamplesPerEpisode,1);
obsPoints(obsPointsIdx) = true;
data.setDataEntry('obsPoints',repmat(obsPoints,numEpisodes,1));

ukf.callDataFunction('initializeMeanAndCov',data,:,1);

%%
ukf.outputFullCov = true;
for i = 1:20
%     i = 1;
    figure(1);
    clf;
    hold on;
    [filteredMu, filteredVar] = ukf.callDataFunctionOutput('filterData', data, i);
    dataStruct = data.getDataStructure();
    plot(dataStruct.steps(i).endEffPositions(1:numSamplesPerEpisode,1),dataStruct.steps(i).endEffPositions(1:numSamplesPerEpisode,2),'b')
    plot(dataStruct.steps(i).endEffPositionsNoisy(1:numSamplesPerEpisode,1),dataStruct.steps(i).endEffPositions(1:numSamplesPerEpisode,2),'g')
    plot(dataStruct.steps(i).endEffPositions(obsPointsIdx,1),dataStruct.steps(i).endEffPositions(obsPointsIdx,2),'+r');
%     Plotter.shadedErrorBar([],dataStruct.steps(i).smoothedMu(:,1),2*sqrt(dataStruct.steps(i).smoothedVar(:,1)),'-k',1);
    for j = 1:1:numSamplesPerEpisode
        Plotter.Gaussianplot.plotgauss2d(filteredMu(j,1:2)',squeeze(filteredVar(j,1:2,1:2)),'k');
    end
    plot(filteredMu(:,1),filteredMu(:,2),'k');
    plot(filteredMu(obsPointsIdx,1),filteredMu(obsPointsIdx,2),'+b');
%     plot(dataStruct.steps(i).states(:,1),':');
    pause
end

%%
% ukf.callDataFunction('filterData',data);
% 
% filteredMu = data.getDataEntry('filteredMu');
% groundtruth = data.getDataEntry('states');
% 
% squared_error = (filteredMu(:,1) - groundtruth(:,1)).^2;
% mse = sum(squared_error(:)) / length(squared_error(:));