Common.clearClasses
clear variables;
close all;


numEpisodes = 1000;

% numObservedSamples = 5;
kernel_size = 5000;
% obs_kernel_size = 300;
red_kernel_size = 1000;
cond_operator_type = 'reg';
numSamplesPerEpisode = 43;


% window_prediction = true;
window_size = 1;
obsPointsIdx = [1:5 numSamplesPerEpisode-window_size-1 numSamplesPerEpisode-window_size];
process_noise = .1;
Filter.test.setup.QuadLinkSampler;
obs_noise = 1e-3;
Filter.test.setup.NoisePreprocessor;
num_obs_features = 2;
state_bandwidth_factor = 2;
obs_bandwidth_factor = .5;
refset_learner_type = 'greedy';
kappa = exp(-6);
lambdaO = exp(-10);
lambdaT = exp(-10);

settings.setProperty('reducedKRS_parentReferenceSetIndicator','obsKRSIndicator');
settings.setProperty('obsKRS_parentReferenceSetIndicator','stateKRSIndicator');

state_kernel_type = 'ScaledBandwidthExponentialQuadraticKernel';
obs_kernel_type = 'ScaledBandwidthExponentialQuadraticKernel';

current_data_pipe = {'states'};
num_features = 8;
output_data_name = {'endEffPositions'};
obs_feature_name = 'endEffPositions';

Smoother.test.setup.GkkfLearner;

dataManager.finalizeDataManager();

gkkfLearner.filter.lambdaI = exp(-6);

gkkfLearner.addDataPreprocessor(noisePrepro);
% gkkfLearner.addDataPreprocessor(windowsPrepro);

settings.setProperty('GKKF_CMAES_optimization_groundtruthName','endEffPositions');
settings.setProperty('GKKF_CMAES_optimization_validityDataEntry','');
settings.setProperty('GKKF_CMAES_optimization_observationIndex',1:2);
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
settings.setProperty('maxNumOptiIterationsGKKF_CMAES_optimization', 25);

optimizer = Filter.Learner.GeneralizedKernelKalmanFilterOptimizer(dataManager, gkkfLearner);

dataManager.finalizeDataManager();

% obtain first data object for learning
data = dataManager.getDataObject([numEpisodes,numSamplesPerEpisode]);

%sampler.numSamples = 1000;
rng(1);
fprintf('sampling data\n');
sampler.createSamples(data);

fprintf('preprocessing data\n');
gkkfLearner.preprocessData(data);

% gkkfLearner.updateModel(data);

obsPoints = false(numSamplesPerEpisode,1);
obsPoints(obsPointsIdx) = true;
data.setDataEntry('obsPoints',repmat(obsPoints,numEpisodes,1));
fprintf('starting optimization\n');
optimizer.processTrainingData(data);
optimizer.initializeParameters(data);
optimizer.updateModel(data);

%%
optimizer.hyperParameterObject.filter.outputFullCov = true;
for i = 1:20
%     i = 1;
    figure(1);
    clf;
    hold on;
    [smoothedMu, smoothedVar] = optimizer.hyperParameterObject.filter.callDataFunctionOutput('smoothData', data, i, 1:numSamplesPerEpisode-window_size);
    dataStruct = data.getDataStructure();
    plot(dataStruct.steps(i).endEffPositions(1:numSamplesPerEpisode-window_size,1),dataStruct.steps(i).endEffPositions(1:numSamplesPerEpisode-window_size,2),'b')
    plot(dataStruct.steps(i).endEffPositionsNoisy(1:numSamplesPerEpisode-window_size,1),dataStruct.steps(i).endEffPositions(1:numSamplesPerEpisode-window_size,2),'g')
    plot(dataStruct.steps(i).endEffPositions(obsPointsIdx,1),dataStruct.steps(i).endEffPositions(obsPointsIdx,2),'+r');
%     Plotter.shadedErrorBar([],dataStruct.steps(i).smoothedMu(:,1),2*sqrt(dataStruct.steps(i).smoothedVar(:,1)),'-k',1);
    for j = 1:1:numSamplesPerEpisode-window_size
        Plotter.Gaussianplot.plotgauss2d(smoothedMu(j,:)',squeeze(smoothedVar(j,:,:)),'k');
    end
    plot(smoothedMu(:,1),smoothedMu(:,2),'k');
    plot(smoothedMu(obsPointsIdx,1),smoothedMu(obsPointsIdx,2),'+b');
%     plot(dataStruct.steps(i).states(:,1),':');
    pause
end