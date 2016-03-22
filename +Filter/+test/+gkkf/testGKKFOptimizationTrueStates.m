close all;
Common.clearClasses
clear variables;

obsPointsIdx = [1:30];
process_noise = 1;
numEpisodes = 400;
window_size = 1;

Filter.test.setup.PendulumSampler;

random_event_prepro_input = {'theta'};
eventProbability = .25;
Filter.test.setup.RandomEventPreprocessor;
Filter.test.setup.NoisePreprocessor;
Filter.test.setup.WindowPreprocessor;
windowsPrepro1 = windowsPrepro;

% feature_name = window_prepro_output{1};
feature_name = 'states';
num_features = 2;
obs_feature_name = 'thetaNoisyNoisy';
output_data_name = 'theta';
valid_data_name = [window_prepro_output{1} 'Valid'];
% num_features = window_size;
% num_obs_features = 1;
refset_learner_type = 'greedy';
cond_operator_type = 'reg';
kappa = exp(-5);
lambdaT = exp(-13);
lambdaO = exp(-13);

% state_kernel_type = 'CauchyKernel';
obs_kernel_type = 'CauchyKernel';

kernel_size = 10000;
red_kernel_size = 50;

% num_obs_features = 4;
% obs_feature_name = 'thetaNoisyWindows';
Filter.test.setup.GkkfLearner;

settings.setProperty('GKKF_CMAES_optimization_groundtruthName','theta');
settings.setProperty('GKKF_CMAES_optimization_validityDataEntry','');
settings.setProperty('GKKF_CMAES_optimization_observationIndex',1);
% settings.setProperty('ParameterMapGKKF_CMAES_optimization',[true true true true false true false false]);
settings.setProperty('ParameterMapGKKF_CMAES_optimization',[false(1,3) false(1,2) false]);
settings.setProperty('CMAOptimizerInitialRangeGKKF_CMAES_optimization', 0.05);
settings.setProperty('maxNumOptiIterationsGKKF_CMAES_optimization', 1);

% settings.setProperty('HyperParametersOptimizerGKKF_CMAES_optimization','ConstrainedCMAES');
% settings.setProperty('GKKF_CMAES_optimization_initLowerParamLogBounds',[-12 -12]);
% settings.setProperty('GKKF_CMAES_optimization_initLowerParamLogBoundsIdx','end-1:end');

dataManager.addDataEntry('steps.obsPoints',1);

gkkfLearner.addDataPreprocessor(eventPrepro);
gkkfLearner.addDataPreprocessor(noisePrepro);
gkkfLearner.addDataPreprocessor(windowsPrepro1);

optimizer = Filter.Learner.GeneralizedKernelKalmanFilterOptimizer(dataManager, gkkfLearner);

%%
% ekfDataManager = dataManager.copy();

fprintf('setting up ekf\n');

ekf = Filter.ExtendedKalmanFilter(dataManager,environment,2,1);
ekf.setObservationModelWeightsBiasAndCov([1 0],0,obs_noise);
ekf.initFiltering({'thetaNoisyNoisy', 'obsPoints'}, {'ekfFilteredMu', 'ekfFilteredVar'}, {2});

%%
fprintf('setting up ukf\n');

ukf = Filter.UnscentedKalmanFilter(dataManager,environment,2,1);
ukf.setObservationModelWeightsBiasAndCov([1 0],0,obs_noise);
ukf.initFiltering({'thetaNoisyNoisy', 'obsPoints'}, {'ukfFilteredMu', 'ukfFilteredVar'}, {2});
ukf.alphaSquared = 1e-6;
ukf.kappa = 0;
ukf.beta = 2;

%%
% fprintf('setting up mcf\n');
% 
% monteCarloFilter = Filter.MonteCarloFilter(dataManager,1,1);
% monteCarloFilter.initFiltering({'thetaNoisyNoisy','obsPoints'},{'mcFilteredMu','mcFilteredVar'},{1});
% monteCarloFilter.preprocessors = {eventPrepro noisePrepro};
% monteCarloFilter.sampleShitloadOfData(sampler);


%%

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
gkkfLearner.preprocessData(data);

gkkfLearner.updateModel(data);
ekf.callDataFunction('initializeMeanAndCov',data,:,1);
ukf.callDataFunction('initializeMeanAndCov',data,:,1);

% pcaFeatureLearner.updateModel(data);

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
gkkfLearner.preprocessData(testData);
testData.setDataEntry('obsPoints',repmat(obsPoints,numEpisodes,1));

%%

gkkfLearner.filter.callDataFunction('filterData', testData, 1:20);
ekf.callDataFunction('filterData',testData,1:20);
ukf.callDataFunction('filterData',testData,1:20);
% monteCarloFilter.callDataFunction('filterData',testData,1:20);

dataStruct = testData.getDataStructure();

%%
for i = 1:20
%     i = 1;
%     optimizer.hyperParameterObject.filter.initialMean = optimizer.hyperParameterObject.filter.getEmbeddings(testData.getDataEntry(feature_name,i,1));

    %
    hold off;
    Plotter.shadedErrorBar([],dataStruct.steps(i).filteredMu(:,1),2*sqrt(dataStruct.steps(i).filteredVar(:,1)),'-k',1);
    hold on;
%     Plotter.shadedErrorBar([],dataStruct.steps(i).ekfFilteredMu(:,1),2*sqrt(dataStruct.steps(i).ekfFilteredVar(:,1)),'-r',1);
    Plotter.shadedErrorBar([],dataStruct.steps(i).ukfFilteredMu(:,1),2*sqrt(dataStruct.steps(i).ukfFilteredVar(:,1)),'-g',1);
%     Plotter.shadedErrorBar([],dataStruct.steps(i).mcFilteredMu(:,1),2*sqrt(dataStruct.steps(i).mcFilteredVar(:,1)),'-m',1);
    %plot(testDataStruct.steps(1).filteredMu);
    plot(dataStruct.steps(i).thetaNoisyNoisy(:,1))
    plot(dataStruct.steps(i).states(:,1),':');
    pause
end