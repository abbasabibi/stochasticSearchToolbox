Filter.test.setup.PendulumSampler;
Filter.test.setup.DataPreprocessors;
Filter.test.setup.PcaFeatureGenerators;
Filter.test.setup.GkkfLearner;

dataManager.finalizeDataManager();

gkkfLearner.addDataPreprocessor(obsNoisePrepro);
gkkfLearner.addDataPreprocessor(windowsPrepro);


% obtain first data object for learning
data = dataManager.getDataObject([100,45]);

%sampler.numSamples = 1000;
rng(1);
fprintf('sampling data\n');
sampler.createSamples(data);

fprintf('preprocessing data\n');
gkkfLearner.preprocessData(data);

pcaFeatureLearner.updateModel(data);

fprintf('learning model\n');

gkkfLearner.updateModel(data);

% obtain second data object for testing
testData = dataManager.getDataObject([100,45]);

rng(2);
fprintf('sampling test data\n');
sampler.createSamples(testData);

fprintf('preprocessing test data\n');
gkkfLearner.preprocessData(testData);