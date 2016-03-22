Common.clearClasses
clear variables;
close all;

obsIdx = [1:30];

Filter.test.setup.PendulumSampler;
Filter.test.setup.NoisePreprocessor;
window_size = 6;
Filter.test.setup.WindowPreprocessor;
window_size = window_size-2;

% add some aliases
dataManager.addDataAlias('x1', 'thetaNoisyWindows', 1:window_size);
dataManager.addDataAlias('x2', 'thetaNoisyWindows', 2:window_size+1);
dataManager.addDataAlias('x3', 'thetaNoisyWindows', 3:window_size+2);

% referenceSet settings
settings.setProperty('state1KRS_maxSizeReferenceSet', 300);
settings.setProperty('state2KRS_maxSizeReferenceSet', 300);
settings.setProperty('state3KRS_maxSizeReferenceSet', 300);
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

kernel = Kernels.ExponentialQuadraticKernel(dataManager, window_size, 'kernel');

state1KernelReferenceSet = Kernels.KernelReferenceSet(dataManager, kernel, 'state1KRS');
state2KernelReferenceSet = Kernels.KernelReferenceSet(dataManager, kernel, 'state2KRS');
state3KernelReferenceSet = Kernels.KernelReferenceSet(dataManager, kernel, 'state3KRS');

state1KRSL = Kernels.Learner.GreedyKernelReferenceSetLearner(dataManager, state1KernelReferenceSet);
state2KRSL = Kernels.Learner.CloneKernelReferenceSetLearner(dataManager, state2KernelReferenceSet, state1KernelReferenceSet);
state3KRSL = Kernels.Learner.CloneKernelReferenceSetLearner(dataManager, state3KernelReferenceSet, state1KernelReferenceSet);

bandwidthSelector = Kernels.Learner.RandomMedianBandwidthSelector(dataManager, state1KernelReferenceSet);
bandwidthSelector.kernelMedianBandwidthFactor = .1;

% #########################################

spectralFilter = Filter.WindowPredictionSpectralFilter(dataManager, 4, 4, state1KernelReferenceSet, state2KernelReferenceSet, state3KernelReferenceSet);
            
spectralLearner = Filter.Learner.SpectralFilterLearner(dataManager, spectralFilter, 100, features1, {'x1', 'obsPoints'}, {'filteredMu'}, 4);

spectralLearner.state1KRSL = state1KRSL;
spectralLearner.state2KRSL = state2KRSL;
spectralLearner.state3KRSL = state3KRSL;

spectralLearner.bandwidthSelector = bandwidthSelector;

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

fprintf('generating pca features\n');
% pcaFeatureLearner.callDataFunction('updateModel', data);
% %pcaFeatures.setM(eye(pca_size));
% pcaFeatures2.setM(pcaFeatures.M);
% pcaFeatures.callDataFunction('generateFeatures', data);
% pcaFeatures2.callDataFunction('generateFeatures', data);

fprintf('learning model\n');

spectralLearner.updateModel(data);

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
spectralFilter.callDataFunction('filterData',testData, 1);

%%
testDataStruct = testData.getDataStructure();
figure; hold on;
%Plotter.shadedErrorBar([],testDataStruct.steps(1).filteredMu(:,1),testDataStruct.steps(1).filteredVar(:,1),'-g',1);
plot(testDataStruct.steps(1).filteredMu,'k');
plot(testDataStruct.steps(1).thetaNoisy(:,1))
plot(testDataStruct.steps(1).states(:,1),':')
