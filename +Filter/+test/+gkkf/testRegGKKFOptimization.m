Common.clearClasses
clear variables;
close all;

obsPointsIdx = [1:5,20];

numObservedSamples = 5;
kernel_size = 1000;
% obs_kernel_size = 300;
red_kernel_size = 500;

%obs_noise = 
% feature_name = 'thetaNoisyWindowsPcaFeatures';
feature_name = 'thetaNoisyWindows';

Filter.test.setup.PendulumSampler;
Filter.test.setup.NoisePreprocessor;
Filter.test.setup.WindowPreprocessor;
% Filter.test.setup.PcaFeatureGenerators;
Filter.test.setup.RegGkkfLearner;

settings.setProperty('groundtruthName','theta');
settings.setProperty('gkkfOptimizer_inputDataEntry','thetaWindows');%feature_name);
% settings.setProperty('ParameterMapGKKF_CMAES_optimization',[true true true true false true false false]);
settings.setProperty('CMAOptimizerInitialRangeGKKF_CMAES_optimization', 0.05);
settings.setProperty('maxNumOptiIterationsGKKF_CMAES_optimization', 5);

dataManager.addDataEntry('steps.obsPoints',1);

gkkfLearner.addDataPreprocessor(noisePrepro);
gkkfLearner.addDataPreprocessor(windowsPrepro);

optimizer = Filter.Learner.GeneralizedKernelKalmanFilterOptimizer(dataManager, gkkfLearner);

dataManager.finalizeDataManager();

% obtain first data object for learning
data = dataManager.getDataObject([100,45]);

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
for i = 1:20
%     i = 1;
    optimizer.hyperParameterObject.filter.initialMean = optimizer.hyperParameterObject.filter.getEmbeddings(data.getDataEntry('thetaWindows',i,1));
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