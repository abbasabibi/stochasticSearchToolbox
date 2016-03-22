Common.clearClasses
clear variables
clc

% obsPointsIdx = [1:5,20];
obsPointsIdx = [1:18];
numSamplesPerEpisode = 18;

numEpisodes = 1000;

process_noise = .1;
Filter.test.setup.DoublePendulumSampler;
obs_noise = 1e-4;
Filter.test.setup.NoisePreprocessor;

monteCarloSmoother = Smoother.MonteCarloSmoother(dataManager,1,1);
monteCarloSmoother.initSmoothing({'endEffPositionsNoisy','obsPoints'},{'smoothedMu','smoothedVar'},{1 1});

monteCarloSmoother.dataEntry = 'endEffPositionsNoisy';
monteCarloSmoother.preprocessors = {noisePrepro};

data = dataManager.getDataObject([20,30]);

sampler.createSamples(data);
noisePrepro.preprocessData(data);

obsPoints = false(numSamplesPerEpisode,1);
obsPoints(obsPointsIdx) = true;
data.setDataEntry('obsPoints',repmat(obsPoints,numEpisodes,1));

monteCarloSmoother.sampleShitloadOfData(sampler);

%%
monteCarloSmoother.callDataFunction('smoothData',data);

smoothedMu = data.getDataEntry3D('smoothedMu');
groundtruth = data.getDataEntry3D('endEffPositions');

euclidean_distance = sqrt(sum((smoothedMu - groundtruth).^2,3));
med = sum(euclidean_distance(:)) / length(euclidean_distance(:));

%%
monteCarloSmoother.outputFullCovariance = true;

for i = 1:20
%     i = 1;
    figure(1);
    clf;
    hold on;
    [smoothedMu, smoothedVar] = monteCarloSmoother.callDataFunctionOutput('smoothData', data, i, 1:numSamplesPerEpisode);
    dataStruct = data.getDataStructure();
    plot(dataStruct.steps(i).endEffPositions(1:numSamplesPerEpisode,1),dataStruct.steps(i).endEffPositions(1:numSamplesPerEpisode,2))
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