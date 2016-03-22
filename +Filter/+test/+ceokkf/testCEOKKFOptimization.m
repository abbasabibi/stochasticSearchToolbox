Common.clearClasses
clear variables;
close all;

obsPointsIndices = [1:5,20];
% % obsPointsIndices = 1:30;
kernel_size = 200;
% obs_kernel_size = 300;
window_size = 4;

%obs_noise = 
% feature_name = 'thetaNoisyWindowsPcaFeatures';
feature_name = 'thetaNoisyWindows';

numEpisodes = 100;

Filter.test.setup.PendulumSampler;
Filter.test.setup.NoisePreprocessor;
Filter.test.setup.WindowPreprocessor;
Filter.test.setup.CeokkfLearner;

settings.setProperty('ceokkfOptimizer_groundtruthName','theta');
settings.setProperty('ceokkfOptimizer_inputDataEntry',feature_name);
settings.setProperty('ceokkfOptimizer_validityDataEntry',valid_data_name);
settings.setProperty('ceokkfOptimizer_internalObjective', 'llh');
% settings.setProperty('ParameterMapGKKF_CMAES_optimization',[true true true true false true false false]);
settings.setProperty('CMAOptimizerInitialRangeCEOKKF_CMAES_optimization', 0.05);
settings.setProperty('maxNumOptiIterationsCEOKKF_CMAES_optimization', 100);

ceokkfLearner.addDataPreprocessor(noisePrepro);
ceokkfLearner.addDataPreprocessor(windowsPrepro);

optimizer = Filter.Learner.CEOKernelKalmanFilterOptimizer(dataManager, ceokkfLearner);

dataManager.finalizeDataManager();

% obtain first data object for learning
data = dataManager.getDataObject([numEpisodes,numSamplesPerEpisode]);

%sampler.numSamples = 1000;
rng(1);
fprintf('sampling data\n');
sampler.createSamples(data);

fprintf('preprocessing data\n');
ceokkfLearner.preprocessData(data);

% pcaFeatureLearner.updateModel(data);
obsPoints = false(numSamplesPerEpisode,1);
obsPoints(obsPointsIndices) = true;
data.setDataEntry('obsPoints',repmat(obsPoints,numEpisodes,1));

fprintf('starting optimization\n');
optimizer.processTrainingData(data);
optimizer.initializeParameters(data);
optimizer.updateModel(data);

% obtain second data object for testing
% testData = dataManager.getDataObject([100,45]);
% 
% rng(2);
% fprintf('sampling test data\n');
% sampler.createSamples(testData);
% 
% fprintf('preprocessing test data\n');
% ceokkfLearner.preprocessData(testData);
% 
% ceokkfLearner = optimizer.hyperParameterObject;
% ceokkfLearner.updateModel(data);

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
% m{1} = (ceokkfLearner.ceokkf.K11 + ceokkfLearner.transitionModelLearner.lambdaT *eye(kernel_size)) \ ceokkfLearner.ceokkf.getKernelVectors1(Y);
% mt{1} = ceokkfLearner.ceokkf.getEmbeddings(Y);
% 
% for t = 2:30
%     Y_out{t} = ceokkfLearner.ceokkf.outputTransformation(m{t-1});
%     Yt_out{t} = ceokkfLearner.ceokkf.outputTransformation(mt{t-1});
%     m{t} = (ceokkfLearner.ceokkf.K11 + ceokkfLearner.transitionModelLearner.lambdaT *eye(kernel_size)) \ ceokkfLearner.ceokkf.K12 * m{t-1};
%     mt{t} = ceokkfLearner.ceokkf.transition(m{t-1});
%     hold off
%     plot(t:length(Y_out{t})+t-1,Y_out{t}(1,:)'); hold on; plot(t:length(Yt_out{t})+t-1,Yt_out{t}(1,:)','k'); plot(Yw(:,obs_ind),'r');
%     pause
% end

%%
for i = 71:90
%     i = 1;
%     optimizer.hyperParameterObject.filter.initialMean = optimizer.hyperParameterObject.filter.getEmbeddings(data.getDataEntry(feature_name,i,1));
    optimizer.hyperParameterObject.filter.callDataFunction('filterData', data, i);

    %
    dataStruct = data.getDataStructure();
    hold off;
    Plotter.shadedErrorBar([],dataStruct.steps(i).filteredMu(:,1),2*sqrt(dataStruct.steps(i).filteredVar(:,1)),'-k',1);
%     plot(dataStruct.steps(i).filteredMu(:,1),'-k');
    hold on;
    plot(dataStruct.steps(i).thetaNoisy(:,1))
    plot(dataStruct.steps(i).states(:,1),':');
    pause
end