Common.clearClasses
clear variables;
close all;

numSamplesPerEpisode = 30;
numEpisodes = 100;

obsIdx = [1:30];

process_noise = 1;
Filter.test.setup.PendulumSampler;
obs_noise = 1e-2;
Filter.test.setup.NoisePreprocessor;
window_size = 6;
obs_ind = 1;
Filter.test.setup.WindowPreprocessor;
window_size = window_size-2;

% add some aliases
dataManager.addDataAlias('x1', 'thetaNoisyWindows', 1:window_size);
dataManager.addDataAlias('x2', 'thetaNoisyWindows', 2:(window_size+1));
dataManager.addDataAlias('x3', 'thetaNoisyWindows', 3:(window_size+2));

% referenceSet settings
settings.setProperty('state1KRS_maxSizeReferenceSet', 100);
settings.setProperty('state2KRS_maxSizeReferenceSet', 100);
settings.setProperty('state3KRS_maxSizeReferenceSet', 100);
settings.setProperty('state1KRS_inputDataEntry', 'x1');
settings.setProperty('state1KRS_validityDataEntry', 'thetaNoisyWindowsValid');
settings.setProperty('state2KRS_inputDataEntry', 'x2');
settings.setProperty('state2KRS_validityDataEntry', 'thetaNoisyWindowsValid');
settings.setProperty('state3KRS_inputDataEntry', 'x3');
settings.setProperty('state3KRS_validityDataEntry', 'thetaNoisyWindowsValid');

% create gkkf
features1 = 'x1';
features2 = 'x2';
features3 = 'x3';
obsFeatures = features1;

% kernel = Kernels.ExponentialQuadraticKernel(dataManager, 4, 'kernel');
kernel = Kernels.ScaledBandwidthExponentialQuadraticKernel(dataManager, 4, 'kernel');

state1KernelReferenceSet = Kernels.KernelReferenceSet(dataManager, kernel, 'state1KRS');
state2KernelReferenceSet = Kernels.KernelReferenceSet(dataManager, kernel, 'state2KRS');
state3KernelReferenceSet = Kernels.KernelReferenceSet(dataManager, kernel, 'state3KRS');

state1KRSL = Kernels.Learner.GreedyKernelReferenceSetLearner(dataManager, state1KernelReferenceSet);
state2KRSL = Kernels.Learner.CloneKernelReferenceSetLearner(dataManager, state2KernelReferenceSet, state1KernelReferenceSet);
state3KRSL = Kernels.Learner.CloneKernelReferenceSetLearner(dataManager, state3KernelReferenceSet, state1KernelReferenceSet);

bandwidthSelector = Kernels.Learner.RandomMedianBandwidthSelector(dataManager, state1KernelReferenceSet);
bandwidthSelector.kernelMedianBandwidthFactor = .5;

% #########################################

settings.setProperty('spectralLearner_outputDataName','thetaNoisy');

spectralFilter = Filter.SpectralFilter(dataManager, 4, 4, state1KernelReferenceSet, state2KernelReferenceSet, state3KernelReferenceSet);
            
spectralLearner = Filter.Learner.SpectralFilterLearner(dataManager, spectralFilter, 50, features1, {'x1', 'obsPoints'}, {'filteredMu'}, {1});
spectralLearner.bandwidthSelector = bandwidthSelector;
spectralLearner.state1KRSL = state1KRSL;
spectralLearner.state2KRSL = state2KRSL;
spectralLearner.state3KRSL = state3KRSL;
% spectralLearner.numEigenvectors = 25;

settings.setProperty('spectralOptimizer_groundtruthName', 'theta');
settings.setProperty('spectralOptimizer_observationIndex', 1);

spectralOptimizer = Filter.Learner.SpectralFilterOptimizer(dataManager, spectralLearner);

dataManager.finalizeDataManager();

% obtain first data object for learning
data = dataManager.getDataObject([numEpisodes,numSamplesPerEpisode]);
obsPoints = false(numSamplesPerEpisode,1);
obsPoints(obsIdx) = true;
data.setDataEntry('obsPoints',repmat(obsPoints,numEpisodes,1));

%sampler.numSamples = 1000;
sampler.setParallelSampling(true);
fprintf('sampling data\n');
sampler.createSamples(data);

fprintf('adding noise\n');
noisePrepro.preprocessData(data);
fprintf('generating windows\n');
windowsPrepro.preprocessData(data);

bandwidthSelector.updateModel(data);
state1KRSL.updateModel(data);
state2KRSL.updateModel(data);
state3KRSL.updateModel(data);

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
    spectralOptimizer.hyperParameterObject.filter.callDataFunction('filterData', data, i, obs_ind:numSamplesPerEpisode);

    %
    dataStruct = data.getDataStructure();
    hold off;
    plot(1:numSamplesPerEpisode, dataStruct.steps(i).filteredMu(:,1))
    hold on;
    %plot(testDataStruct.steps(1).filteredMu);
    plot(dataStruct.steps(i).thetaNoisy(:,1))
    plot(dataStruct.steps(i).states(:,1),':');
    pause
end
