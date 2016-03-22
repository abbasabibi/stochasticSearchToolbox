Common.clearClasses
clear variables;
close all;

numEpisodes = 100;

kernel_size = 100;
% obs_kernel_size = 300;

%obs_noise = 
feature_name = 'thetaNoisyWindows';
% feature_name = 'endEffPositionsNoisyWindows';
numSamplesPerEpisode = 30;


% window_prediction = true;
window_size = 4;
obs_ind = 4;
obsPointsIdx = obs_ind:30;
% obsPointsIdx = 1:numSamplesPerEpisode-window_size;
% obsPointsIdx = obs_ind:numSamplesPerEpisode;
process_noise = .1;
Filter.test.setup.PendulumSampler;
obs_noise = 1e-2;
Filter.test.setup.NoisePreprocessor;
Filter.test.setup.WindowPreprocessor;
% windowsPrepro2 = windowsPrepro;
% current_data_pipe = {'endEffPositionsNoisyWindows'};

bandwidth_factor = exp(-1.5);
sigma = exp(-33.5);
lambda = exp(1.01);
q = exp(3.9);
r = exp(.27);

% num_features = window_size * 2;
% output_data_name = {'endEffPositions'};

% window_prediction = true;
% window_size = 4;
kernel_type = 'ScaledBandwidthExponentialQuadraticKernel';
% feature_name = 'endEffPositionsWindows';
Filter.test.setup.CeokkfLearner;


% window_prepro_name = 'groundtruthWindows';
% obs_ind = 1;
% window_size = 4;
% window_prepro_input = 'endEffPositions';
% window_prepro_output = {'endEffPositionsWindows'};
% Filter.test.setup.WindowPreprocessor;

% dataManager.addDataAlias('allValid',{'endEffPositionsNoisyWindowsValid' 'endEffPositionsWindowsValid'});

settings.setProperty('ceokkfOptimizer_groundtruthName','theta');
settings.setProperty('ceokkfOptimizer_observationIndex',4);
settings.setProperty('ceokkfOptimizer_validityDataEntry','thetaNoisyWindowsValid');
settings.setProperty('ceokkfOptimizer_internalObjective','llh');
% settings.setProperty('ceokkfOptimizer_validityDataEntry','endEffPositionsWindowsValid');
% settings.setProperty('ParameterMapCEOKKF_CMAES_optimization',[false false false false false]);
settings.setProperty('CMAOptimizerInitialRangeCEOKKF_CMAES_optimization', 0.05);
settings.setProperty('maxNumOptiIterationsCEOKKF_CMAES_optimization', 50);

ceokkfLearner.addDataPreprocessor(noisePrepro);
% ceokkfLearner.addDataPreprocessor(windowsPrepro2);
ceokkfLearner.addDataPreprocessor(windowsPrepro);

optimizer = Filter.Learner.CEOKernelKalmanFilterOptimizer(dataManager, ceokkfLearner);

ceokkfLearner.filter.outputFullCov = true;

dataManager.finalizeDataManager();

% obtain first data object for learning
data = dataManager.getDataObject([numEpisodes,numSamplesPerEpisode]);

%sampler.numSamples = 1000;
rng(1);
fprintf('sampling data\n');
sampler.createSamples(data);

fprintf('preprocessing data\n');
ceokkfLearner.preprocessData(data);
ceokkfLearner.updateModel(data);

obsPoints = false(numSamplesPerEpisode,1);
obsPoints(obsPointsIdx) = true;
data.setDataEntry('obsPoints',repmat(obsPoints,numEpisodes,1));

fprintf('starting optimization\n');
% optimizer.processTrainingData(data);
% optimizer.initializeParameters(data);
% optimizer.updateModel(data);

%%
for i = 1:20
%     i = 1;
    optimizer.hyperParameterObject.filter.callDataFunction('filterData', data, i, 1:numSamplesPerEpisode);

    %
    dataStruct = data.getDataStructure();
    hold off;
    Plotter.shadedErrorBar(obs_ind:numSamplesPerEpisode,dataStruct.steps(i).filteredMu(obs_ind:numSamplesPerEpisode,obs_ind),2*sqrt(dataStruct.steps(i).filteredVar(obs_ind:numSamplesPerEpisode,obs_ind)),'-k',1);
    hold on;
    %plot(testDataStruct.steps(1).filteredMu);
    plot(dataStruct.steps(i).thetaNoisy(:,1))
    plot(dataStruct.steps(i).states(:,1),':');
    pause
end
%%
[filteredMu] = optimizer.hyperParameterObject.filter.callDataFunctionOutput('filterData', data, ':', 1:numSamplesPerEpisode);
groundtruth = data.getDataEntry('theta');
