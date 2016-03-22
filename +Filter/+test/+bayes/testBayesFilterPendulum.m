close all;
Common.clearClasses
clear variables;

numSamplesPerEpisode = 30;

% obsPointsIdx = [1:5 15];
obsPointsIdx = 1:numSamplesPerEpisode;
process_noise = 1;
numEpisodes = 100;
window_size = 4;
% obs_ind = 3;%window_size;

Filter.test.setup.PendulumSampler;
obs_noise = 1e-2;
Filter.test.setup.NoisePreprocessor;
Filter.test.setup.WindowPreprocessor;
windowsPrepro1 = windowsPrepro;


% feature_name = window_prepro_output{1};
feature_name = 'thetaNoisyWindows';
% num_features = 3;
obs_feature_name = 'thetaNoisy';
% num_obs_features = 2;
output_data_name = 'thetaNoisy';
% valid_data_name = [window_prepro_output{1} 'Valid'];
% num_features = window_size;
% num_obs_features = 1;
refset_learner_type = 'greedy';
cond_operator_type = 'reg';
kappa = exp(-11);
lambdaT = exp(-6);
lambdaO = exp(-6);

% kernel_size = 50;
kernel_size = 100;
red_kernel_size = 100;
window_prediction = false;

state_bandwidth_factor = 6;
obs_bandwidth_factor = 4.3;

state_kernel_type = 'ScaledBandwidthExponentialQuadraticKernel';
obs_kernel_type = 'ScaledBandwidthExponentialQuadraticKernel';

% num_obs_features = 4;
% obs_feature_name = 'thetaNoisyWindows';
Filter.test.setup.BayesFilter;

% window_prepro_name = 'gtWindowPrepro';
% window_prepro_input = {'theta'};
% window_prepro_output = {'thetaWindows'};
% Filter.test.setup.WindowPreprocessor;
% windowsPrepro2 = windowsPrepro;

settings.setProperty('GKKF_CMAES_optimization_groundtruthName','theta');
settings.setProperty('GKKF_CMAES_optimization_validityDataEntry','');
settings.setProperty('GKKF_CMAES_optimization_observationIndex',1);
settings.setProperty('GKKF_CMAES_optimization_internalObjective','llh');
% settings.setProperty('ParameterMapGKKF_CMAES_optimization',[false false false false true true true true]);
% settings.setProperty('ParameterMapGKKF_CMAES_optimization',[false(1,3) true(1,3)]);
settings.setProperty('CMAOptimizerInitialRangeGKKF_CMAES_optimization', 0.05);
settings.setProperty('maxNumOptiIterationsGKKF_CMAES_optimization', 20);

dataManager.addDataEntry('steps.obsPoints',1);

kbfLearner.addDataPreprocessor(noisePrepro);
kbfLearner.addDataPreprocessor(windowsPrepro1);
% kbfLearner.addDataPreprocessor(windowsPrepro2);

optimizer = Filter.Learner.GeneralizedKernelKalmanFilterOptimizer(dataManager, kbfLearner);

dataManager.finalizeDataManager();

% obtain first data object for learning
data = dataManager.getDataObject([numEpisodes,numSamplesPerEpisode]);

%sampler.numSamples = 1000;
rng(1);
fprintf('sampling data\n');
sampler.createSamples(data);

obsPoints = false(numSamplesPerEpisode,1);
obsPoints(obsPointsIdx) = true;
data.setDataEntry('obsPoints',repmat(obsPoints,numEpisodes,1));

fprintf('preprocessing data\n');
kbfLearner.preprocessData(data);

% kbfLearner.updateModel(data);

fprintf('starting optimization\n');
optimizer.processTrainingData(data);
optimizer.initializeParameters(data);
optimizer.updateModel(data);

% obtain second data object for testing
testData = dataManager.getDataObject([100,30]);

rng(3);
fprintf('sampling test data\n');
sampler.createSamples(testData);

fprintf('preprocessing test data\n');
kbfLearner.preprocessData(testData);
testData.setDataEntry('obsPoints',repmat(obsPoints,numEpisodes,1));


%%
% optimizer.hyperParameterObject.filter.outputFullCov = true;
% for i = 1:20
% %     i = 1;
%     figure(1);
%     clf;
%     hold on;
%     [smoothedMu, smoothedVar] = optimizer.hyperParameterObject.filter.callDataFunctionOutput('filterData', data, i);
%     dataStruct = data.getDataStructure();
%     plot(dataStruct.steps(i).endEffPositions(:,1),dataStruct.steps(i).endEffPositions(:,2),'b')
%     plot(dataStruct.steps(i).endEffPositionsNoisy(:,1),dataStruct.steps(i).endEffPositions(:,2),'g')
% %     plot(dataStruct.steps(i).endEffPositions(obsPointsIdx,1),dataStruct.steps(i).endEffPositions(obsPointsIdx,2),'+r');
% %     Plotter.shadedErrorBar([],dataStruct.steps(i).smoothedMu(:,1),2*sqrt(dataStruct.steps(i).smoothedVar(:,1)),'-k',1);
%     for j = 1:1:numSamplesPerEpisode
%         Plotter.Gaussianplot.plotgauss2d(smoothedMu(j,1:2)',squeeze(smoothedVar(j,1:2,1:2)),'k');
%     end
%     plot(smoothedMu(:,1),smoothedMu(:,2),'k');
% %     plot(smoothedMu(obsPointsIdx,1),smoothedMu(obsPointsIdx,2),'+b');
% %     plot(dataStruct.steps(i).states(:,1),':');
%     pause
% end

for i = 1:20
%     i = 1;
%     kbfLearner.filter.initialMean = optimizer.hyperParameterObject.filter.getEmbeddings(data.getDataEntry(feature_name,i,1));
    kbfLearner.filter.callDataFunction('filterData', testData, i);
%     [ekfMu, ekfVar] = ekf.callDataFunctionOutput('filterData',data,i);
%     [ukfMu, ukfVar] = ukf.callDataFunctionOutput('filterData',data,i);
%     [mcMu, mcVar] = monteCarloFilter.callDataFunctionOutput('filterData',data,i);
    %
    dataStruct = testData.getDataStructure();
    hold off;
%     plot(dataStruct.steps(i).filteredMu(:,1),'-k');
    Plotter.shadedErrorBar([],dataStruct.steps(i).filteredMu(:,1),2*sqrt(dataStruct.steps(i).filteredVar(:,1)),'-k',1);
    hold on;
%     Plotter.shadedErrorBar([],ekfMu(:,1),2*sqrt(ekfVar(:,1)),'-r',1);
%     Plotter.shadedErrorBar([],ukfMu(:,1),2*sqrt(ukfVar(:,1)),'-g',1);
%     Plotter.shadedErrorBar([],mcMu(:,1),2*sqrt(mcVar(:,1)),'-m',1);
    %plot(testDataStruct.steps(1).filteredMu);
    plot(dataStruct.steps(i).thetaNoisy(:,1))
    plot(dataStruct.steps(i).states(:,1),':');
    pause
end