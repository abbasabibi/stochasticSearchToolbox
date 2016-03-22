Common.clearClasses
clear variables;
close all;

obsPointsIdx = [1:30];
numEpisodes = 50;

picture_size = 10;
picture_feature_size = picture_size^2;
window_size = 3;
obs_ind = window_size;
num_pca_features = 10;
process_noise = 2;
isPeriodic = false;
eventProbability = .2;

Filter.test.setup.PendulumSampler;
settings.setProperty('PcaFeatures_normalizeEigenVectors',true);
Filter.test.setup.PendulumImages;
Filter.test.setup.PcaFeatureGenerators;
gt_picture_feature_output = picture_feature_output;
gt_pca_feature_output = pca_feature_output;
gt_pcaFeatureLearner = pcaFeatureLearner;
clear picture_feature_input picture_feature_output pca_feature_output pca_feature_input;
current_data_pipe = {'theta'};
Filter.test.setup.RandomEventPreprocessor;
Filter.test.setup.PendulumImages;
clone_pca_transform = true;
Filter.test.setup.PcaFeatureGenerators;
Filter.test.setup.WindowPreprocessor;
windowsPrepro1 = windowsPrepro;

feature_name = 'states';
% feature_name = window_prepro_output{1};
obs_feature_name = pca_feature_output{1};
% obs_feature_name = noise_prepro_output{1};
output_data_name = {gt_picture_feature_output{1} gt_pca_feature_output{1} 'theta'};
valid_data_name = [window_prepro_output{1} 'Valid'];
num_features = 2;%window_size * num_pca_features;
num_obs_features = num_pca_features;
% num_obs_features = 100;

% num_features = window_size;
% num_obs_features = 1;
refset_learner_type = 'random';
cond_operator_type = 'std';
kappa = exp(0.8);
lambdaT = exp(-10);
lambdaO = exp(-10);

kernel_size = 250;
red_kernel_size = 250;

% state_kernel_type = 'WindowedExponentialQuadraticKernel';
obs_kernel_type = 'WindowedExponentialQuadraticKernel';
% state_bandwidth_factor = 5;
obs_bandwidth_factor = 1;

settings.setProperty('stateKernel_numWindows',15);
settings.setProperty('obsKernel_numWindows',5);

% num_obs_features = 4;
% obs_feature_name = 'thetaNoisyWindows';
Filter.test.setup.BayesFilter;
kbfLearner.filter.normalization = true;

% settings.setProperty('GKKF_CMAES_optimization_monitoringIndex',1+num_pca_features+picture_feature_size);
% settings.setProperty('GKKF_CMAES_optimization_monitoringGroundtruthName','theta');
settings.setProperty('GKKF_CMAES_optimization_groundtruthName','theta');
settings.setProperty('GKKF_CMAES_optimization_validityDataEntry','');
settings.setProperty('GKKF_CMAES_optimization_observationIndex',[num_pca_features]+picture_feature_size+1);
% settings.setProperty('GKKF_CMAES_optimization_inputDataEntry',window_prepro_output{1});
settings.setProperty('ParameterMapGKKF_CMAES_optimization',[false(1,9) true(1,1)]);
% settings.setProperty('ParameterMapGKKF_CMAES_optimization',[true true true true true]);
settings.setProperty('CMAOptimizerInitialRangeGKKF_CMAES_optimization', 0.05);
settings.setProperty('maxNumOptiIterationsGKKF_CMAES_optimization', 50);
% 
settings.setProperty('HyperParametersOptimizerGKKF_CMAES_optimization','ConstrainedCMAES');
settings.setProperty('GKKF_CMAES_optimization_initLowerParamLogBounds',-15);
settings.setProperty('GKKF_CMAES_optimization_initLowerParamLogBoundsIdx','end');
settings.setProperty('GKKF_CMAES_optimization_trainEpisodesRatio',.8);

optimizer = Filter.Learner.GeneralizedKernelKalmanFilterOptimizerThetaExtraction(dataManager, kbfLearner, 'GKKF_CMAES_optimization');

dataManager.addDataEntry('steps.obsPoints',1);

kbfLearner.addDataPreprocessor(eventPrepro);
% kbfLearner.addDataPreprocessor(noisePrepro);
kbfLearner.addDataPreprocessor(windowsPrepro1);
% kbfLearner.addDataPreprocessor(windowsPrepro2);

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
gt_pcaFeatureLearner.updateModel(data);
eventPrepro.preprocessData(data);
% noisePrepro.preprocessData(data);
pcaFeatureLearner.updateModel(data);
windowsPrepro.preprocessData(data);

kbfLearner.updateModel(data);

fprintf('starting optimization\n');
% optimizer.processTrainingData(data);
% optimizer.initializeParameters(data);
% optimizer.updateModel(data);

% obtain second data object for testing
testData = dataManager.getDataObject([100,30]);

rng(3);
fprintf('sampling test data\n');
sampler.createSamples(testData);

fprintf('preprocessing test data\n');
kbfLearner.preprocessData(testData);
testData.setDataEntry('obsPoints',repmat(obsPoints,numEpisodes,1));
% 
% kbfLearner = optimizer.hyperParameterObject;
% kbfLearner.updateModel(data);

%% obtain second data object for testing
% testData = dataManager.getDataObject([100,40]);
% 
% rng(2);
% fprintf('sampling test data\n');
% sampler.createSamples(testData);
% eventPrepro.preprocessData(data);
% % noisePrepro.preprocessData(testData);
% windowsPrepro.preprocessData(testData);
% 
% obsPoints = false(numSamplesPerEpisode,1);
% obsPoints(obsPointsIdx) = true;
% testData.setDataEntry('obsPoints',repmat(obsPoints,numEpisodes,1));

%%
figure; 
for i = 27:40
%     i = 1;
%     optimizer.hyperParameterObject.filter.initialMean = optimizer.hyperParameterObject.filter.getEmbeddings(testData.getDataEntry(feature_name,i,1));
    kbfLearner.filter.callDataFunction('filterData', testData, i);
    %
    dataStruct = testData.getDataStructure();
    extrThetas = FeatureGenerators.PictureFeatureExtractors.extractTheta(reshape(dataStruct.steps(i).filteredMu(:,1:100)',10,10,[]),false);
    clf;
%     Plotter.shadedErrorBar([],dataStruct.steps(i).filteredMu(:,1+num_pca_features+picture_feature_size),2*sqrt(dataStruct.steps(i).filteredVar(:,1+num_pca_features+picture_feature_size)),'-k',1);
    hold on;
    %plot(testDataStruct.steps(1).filteredMu);
    plot(dataStruct.steps(i).thetaNoisy(:,1))
    plot(extrThetas,'r');
%     plot(extrThetas(:,2),'k');
    plot(dataStruct.steps(i).states(:,1),':');
    pause
end