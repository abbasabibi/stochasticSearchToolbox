Common.clearClasses
clear variables;
close all;


numEpisodes = 1000;

% numObservedSamples = 5;
kernel_size = 5000;
% obs_kernel_size = 300;
red_kernel_size = 500;
cond_operator_type = 'reg';
numSamplesPerEpisode = 23;


% window_prediction = true;
window_size = 5;
obsPointsIdx = 1:numSamplesPerEpisode-window_size;
process_noise = .1;
Filter.test.setup.DoublePendulumSampler;
obs_noise = 1e-4;
Filter.test.setup.NoisePreprocessor;
Filter.test.setup.WindowPreprocessor;   
num_features = 2*window_size;
num_obs_features = 2;
state_bandwidth_factor = 1;
obs_bandwidth_factor = 1;   
refset_learner_type = 'greedy';
kappa = exp(-8);
lambdaO = exp(-12);
lambdaT = exp(-12);

settings.setProperty('reducedKRS_parentReferenceSetIndicator','obsKRSIndicator');
settings.setProperty('obsKRS_parentReferenceSetIndicator','stateKRSIndicator');

state_kernel_type = 'ScaledBandwidthExponentialQuadraticKernel';
obs_kernel_type = 'ScaledBandwidthExponentialQuadraticKernel';

Smoother.test.setup.GkkfLearner;

dataManager.finalizeDataManager();

gkkfLearner.addDataPreprocessor(noisePrepro);
gkkfLearner.addDataPreprocessor(windowsPrepro);

settings.setProperty('GKKF_CMAES_optimization_groundtruthName','endEffPositions');
settings.setProperty('GKKF_CMAES_optimization_validityDataEntry','endEffPositionsNoisyWindowsValid');
settings.setProperty('GKKF_CMAES_optimization_observationIndex',1:2);
settings.setProperty('GKKF_CMAES_optimization_testMethod','smooth');
settings.setProperty('GKKF_CMAES_optimization_internalObjective','rmse');
% settings.setProperty('gkkfOptimizer_inputDataEntry','thetaWindows');%feature_name);
settings.setProperty('HyperParametersOptimizerGKKF_CMAES_optimization','ConstrainedCMAES');
settings.setProperty('GKKF_CMAES_optimization_initUpperParamLogBounds', []);
settings.setProperty('GKKF_CMAES_optimization_initLowerParamLogBounds', [-9.5]);
settings.setProperty('GKKF_CMAES_optimization_initUpperParamLogBoundsIdx', []);
settings.setProperty('GKKF_CMAES_optimization_initLowerParamLogBoundsIdx', 'end');
% % settings.setProperty('ParameterMapGKKF_CMAES_optimization',[true false(1,16) true(1,1)]);
settings.setProperty('CMAOptimizerInitialRangeGKKF_CMAES_optimization', 0.05);
settings.setProperty('maxNumOptiIterationsGKKF_CMAES_optimization', 0);

optimizer = Smoother.Learner.GeneralizedKernelKalmanSmootherOptimizer(dataManager, gkkfLearner);

dataManager.finalizeDataManager();

% obtain first data object for learning
data = dataManager.getDataObject([numEpisodes,numSamplesPerEpisode]);

%sampler.numSamples = 1000;
rng(1);
fprintf('sampling data\n');
sampler.createSamples(data);

fprintf('preprocessing data\n');
gkkfLearner.preprocessData(data);

% pcaFeatureLearner.updateModel(data);

obsPoints = false(numSamplesPerEpisode,1);
obsPoints(obsPointsIdx) = true;
data.setDataEntry('obsPoints',repmat(obsPoints,numEpisodes,1));
fprintf('starting optimization\n');
optimizer.processTrainingData(data);
optimizer.initializeParameters(data);
optimizer.updateModel(data);
% 0.0000    0.5778    0.2580    0.6207    0.3225    0.6502    0.3902    0.6710    0.4804    0.5408    0.2210    0.0000    0.0000    0.0010
% 0.0000    0.5591    0.2766    0.5890    0.3575    0.6207    0.4500    0.6480    0.5404    0.5415    0.2523    0.0000    0.0000    0.0010
%%
optimizer.hyperParameterObject.filter.outputFullCov = true;
for i = 1:20
%     i = 1;
    figure(1);
    clf;
    hold on;
    [smoothedMu, smoothedVar] = optimizer.hyperParameterObject.filter.callDataFunctionOutput('smoothData', data, i, 1:numSamplesPerEpisode-window_size);
    dataStruct = data.getDataStructure();
    plot(dataStruct.steps(i).endEffPositions(1:numSamplesPerEpisode-window_size,1),dataStruct.steps(i).endEffPositions(1:numSamplesPerEpisode-window_size,2))
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