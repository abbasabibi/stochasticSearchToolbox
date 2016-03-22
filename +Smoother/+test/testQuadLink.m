Common.clearClasses
clear variables;
close all;


numEpisodes = 200;

% numObservedSamples = 5;
% kernel_size = 5000;
kernel_size = 750;
obs_kernel_size = 750;
red_kernel_size = 750;
cond_operator_type = 'std';
numSamplesPerEpisode = 43;


% window_prediction = true;
window_size = 8;
obsPointsIdx = [1:5];
% obsPointsIdx = [1:5 numSamplesPerEpisode-window_size-1 numSamplesPerEpisode-window_size];
% obsPointsIdx = 1:10;
obsPointsIdx = 1:35;
process_noise = .1;
Filter.test.setup.QuadLinkSampler;
obs_noise = 1e-3;
Filter.test.setup.NoisePreprocessor;
window_prepro_input = {'endEffPositionsNoisy', 'endEffPositions'};
window_size = {8, 4};
Filter.test.setup.WindowPreprocessor;
num_features = 2*window_size{1};
num_obs_features = 2;
state_bandwidth_factor = 1;
obs_bandwidth_factor = .5;   
refset_learner_type = 'greedy';
kappa = exp(-9);
lambdaO = exp(-12);
lambdaT = exp(-12);

settings.setProperty('reducedKRS_parentReferenceSetIndicator','obsKRSIndicator');
settings.setProperty('obsKRS_parentReferenceSetIndicator','stateKRSIndicator');

state_kernel_type = 'ScaledBandwidthExponentialQuadraticKernel';
obs_kernel_type = 'ScaledBandwidthExponentialQuadraticKernel';

% output_data_name = {'endEffPositionsNoisy', 'states'};
output_data_name = {'endEffPositionsNoisy'};
observationIdx = 1:2;
window_prediction = true;
current_data_pipe = {'endEffPositionsNoisyWindows'};

Filter.test.setup.GkkfLearner;

dataManager.finalizeDataManager();
% 
% gkkfLearner.filter.lambdaI = exp(-5);

gkkfLearner.addDataPreprocessor(noisePrepro);
gkkfLearner.addDataPreprocessor(windowsPrepro);

settings.setProperty('GKKF_CMAES_optimization_groundtruthName','endEffPositions');
settings.setProperty('GKKF_CMAES_optimization_validityDataEntry','endEffPositionsNoisyWindowsValid');
settings.setProperty('GKKF_CMAES_optimization_observationIndex',observationIdx);
settings.setProperty('GKKF_CMAES_optimization_testMethod','filter');
settings.setProperty('GKKF_CMAES_optimization_internalObjective','mse');
% settings.setProperty('gkkfOptimizer_inputDataEntry','thetaWindows');%feature_name);
settings.setProperty('HyperParametersOptimizerGKKF_CMAES_optimization','ConstrainedCMAES');
settings.setProperty('GKKF_CMAES_optimization_initUpperParamLogBounds', []);
settings.setProperty('GKKF_CMAES_optimization_initLowerParamLogBounds', [-10]);
settings.setProperty('GKKF_CMAES_optimization_initUpperParamLogBoundsIdx', []);
settings.setProperty('GKKF_CMAES_optimization_initLowerParamLogBoundsIdx', 'end');
% settings.setProperty('ParameterMapGKKF_CMAES_optimization',[true false(1,14) true(1,3)]);
settings.setProperty('CMAOptimizerInitialRangeGKKF_CMAES_optimization', 0.05);
settings.setProperty('maxNumOptiIterationsGKKF_CMAES_optimization', 20);
settings.setProperty('GKKF_CMAES_optimization_trainEpisodesRatio',.97);

optimizer = Filter.Learner.GeneralizedKernelKalmanFilterOptimizer(dataManager, gkkfLearner);

dataManager.finalizeDataManager();

% obtain first data object for learning
data = dataManager.getDataObject([numEpisodes,numSamplesPerEpisode]);
trainData = dataManager.getDataObject([numEpisodes,numSamplesPerEpisode]);

%sampler.numSamples = 1000;
rng(1);
fprintf('sampling data\n');
sampler.createSamples(data);
sampler.createSamples(trainData);

fprintf('preprocessing data\n');
gkkfLearner.preprocessData(data);
gkkfLearner.preprocessData(trainData);

gkkfLearner.updateModel(trainData);

obsPoints = false(numSamplesPerEpisode,1);
obsPoints(obsPointsIdx) = true;
data.setDataEntry('obsPoints',repmat(obsPoints,numEpisodes,1));
fprintf('starting optimization\n');
optimizer.processTrainingData(data);
optimizer.initializeParameters(data);
optimizer.updateModel(data);

%%
% window_size = window_size{1}
optimizer.hyperParameterObject.filter.outputFullCov = true;
for i = 20:20
    i
    figure(1);
    clf;
    hold on;
    [smoothedMu, smoothedVar] = optimizer.hyperParameterObject.filter.callDataFunctionOutput('filterData', data, i, 1:numSamplesPerEpisode-window_size);
%     [filteredMu, filteredVar] = optimizer.hyperParameterObject.filter.callDataFunctionOutput('filterData', data, i, 1:numSamplesPerEpisode-window_size);
    dataStruct = data.getDataStructure();
    plot(dataStruct.steps(i).endEffPositions(1:numSamplesPerEpisode-window_size,1),dataStruct.steps(i).endEffPositions(1:numSamplesPerEpisode-window_size,2),'b')
    plot(dataStruct.steps(i).endEffPositionsNoisy(1:numSamplesPerEpisode-window_size,1),dataStruct.steps(i).endEffPositions(1:numSamplesPerEpisode-window_size,2),'g')
    plot(dataStruct.steps(i).endEffPositions(obsPointsIdx,1),dataStruct.steps(i).endEffPositions(obsPointsIdx,2),'+r');
%     Plotter.shadedErrorBar([],dataStruct.steps(i).smoothedMu(:,1),2*sqrt(dataStruct.steps(i).smoothedVar(:,1)),'-k',1);
%     for j = 1:1:numSamplesPerEpisode-window_size
%         Plotter.Gaussianplot.plotgauss2d(smoothedMu(j,observationIdx)',squeeze(smoothedVar(j,observationIdx,observationIdx)),'k');
%     end
    for j = 1:1:numSamplesPerEpisode-window_size
        Plotter.Gaussianplot.plotgauss2d(filteredMu(j,observationIdx)',squeeze(filteredVar(j,observationIdx,observationIdx)),'b');
    end
%     plot(smoothedMu(:,1),smoothedMu(:,2),'k');
    plot(filteredMu(:,1),filteredMu(:,2),'b');
    plot(filteredMu(obsPointsIdx,1),filteredMu(obsPointsIdx,2),'+b');
%     plot(dataStruct.steps(i).states(:,1),':');
    pause
end