numEpisodes = 100;

picture_size = 10;
window_size = 3;
num_pca_features = 10;

Filter.test.setup.PendulumSampler;
Filter.test.setup.NoisePreprocessor;
Filter.test.setup.PendulumImages;
Filter.test.setup.PcaFeatureGenerators;
Filter.test.setup.WindowPreprocessor;

feature_name = 'thetaNoisyPicturePcaFeaturesWindows';
obs_feature_name = 'thetaNoisyPicturePcaFeatures';
output_data_name = 'theta';
valid_data_name = 'thetaNoisyPicturePcaFeaturesWindowsValid';
num_features = window_size * num_pca_features;
num_obs_features = num_pca_features;
refset_learner_type = 'random';

Filter.test.setup.GkkfLearner;

dataManager.finalizeDataManager();

% gkkfLearner.addDataPreprocessor(obsNoisePrepro);
% gkkfLearner.addDataPreprocessor(windowsPrepro);


% obtain first data object for learning
data = dataManager.getDataObject([numEpisodes,numSamplesPerEpisode]);

%sampler.numSamples = 1000;
rng(1);
fprintf('sampling data\n');
sampler.createSamples(data);

fprintf('preprocessing data\n');
% gkkfLearner.preprocessData(data);
noisePrepro.preprocessData(data);
pcaFeatureLearner.updateModel(data);
windowsPrepro.preprocessData(data);

fprintf('learning model\n');

gkkfLearner.updateModel(data);

% obtain second data object for testing
testData = dataManager.getDataObject([numEpisodes,numSamplesPerEpisode]);

rng(2);
fprintf('sampling test data\n');
sampler.createSamples(testData);

fprintf('preprocessing test data\n');
noisePrepro.preprocessData(testData);
windowsPrepro.preprocessData(testData);