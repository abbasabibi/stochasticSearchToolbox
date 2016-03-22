Common.clearClasses;
clear variables;
close all;

Filter.test.setup.PendulumSampler;
Filter.test.setup.NoisePreprocessor;
Filter.test.setup.WindowPreprocessor;

Smoother.test.setup.GkkfLearner;

obsPointsIndices = [1:4,28:30];

%%
dataManager.finalizeDataManager();

gkkfLearner.addDataPreprocessor(noisePrepro);
gkkfLearner.addDataPreprocessor(windowsPrepro);


% obtain first data object for learning
data = dataManager.getDataObject([100,30]);

%sampler.numSamples = 1000;
rng(1);
fprintf('sampling data\n');
sampler.createSamples(data);

fprintf('preprocessing data\n');
gkkfLearner.preprocessData(data);

fprintf('learning model\n');

gkkfLearner.updateModel(data);

% obtain second data object for testing
testData = dataManager.getDataObject([100,30]);

rng(2);
fprintf('sampling test data\n');
sampler.createSamples(testData);

fprintf('preprocessing test data\n');
gkkfLearner.preprocessData(testData);

%%
obsPoints = false(30,1);
obsPoints(obsPointsIndices) = true;
testData.setDataEntry('obsPoints',repmat(obsPoints,numEpisodes,1));

gkkfLearner.filter.callDataFunction('filterData',testData,1:20);
gkkfLearner.filter.callDataFunction('smoothData',testData,1:20);

%%

for i = 1:20
    hold off
    Plotter.shadedErrorBar([],testData.getDataEntry('filteredMu',i),testData.getDataEntry('filteredVar',i));
    hold on
    Plotter.shadedErrorBar([],testData.getDataEntry('smoothedMu',i),testData.getDataEntry('smoothedVar',i),'k');
    plot(testData.getDataEntry('theta',i),':r');
    plot(testData.getDataEntry('thetaNoisy',i),'--r');
    pause
end