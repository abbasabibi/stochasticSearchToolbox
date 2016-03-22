Common.clearClasses;
clear variables;
close all;

obsPointsIdx = [1:5];

numEpisodes = 100;

picture_size = 10;
picture_feature_size = picture_size^2;
window_size = 3;
obs_ind = window_size;
num_pca_features = 10;
obs_noise = 1e-4;
process_noise = 1e-2;
isPeriodic = false;

Filter.test.setup.PendulumSampler;
settings.setProperty('PcaFeatures_normalizeEigenVectors',true);
% Filter.test.setup.NoisePreprocessor;
Filter.test.setup.PendulumImages;
settings.setProperty('noisePrepro_positiveOnly',true);
Filter.test.setup.NoisePreprocessor;
Filter.test.setup.PcaFeatureGenerators;
Filter.test.setup.WindowPreprocessor;

% pfe_feature_input = 'filteredMu';
% pfe_input_index = 1:100;
% Filter.test.setup.PictureFeatureExtractionFeatureGenerators;


% feature_name = current_data_pipe{1};
% obs_feature_name = picture_feature_output{1};
% output_data_name = picture_feature_output{1};
% valid_data_name = [window_prepro_output{1} 'Valid'];
% num_features = num_pca_features;
% num_obs_features = picture_size^2;

feature_name = window_prepro_output{1};
obs_feature_name = pca_feature_output{1};
% obs_feature_name = noise_prepro_output{1};
output_data_name = {picture_feature_output{1} pca_feature_output{1} 'theta'};
valid_data_name = [window_prepro_output{1} 'Valid'];
num_features = window_size * num_pca_features;
num_obs_features = num_pca_features;
% num_obs_features = 100;

refset_learner_type = 'greedy';
cond_operator_type = 'reg';
kappa = exp(-6);

kernel_size = 5000;
red_kernel_size = 400;
    
% 
state_kernel_type = 'WindowedExponentialQuadraticKernel';
obs_kernel_type = 'WindowedExponentialQuadraticKernel';
% state_kernel_type = 'ScaledBandwidthExponentialQuadraticKernel';
% obs_kernel_type = 'ScaledBandwidthExponentialQuadraticKernel';
state_bandwidth_factor = 5;
% obs_bandwidth_factor = 50;
obs_bandwidth_factor = 5;

settings.setProperty('stateKernel_numWindows',15);
settings.setProperty('obsKernel_numWindows',5);
% settings.setProperty('stateKernel_imageFeatureName','thetaPicture');
% settings.setProperty('obsKernel_imageFeatureName',4);
% settings.setProperty('ExponentialQuadraticKernelUseARDobsKernel',false);


Filter.test.setup.GkkfLearner;

% settings.setProperty('GKKF_CMAES_optimization_monitoringIndex',1+num_pca_features+picture_feature_size);
% settings.setProperty('GKKF_CMAES_optimization_monitoringGroundtruthName','theta');
settings.setProperty('GKKF_CMAES_optimization_groundtruthName',pca_feature_output{1});
settings.setProperty('GKKF_CMAES_optimization_validityDataEntry','');
settings.setProperty('GKKF_CMAES_optimization_observationIndex',(1:num_pca_features)+picture_feature_size);
% settings.setProperty('GKKF_CMAES_optimization_inputDataEntry',window_prepro_output{1});
% settings.setProperty('ParameterMapGKKF_CMAES_optimization',[true(1,22) false]);
% settings.setProperty('ParameterMapGKKF_CMAES_optimization',[true true true true true]);
settings.setProperty('CMAOptimizerInitialRangeGKKF_CMAES_optimization', 0.05);
settings.setProperty('maxNumOptiIterationsGKKF_CMAES_optimization', 100);

settings.setProperty('HyperParametersOptimizerGKKF_CMAES_optimization','ConstrainedCMAES');
settings.setProperty('GKKF_CMAES_optimization_initLowerParamLogBounds',-7);
settings.setProperty('GKKF_CMAES_optimization_initLowerParamLogBoundsIdx','end');

optimizer = Filter.Learner.GeneralizedKernelKalmanFilterOptimizer(dataManager, gkkfLearner, 'GKKF_CMAES_optimization');

dataManager.finalizeDataManager();

% obtain first data object for learning
data = dataManager.getDataObject([numEpisodes,numSamplesPerEpisode]);

%sampler.numSamples = 1000;
rng(3);
fprintf('sampling data\n');
sampler.createSamples(data);

fprintf('preprocessing data\n');
noisePrepro.preprocessData(data);
pcaFeatureLearner.updateModel(data);
windowsPrepro.preprocessData(data);

obsPoints = false(numSamplesPerEpisode,1);
obsPoints(obsPointsIdx) = true;
data.setDataEntry('obsPoints',repmat(obsPoints,numEpisodes,1));

fprintf('starting optimization\n');
optimizer.processTrainingData(data);
optimizer.initializeParameters(data);
optimizer.updateModel(data);

% bestHyp = [3.331991286245717e+00     1.937930755248827e+00     1.110836573560532e+01     2.377377586967808e+00     5.161725079524397e+01     8.455788915744243e+00     2.228378289895541e+01     3.322853721004654e+01     3.313578196663847e+01     8.434152192436935e+00     1.866241774628234e+00     7.976534538651003e+00     5.132340157747562e+00     3.653429991205901e+00     1.697218374706567e+00     1.387540051082461e+00     2.303869158061414e+00     1.717926836811008e+01     1.487052478653710e+00     2.293612241756394e+00     1.938098904047189e-07     6.410352153400929e-05     1.809574888324600e-05];
% gkkfLearner.setHyperParameters(bestHyp);
% gkkfLearner.updateModel(data);
% obtain second data object for testing
% testData = dataManager.getDataObject([100,45]);
% 
% rng(2);
% fprintf('sampling test data\n');
% sampler.createSamples(testData);
% 
% fprintf('preprocessing test data\n');
% gkkfLearner.preprocessData(testData);
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

%%

% bestHyp = [3.331991286245717e+00     1.937930755248827e+00     1.110836573560532e+01     2.377377586967808e+00     5.161725079524397e+01     8.455788915744243e+00     2.228378289895541e+01   3.322853721004654e+01     3.313578196663847e+01     8.434152192436935e+00     1.866241774628234e+00     7.976534538651003e+00     5.132340157747562e+00     3.653429991205901e+00   1.697218374706567e+00     1.387540051082461e+00     2.303869158061414e+00     1.717926836811008e+01     1.487052478653710e+00     2.293612241756394e+00     1.938098904047189e-07   6.410352153400929e-05     1.809574888324600e-05];
% optimizer.hyperParameterObject.setHyperParameters(bestHyp);
% optimizer.hyperParameterObject.updateModel(data);

%%
% obtain second data object for testing
testData = dataManager.getDataObject([100,40]);

rng(2);
fprintf('sampling test data\n');
sampler.createSamples(testData);
noisePrepro.preprocessData(testData);
windowsPrepro.preprocessData(testData);

obsPoints = false(numSamplesPerEpisode,1);
obsPoints(obsPointsIdx) = true;
testData.setDataEntry('obsPoints',repmat(obsPoints,numEpisodes,1));

%%
figure; 
for i = 1:20
%     i = 1;
%     optimizer.hyperParameterObject.filter.initialMean = optimizer.hyperParameterObject.filter.getEmbeddings(testData.getDataEntry(feature_name,i,1));
    optimizer.hyperParameterObject.filter.callDataFunction('filterData', testData, i);
    %
    dataStruct = testData.getDataStructure();
    extrThetas = FeatureGenerators.PictureFeatureExtractors.extractTheta(reshape(dataStruct.steps(i).filteredMu(:,1:100)',10,10,[]),true);
    clf;
    Plotter.shadedErrorBar([],dataStruct.steps(i).filteredMu(:,1+num_pca_features+picture_feature_size),2*sqrt(dataStruct.steps(i).filteredVar(:,1+num_pca_features+picture_feature_size)),'-k',1);
    hold on;
    %plot(testDataStruct.steps(1).filteredMu);
    plot(dataStruct.steps(i).states(:,1))
    plot(extrThetas,'r');
%     plot(extrThetas(:,2),'k');
%     plot(dataStruct.steps(i).states(:,1),':');
    pause
end