Filter.test.setup.PendulumSampler;
Filter.test.setup.NoisePreprocessor;
Filter.test.setup.WindowPreprocessor;
% window_prediction = true;
% window_size = 4;
Filter.test.setup.CeokkfLearner;

dataManager.finalizeDataManager();

ceokkfLearner.addDataPreprocessor(noisePrepro);
ceokkfLearner.addDataPreprocessor(windowsPrepro);


% obtain first data object for learning
data = dataManager.getDataObject([100,45]);

%sampler.numSamples = 1000;
rng(1);
fprintf('sampling data\n');
sampler.createSamples(data);

fprintf('preprocessing data\n');
ceokkfLearner.preprocessData(data);

fprintf('learning model\n');

ceokkfLearner.initializeModel(data);
ceokkfLearner.updateModel(data);

% obtain second data object for testing
testData = dataManager.getDataObject([100,45]);

rng(2);
fprintf('sampling test data\n');
sampler.createSamples(testData);

fprintf('preprocessing test data\n');
ceokkfLearner.preprocessData(testData);