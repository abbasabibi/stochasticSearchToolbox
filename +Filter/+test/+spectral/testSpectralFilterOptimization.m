Common.clearClasses
clear variables;
close all;

obsIdx = [1:5];

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

spectralFilter = Filter.SpectralFilter(dataManager, 4, 4, state1KernelReferenceSet, state2KernelReferenceSet, state3KernelReferenceSet);


settings.setProperty('spectralOptimizer_groundtruthName', 'theta');
settings.setProperty('spectralOptimizer_observationIndex', 1);

spectralLearner = Filter.Learner.SpectralFilterLearner(dataManager, spectralFilter, 20, features1, {'x1', 'obsPoints'}, {'filteredMu'}, {4});
spectralOptimizer = Filter.Learner.SpectralFilterOptimizer(dataManager, spectralLearner);

dataManager.finalizeDataManager();

% obtain first data object for learning
data = dataManager.getDataObject([numEpisodes,numSamplesPerEpisode]);

%sampler.numSamples = 1000;
sampler.setParallelSampling(true);
fprintf('sampling data\n');
sampler.createSamples(data);

obsPoints = false(numSamplesPerEpisode,1);
obsPoints(obsIdx) = true;
data.setDataEntry('obsPoints',repmat(obsPoints,numEpisodes,1));

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

bandwidthSelector.updateModel(data);
state1KRSL.updateModel(data);
state2KRSL.updateModel(data);
state3KRSL.updateModel(data);

spectralLearner.bandwidthSelector = bandwidthSelector;
spectralLearner.state1KRSL = state1KRSL;
spectralLearner.state2KRSL = state2KRSL;
spectralLearner.state3KRSL = state3KRSL;

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

testData.setDataEntry('obsPoints',repmat(obsPoints,numEpisodes,1));
fprintf('filtering testData\n');

%%
figure;
for i = 1:20
    spectralFilter.callDataFunction('filterData',testData, i);
    testDataStruct = testData.getDataStructure();
    hold off
    %Plotter.shadedErrorBar([],testDataStruct.steps(1).filteredMu(:,1),testDataStruct.steps(1).filteredVar(:,1),'-g',1);
    plot(testDataStruct.steps(i).filteredMu(:,1),'k'); hold on
    plot(testDataStruct.steps(i).thetaNoisy(:,1))
    plot(testDataStruct.steps(i).states(:,1),':')
    pause
end
