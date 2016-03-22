Common.clearClasses
clear variables;
close all;

obsPointsIdx = [1:30];
process_noise = 1;
numEpisodes = 50;
window_size = 4;
obs_ind = 4;

Filter.test.setup.PendulumSampler;
Filter.test.setup.NoisePreprocessor;
window_prepro_input = {'theta'};
Filter.test.setup.WindowPreprocessor;

feature_name = window_prepro_output{1};
obs_feature_name = 'thetaNoisy';
output_data_name = 'thetaNoisy';
valid_data_name = [window_prepro_output{1} 'Valid'];
% num_features = window_size;
% num_obs_features = 1;
% refset_learner_type = 'random';
cond_operator_type = 'reg';
kappa = 1e-2;
lambdaO = 1e-2;
lambdaT = 1e-2;

kernel_size = 1000;
red_kernel_size = 400;

% num_obs_features = 4;
% obs_feature_name = 'thetaNoisyWindows';
Smoother.test.setup.GkkfLearner;

settings.setProperty('GKKF_CMAES_optimization_internalObjective','llh');
settings.setProperty('GKKF_CMAES_optimization_groundtruthName','theta');
% settings.setProperty('GKKF_CMAES_optimization_validityDataName','llh');
settings.setProperty('ParameterMapGKKF_CMAES_optimization',[true true true true true true true true true]);
settings.setProperty('CMAOptimizerInitialRangeGKKF_CMAES_optimization', 0.05);
settings.setProperty('maxNumOptiIterationsGKKF_CMAES_optimization', 100);

dataManager.addDataEntry('steps.obsPoints',1);

gkkfLearner.addDataPreprocessor(noisePrepro);
gkkfLearner.addDataPreprocessor(windowsPrepro);

optimizer = Smoother.Learner.GeneralizedKernelKalmanSmootherOptimizer(dataManager, gkkfLearner, 'GKKF_CMAES_optimization');

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

% obtain second data object for testing
testData = dataManager.getDataObject([50,30]);

rng(2);
fprintf('sampling test data\n');
sampler.createSamples(testData);

fprintf('preprocessing test data\n');
gkkfLearner.preprocessData(testData);
testData.setDataEntry('obsPoints',repmat(obsPoints,numEpisodes,1));
% 
% gkkfLearner = optimizer.hyperParameterObject;
% gkkfLearner.updateModel(data);

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
% m{1} = (gkkfLearner.filter.K11 + gkkfLearner.transitionModelLearner.lambdaT *eye(kernel_size)) \ gkkfLearner.filter.getKernelVectors1(Y);
% mt{1} = gkkfLearner.filter.getEmbeddings(Y);
% 
% for t = 2:30
%     Y_out{t} = gkkfLearner.filter.outputTransformation(m{t-1});
%     Yt_out{t} = gkkfLearner.filter.outputTransformation(mt{t-1});
%     m{t} = (gkkfLearner.filter.K11 + gkkfLearner.transitionModelLearner.lambdaT *eye(kernel_size)) \ gkkfLearner.filter.K12 * m{t-1};
%     mt{t} = gkkfLearner.filter.transition(m{t-1});
%     hold off
%     plot(t:length(Y_out{t})+t-1,Y_out{t}(1,:)'); hold on; plot(t:length(Yt_out{t})+t-1,Yt_out{t}(1,:)','k'); plot(Yw(:,obs_ind),'r');
%     pause
% end
% %%
% ekfDataManager = dataManager.copy();
% 
% ekf = Filter.ExtendedKalmanFilter(ekfDataManager,environment,2,1);
% ekf.setObservationModelWeightsBiasAndCov([1 0],0,obs_noise);
% ekf.initFiltering({'thetaNoisy', 'obsPoints'}, {'ekfFilteredMu', 'ekfFilteredVar'}, 2);
% 
% ekf.callDataFunction('initializeMeanAndCov',data,:,1);
% 
% %%
% ukf = Filter.UnscentedKalmanFilter(dataManager,environment,2,1);
% ukf.setObservationModelWeightsBiasAndCov([1 0],0,obs_noise);
% ukf.initFiltering({'thetaNoisy', 'obsPoints'}, {'ukfFilteredMu', 'ukfFilteredVar'}, 2);
% ukf.alphaSquared = 1e-6;
% ukf.kappa = 0;
% ukf.beta = 2;
% 
% ukf.callDataFunction('initializeMeanAndCov',data,:,1);
% 
%%

monteCarloSmoother = Smoother.MonteCarloSmoother(dataManager,1,1);
monteCarloSmoother.initFiltering({'theta','obsPoints'},{'filteredMu','filteredVar'},1);
monteCarloSmoother.initSmoothing({'theta','obsPoints'},{'smoothedMu','smoothedVar'},1);
monteCarloSmoother.sampleShitloadOfData(sampler);

%%

for i = 1:20
%     i = 1;
%     optimizer.hyperParameterObject.filter.initialMean = optimizer.hyperParameterObject.filter.getEmbeddings(data.getDataEntry(feature_name,i,1));
    optimizer.hyperParameterObject.filter.callDataFunction('smoothData', testData, i);
%     [ekfMu, ekfVar] = ekf.callDataFunctionOutput('filterData',data,i);
%     [ukfMu, ukfVar] = ukf.callDataFunctionOutput('filterData',data,i);
    [mcMu, mcVar] = monteCarloSmoother.callDataFunctionOutput('smoothData',testData,i);
    %
    dataStruct = testData.getDataStructure();
    hold off;
    Plotter.shadedErrorBar([],dataStruct.steps(i).smoothedMu(:,1),2*sqrt(dataStruct.steps(i).smoothedVar(:,1)),'-k',1);
    hold on;
%     Plotter.shadedErrorBar([],ekfMu(:,1),2*sqrt(ekfVar(:,1)),'-r',1);
%     Plotter.shadedErrorBar([],ukfMu(:,1),2*sqrt(ukfVar(:,1)),'-g',1);
    Plotter.shadedErrorBar([],mcMu(:,1),2*sqrt(mcVar(:,1)),'-m',1);
    %plot(testDataStruct.steps(1).filteredMu);
    plot(dataStruct.steps(i).thetaNoisy(:,1))
    plot(dataStruct.steps(i).states(:,1),':');
    pause
end