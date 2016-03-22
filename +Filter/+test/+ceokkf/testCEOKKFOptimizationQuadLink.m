Common.clearClasses
clear variables;
close all;

numEpisodes = 200;

kernel_size = 500;
% obs_kernel_size = 300;

%obs_noise = 
% feature_name = 'thetaNoisyWindowsPcaFeatures';
% feature_name = 'endEffPositionsNoisyWindows';
numSamplesPerEpisode = 43;


% window_prediction = true;
window_size = 8;
obs_ind = 8;
obsPointsIdx = [obs_ind:numSamplesPerEpisode];
% obsPointsIdx = 1:numSamplesPerEpisode-window_size;
% obsPointsIdx = obs_ind:numSamplesPerEpisode;
process_noise = .1;
Filter.test.setup.QuadLinkSampler;
obs_noise = 1e-3;
Filter.test.setup.NoisePreprocessor;
window_prepro_input = {'endEffPositionsNoisy'};
Filter.test.setup.WindowPreprocessor;
windowsPrepro2 = windowsPrepro;
current_data_pipe = {'endEffPositionsNoisyWindows'};

bandwidth_factor = .86;
sigma = exp(-20);
lambda = exp(-16);
q = exp(-7.6);
r = exp(-7.8);

num_features = window_size * 2;
% output_data_name = {'endEffPositions'};

window_prediction = true;
window_size = 4;
kernel_type = 'ScaledBandwidthExponentialQuadraticKernel';
% feature_name = 'endEffPositionsWindows';
Filter.test.setup.CeokkfLearner;


window_prepro_name = 'groundtruthWindows';
obs_ind = 1;
window_size = 4;
window_prepro_input = 'endEffPositions';
window_prepro_output = {'endEffPositionsWindows'};
Filter.test.setup.WindowPreprocessor;

dataManager.addDataAlias('allValid',{'endEffPositionsNoisyWindowsValid' 'endEffPositionsWindowsValid'});

settings.setProperty('ceokkfOptimizer_groundtruthName','endEffPositionsWindows');
settings.setProperty('ceokkfOptimizer_observationIndex',[15 16 31 32 47 48 63 64]);
settings.setProperty('ceokkfOptimizer_validityDataEntry','allValid');
settings.setProperty('ceokkfOptimizer_internalObjective','euclidean');
% settings.setProperty('ceokkfOptimizer_internalObjective','llh');
% settings.setProperty('ceokkfOptimizer_validityDataEntry','endEffPositionsWindowsValid');
% settings.setProperty('ParameterMapCEOKKF_CMAES_optimization',[false false true true false]);
settings.setProperty('CMAOptimizerInitialRangeCEOKKF_CMAES_optimization', 0.05);
settings.setProperty('maxNumOptiIterationsCEOKKF_CMAES_optimization', 25);

ceokkfLearner.addDataPreprocessor(noisePrepro);
ceokkfLearner.addDataPreprocessor(windowsPrepro2);
ceokkfLearner.addDataPreprocessor(windowsPrepro);

optimizer = Filter.Learner.CEOKernelKalmanFilterOptimizer(dataManager, ceokkfLearner);

% ceokkfLearner.filter.outputFullCov = true;

dataManager.finalizeDataManager();

% obtain first data object for learning
data = dataManager.getDataObject([numEpisodes,numSamplesPerEpisode]);

%sampler.numSamples = 1000;
rng(1);
fprintf('sampling data\n');
sampler.createSamples(data);

fprintf('preprocessing data\n');
ceokkfLearner.preprocessData(data);
% ceokkfLearner.updateModel(data);

% pcaFeatureLearner.updateModel(data);
obsPoints = false(numSamplesPerEpisode,1);
obsPoints(obsPointsIdx) = true;
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
optimizer.hyperParameterObject.filter.outputFullCov = true;
for i = 1:20
%     i = 1;
    figure(1);
    clf;
    hold on;
    [smoothedMu, smoothedVar] = optimizer.hyperParameterObject.filter.callDataFunctionOutput('filterData', data, i, 1:obsPointsIdx(end));
    dataStruct = data.getDataStructure();
    plot(dataStruct.steps(i).endEffPositions(1:obsPointsIdx(end),1),dataStruct.steps(i).endEffPositions(1:obsPointsIdx(end),2),'b')
    plot(dataStruct.steps(i).endEffPositionsNoisy(1:obsPointsIdx(end),1),dataStruct.steps(i).endEffPositions(1:obsPointsIdx(end),2),'g')
%     plot(dataStruct.steps(i).endEffPositions(obsPointsIdx,1),dataStruct.steps(i).endEffPositions(obsPointsIdx,2),'+r');
%     Plotter.shadedErrorBar([],dataStruct.steps(i).smoothedMu(:,1),2*sqrt(dataStruct.steps(i).smoothedVar(:,1)),'-k',1);
    for j = obsPointsIdx(1):1:obsPointsIdx(end)
        Plotter.Gaussianplot.plotgauss2d(smoothedMu(j,15:16)',squeeze(smoothedVar(j,15:16,15:16)),'k');
    end
    plot(smoothedMu(obsPointsIdx(1):1:obsPointsIdx(end),15),smoothedMu(obsPointsIdx(1):1:obsPointsIdx(end),16),'k');
    plot(smoothedMu(obsPointsIdx,15),smoothedMu(obsPointsIdx,16),'+b');
%     plot(dataStruct.steps(i).states(:,1),':');
    pause
end