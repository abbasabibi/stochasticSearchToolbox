close all;
Common.clearClasses
clear variables;

% obsPointsIdx = [1:5,20];
obsPointsIdx = 1:30;
numSamplesPerEpisode = 30;
numEpisodes = 15;
% numObservedSamples = 5;
kernel_size = 500;
% obs_kernel_size = 300;
red_kernel_size = 500;

%obs_noise = 
% feature_name = 'thetaNoisyWindowsPcaFeatures';
feature_name = 'thetaNoisyWindows';

process_noise = 1;
Filter.test.setup.PendulumSampler;
obs_noise = 1e-2;
Filter.test.setup.NoisePreprocessor;
Filter.test.setup.WindowPreprocessor;
% Filter.test.setup.PcaFeatureGenerators;

lambdaT = exp(-4);
lambdaO = exp(-12);
kappa = exp(-7);

state_kernel_type = 'ScaledBandwidthExponentialQuadraticKernel';
obs_kernel_type = 'ScaledBandwidthExponentialQuadraticKernel';

state_bandwidth_factor = 2.5;
obs_bandwidth_factor = 3;

cond_operator_type = 'std';

Filter.test.setup.GkkfLearner;

settings.setProperty('GKKF_CMAES_optimization_groundtruthName','theta');
settings.setProperty('GKKF_CMAES_optimization_validityDataEntry','thetaNoisyWindowsValid');
settings.setProperty('GKKF_CMAES_optimization_observationIndex',1);
settings.setProperty('GKKF_CMAES_optimization_internalObjective','mse');
% settings.setProperty('ParameterMapGKKF_CMAES_optimization',[true true false false false]);
settings.setProperty('CMAOptimizerInitialRangeGKKF_CMAES_optimization', 0.05);
settings.setProperty('maxNumOptiIterationsGKKF_CMAES_optimization', 25);

dataManager.addDataEntry('steps.obsPoints',1);

gkkfLearner.addDataPreprocessor(noisePrepro);
gkkfLearner.addDataPreprocessor(windowsPrepro);

optimizer = Filter.Learner.GeneralizedKernelKalmanFilterOptimizer(dataManager, gkkfLearner);

dataManager.finalizeDataManager();

% obtain first data object for learning
data = dataManager.getDataObject([100,30]);

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
for i = 1:20
%     i = 1;
    optimizer.hyperParameterObject.filter.callDataFunction('filterData', data, i);

    %
    dataStruct = data.getDataStructure();
    hold off;
    Plotter.shadedErrorBar([],dataStruct.steps(i).filteredMu(:,1),2*sqrt(dataStruct.steps(i).filteredVar(:,1)),'-k',1);
    hold on;
    %plot(testDataStruct.steps(1).filteredMu);
    plot(dataStruct.steps(i).thetaNoisy(:,1))
    plot(dataStruct.steps(i).states(:,1),':');
    pause
end

%%
groundtruth = data.getDataEntry('theta');
filteredMu = data.getDataEntry('filteredMu');
error = groundtruth - filteredMu;
mse = sum(error(:).^2)./length(groundtruth(:));