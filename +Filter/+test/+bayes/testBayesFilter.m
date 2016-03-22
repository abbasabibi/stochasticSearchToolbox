Common.clearClasses
clear variables;
close all;

obsPointsIdx = [1:30];
process_noise = 1;
numEpisodes = 200;
window_size = 1;

% Filter.test.setup.RandomEventPendulumSampler;
Filter.test.setup.PendulumSampler;

random_event_prepro_input = {'theta'};
eventProbability = 0.25;
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
kappa = exp(-6);
lambdaT = exp(-1);
lambdaO = exp(-6);

% kernel_size = 50;
kernel_size = 500;
red_kernel_size = 100;
window_prediction = false;

state_bandwidth_factor = 1;
obs_bandwidth_factor = 1;

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
% settings.setProperty('ParameterMapGKKF_CMAES_optimization',[false false false false true true true true]);
settings.setProperty('ParameterMapGKKF_CMAES_optimization',[false(1,3) true(1,3)]);
settings.setProperty('CMAOptimizerInitialRangeGKKF_CMAES_optimization', 0.05);
settings.setProperty('maxNumOptiIterationsGKKF_CMAES_optimization', 20);

dataManager.addDataEntry('steps.obsPoints',1);

kbfLearner.addDataPreprocessor(eventPrepro);
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

% pcaFeatureLearner.updateModel(data);

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
% 
% kbfLearner = optimizer.hyperParameterObject;
% kbfLearner.updateModel(data);

% %%
% i = 30;
% Y = testData.getDataEntry('thetaNoisyWindows',i);
% Yw = testData.getDataEntry('thetaNoisyWindows',i);
% valid = testData.getDataEntry('thetaNoisyWindowsValid',i);
% Y = Y(logical(valid),:);
% Yw = Yw(logical(valid),:);
% 
% %%
% m = cell(1,30);
% mt = cell(1,30);
% Y_out = cell(1,30);
% Yt_out = cell(1,30);
% 
% m{1} = (kbfLearner.filter.K11 + kbfLearner.transitionModelLearner.lambdaT *eye(kernel_size)) \ kbfLearner.filter.getKernelVectors1(Y);
% mt{1} = kbfLearner.filter.getEmbeddings(Y);
% 
% for t = 2:30
%     Y_out{t} = kbfLearner.filter.outputTransformation(m{t-1});
%     Yt_out{t} = kbfLearner.filter.outputTransformation(mt{t-1});
%     m{t} = (kbfLearner.filter.K11 + kbfLearner.transitionModelLearner.lambdaT *eye(kernel_size)) \ kbfLearner.filter.K12 * m{t-1};
%     mt{t} = kbfLearner.filter.transition(m{t-1});
%     hold off
%     plot(t:length(Y_out{t})+t-1,Y_out{t}(1,:)'); hold on; plot(t:length(Yt_out{t})+t-1,Yt_out{t}(1,:)','k'); plot(Yw(:,obs_ind),'r');
%     pause
% end
%%
% ekfDataManager = dataManager.copy();
% 
% ekf = Filter.ExtendedKalmanFilter(ekfDataManager,environment,2,1);
% ekf.setObservationModelWeightsBiasAndCov([1 0],0,obs_noise);
% ekf.initFiltering({'thetaNoisy', 'obsPoints'}, {'ekfFilteredMu', 'ekfFilteredVar'}, {2});
% 
% ekf.callDataFunction('initializeMeanAndCov',data,:,1);

%%
% ukf = Filter.UnscentedKalmanFilter(dataManager,environment,2,1);
% ukf.setObservationModelWeightsBiasAndCov([1 0],0,obs_noise);
% ukf.initFiltering({'thetaNoisy', 'obsPoints'}, {'ukfFilteredMu', 'ukfFilteredVar'}, {2});
% ukf.alphaSquared = 1e-6;
% ukf.kappa = 0;
% ukf.beta = 2;
% 
% ukf.callDataFunction('initializeMeanAndCov',data,:,1);

%%

% monteCarloFilter = Filter.MonteCarloFilter(dataManager,1,1);
% monteCarloFilter.initFiltering({'theta','obsPoints'},{'filteredMu','filteredVar'},{1});
% monteCarloFilter.sampleShitloadOfData(sampler);

%%

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
    plot(dataStruct.steps(i).filteredMu(:,1),'-k');
%     Plotter.shadedErrorBar([],dataStruct.steps(i).filteredMu(:,1),2*sqrt(dataStruct.steps(i).filteredVar(:,1)),'-k',1);
    hold on;
%     Plotter.shadedErrorBar([],ekfMu(:,1),2*sqrt(ekfVar(:,1)),'-r',1);
%     Plotter.shadedErrorBar([],ukfMu(:,1),2*sqrt(ukfVar(:,1)),'-g',1);
%     Plotter.shadedErrorBar([],mcMu(:,1),2*sqrt(mcVar(:,1)),'-m',1);
    %plot(testDataStruct.steps(1).filteredMu);
    plot(dataStruct.steps(i).thetaNoisyNoisy(:,1))
    plot(dataStruct.steps(i).states(:,1),':');
    pause
end