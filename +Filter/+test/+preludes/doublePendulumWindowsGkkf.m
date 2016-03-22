Filter.test.setup.DoublePendulumSampler;
obs_noise = 1e-4;
Filter.test.setup.NoisePreprocessor;
Filter.test.setup.WindowPreprocessor;
num_features = 2*window_size;
num_obs_features = 2;
Filter.test.setup.GkkfLearner;

dataManager.finalizeDataManager();

gkkfLearner.addDataPreprocessor(noisePrepro);
gkkfLearner.addDataPreprocessor(windowsPrepro);


% obtain first data object for learning
% data = dataManager.getDataObject([numEpisodes,numSamplesPerEpisode]);

%sampler.numSamples = 1000;
% rng(1);
% fprintf('sampling data\n');
% sampler.createSamples(data);
% 
% fprintf('preprocessing data\n');
% gkkfLearner.preprocessData(data);
% 
% fprintf('learning model\n');
% 
% gkkfLearner.updateModel(data);

% obtain second data object for testing
% testData = dataManager.getDataObject([numEpisodes,numSamplesPerEpisode]);
% 
% rng(2);
% fprintf('sampling test data\n');
% sampler.createSamples(testData);
% 
% fprintf('preprocessing test data\n');
% gkkfLearner.preprocessData(testData);