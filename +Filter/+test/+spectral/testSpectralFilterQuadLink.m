 Common.clearClasses
clear variables;
close all;

numSamplesPerEpisode = 45;
numEpisodes = 200;

obsIdx = [8:43];

process_noise = .1;
Filter.test.setup.QuadLinkSampler;
obs_noise = 1e-3;
Filter.test.setup.NoisePreprocessor;
window_prepro_input = {'endEffPositionsNoisy', 'endEffPositions'};
window_size = {10 4};
obs_ind = {8 1};
Filter.test.setup.WindowPreprocessor;
window_size = window_size{1}-2;

% add some aliases
dataManager.addDataAlias('x1', 'endEffPositionsNoisyWindows', 1:window_size*2);
dataManager.addDataAlias('x2', 'endEffPositionsNoisyWindows', 3:(window_size+1)*2);
dataManager.addDataAlias('x3', 'endEffPositionsNoisyWindows', 5:(window_size+2)*2);

dataManager.addDataAlias('allValid',{'endEffPositionsNoisyWindowsValid' 'endEffPositionsWindowsValid'});

% referenceSet settings
settings.setProperty('state1KRS_maxSizeReferenceSet', 750);
settings.setProperty('state2KRS_maxSizeReferenceSet', 750);
settings.setProperty('state3KRS_maxSizeReferenceSet', 750);
settings.setProperty('state1KRS_inputDataEntry', 'x1');
settings.setProperty('state1KRS_validityDataEntry', 'endEffPositionsNoisyWindowsValid');
settings.setProperty('state2KRS_inputDataEntry', 'x2');
settings.setProperty('state2KRS_validityDataEntry', 'endEffPositionsNoisyWindowsValid');
settings.setProperty('state3KRS_inputDataEntry', 'x3');
settings.setProperty('state3KRS_validityDataEntry', 'endEffPositionsNoisyWindowsValid');

% create gkkf
features1 = 'x1';
features2 = 'x2';
features3 = 'x3';
obsFeatures = features1;

kernel = Kernels.ScaledBandwidthExponentialQuadraticKernel(dataManager, 16, 'kernel');

state1KernelReferenceSet = Kernels.KernelReferenceSet(dataManager, kernel, 'state1KRS');
state2KernelReferenceSet = Kernels.KernelReferenceSet(dataManager, kernel, 'state2KRS');
state3KernelReferenceSet = Kernels.KernelReferenceSet(dataManager, kernel, 'state3KRS');

state1KRSL = Kernels.Learner.GreedyKernelReferenceSetLearner(dataManager, state1KernelReferenceSet);
state2KRSL = Kernels.Learner.CloneKernelReferenceSetLearner(dataManager, state2KernelReferenceSet, state1KernelReferenceSet);
state3KRSL = Kernels.Learner.CloneKernelReferenceSetLearner(dataManager, state3KernelReferenceSet, state1KernelReferenceSet);

bandwidthSelector = Kernels.Learner.RandomMedianBandwidthSelector(dataManager, state1KernelReferenceSet);
bandwidthSelector.kernelMedianBandwidthFactor = .9;

% #########################################

settings.setProperty('spectralLearner_outputDataName','endEffPositionsNoisy');

spectralFilter = Filter.WindowPredictionSpectralFilter(dataManager, 16, 16, state1KernelReferenceSet, state2KernelReferenceSet, state3KernelReferenceSet);
            
spectralLearner = Filter.Learner.SpectralFilterLearner(dataManager, spectralFilter, 200, features1, {'x1', 'obsPoints'}, {'filteredMu'}, {2});
spectralLearner.bandwidthSelector = bandwidthSelector;
spectralLearner.state1KRSL = state1KRSL;
spectralLearner.state2KRSL = state2KRSL;
spectralLearner.state3KRSL = state3KRSL;

settings.setProperty('spectralLearner_lambda',exp(-4));

settings.setProperty('spectralOptimizer_groundtruthName', 'endEffPositionsWindows');
settings.setProperty('spectralOptimizer_observationIndex', 1:8);
settings.setProperty('spectralOptimizer_validityDataEntry', 'allValid');
settings.setProperty('HyperParametersOptimizerSpectral_CMAES_optimization','ConstrainedCMAES');
settings.setProperty('spectralOptimizer_initUpperParamLogBounds', []);
settings.setProperty('spectralOptimizer_initLowerParamLogBounds', [-10]);
settings.setProperty('spectralOptimizer_initUpperParamLogBoundsIdx', []);
settings.setProperty('spectralOptimizer_initLowerParamLogBoundsIdx', 'end');
% settings.setProperty('ParameterMapSpectral_CMAES_optimization',[true false(1,14) true(1,3)]);
settings.setProperty('CMAOptimizerInitialRangeSpectral_CMAES_optimization',.05);
settings.setProperty('maxNumOptiIterationsSpectral_CMAES_optimization', 50);

spectralOptimizer = Filter.Learner.SpectralFilterOptimizer(dataManager, spectralLearner);

dataManager.finalizeDataManager();

% obtain first data object for learning
data = dataManager.getDataObject([numEpisodes,numSamplesPerEpisode]);

%sampler.numSamples = 1000;
sampler.setParallelSampling(true);
fprintf('sampling data\n');
sampler.createSamples(data);

fprintf('adding noise\n');
noisePrepro.preprocessData(data);
fprintf('generating windows\n');
windowsPrepro.preprocessData(data);

obsPoints = false(numSamplesPerEpisode,1);
obsPoints(obsIdx) = true;
data.setDataEntry('obsPoints',repmat(obsPoints,numEpisodes,1));


% fprintf('generating pca features\n');
% pcaFeatureLearner.callDataFunction('updateModel', data);
% %pcaFeatures.setM(eye(pca_size));
% pcaFeatures2.setM(pcaFeatures.M);
% pcaFeatures.callDataFunction('generateFeatures', data);
% pcaFeatures2.callDataFunction('generateFeatures', data);

fprintf('learning model\n');
% spectralLearner.updateModel(data);
spectralOptimizer.updateModel(data);

% obtain second data object for testing
testData = dataManager.getDataObject([numEpisodes,numSamplesPerEpisode]);

%sampler.numSamples = 1000;
sampler.setParallelSampling(true);
fprintf('sampling testData\n');
sampler.createSamples(testData);

fprintf('adding noise\n');
noisePrepro.preprocessData(testData);
% fprintf('generating windows\n');
windowsPrepro.preprocessData(testData);

% fprintf('generating pca features\n');
% pcaFeatures.callDataFunction('generateFeatures', testData);

obsPoints = false(numSamplesPerEpisode,1);
obsPoints(obsIdx) = true;
testData.setDataEntry('obsPoints',repmat(obsPoints,numEpisodes,1));
fprintf('filtering testData\n');

%%
for i = 1:20
%     i = 1;
    figure(1);
    clf;
    hold on;
    [filteredMu] = spectralFilter.callDataFunctionOutput('filterData', testData, i, 1:numSamplesPerEpisode-window_size);
    dataStruct = data.getDataStructure();
    plot(dataStruct.steps(i).endEffPositions(1:numSamplesPerEpisode-window_size,1),dataStruct.steps(i).endEffPositions(1:numSamplesPerEpisode-window_size,2),'b')
    plot(dataStruct.steps(i).endEffPositionsNoisy(1:numSamplesPerEpisode-window_size,1),dataStruct.steps(i).endEffPositions(1:numSamplesPerEpisode-window_size,2),'g')
    plot(dataStruct.steps(i).endEffPositions(obsIdx,1),dataStruct.steps(i).endEffPositions(obsIdx,2),'+r');
%     Plotter.shadedErrorBar([],dataStruct.steps(i).smoothedMu(:,1),2*sqrt(dataStruct.steps(i).smoothedVar(:,1)),'-k',1);
%     for j = 1:1:numSamplesPerEpisode-window_size
%         Plotter.Gaussianplot.plotgauss2d(filteredMu(j,observationIdx)',squeeze(filteredVar(j,observationIdx,observationIdx)),'k');
%     end
    plot(filteredMu(:,1),filteredMu(:,2),'k');
    plot(filteredMu(obsIdx,1),filteredMu(obsIdx,2),'+b');
%     plot(dataStruct.steps(i).states(:,1),':');
    pause
end
