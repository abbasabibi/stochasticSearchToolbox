
assert(exist('dataManager','var') && isa(dataManager,'Data.DataManager'));

if ~exist('settings','var')
    settings = Common.Settings();
end

if ~exist('pca_feature_input','var')
    pca_feature_input = current_data_pipe;
end

if ~exist('pca_feature_output','var')
    pca_feature_output = cellfun(@(A) [A 'PcaFeatures'],pca_feature_input, 'UniformOutput', false);
end

if ~exist('num_pca_features','var')
    num_pca_features = window_size;
end

if ~exist('clone_pca_transform','var')
    clone_pca_transform = false;
end

if exist('pcaFeatures','var')
    basePcaFeatures = pcaFeatures;
end

featureGeneratorName = 'pcaFeatureGenerator';
settings.setProperty([featureGeneratorName '_featureName'], 'PcaFeatures');
settings.setProperty([featureGeneratorName '_featureVariables'], pca_feature_input);
settings.setProperty([featureGeneratorName '_numFeatures'], num_pca_features);

pcaFeatures = FeatureGenerators.LinearTransformFeatures(dataManager, pca_feature_input, 'PcaFeatures', ':', num_pca_features);
if clone_pca_transform
    pcaFeatureLearner = FeatureGenerators.FeatureLearner.CloneLinearTransformFeatureGenerator(pcaFeatures,basePcaFeatures);
else
    pcaFeatureLearner = FeatureGenerators.FeatureLearner.PrimaryComponentsAnalysis(pcaFeatures);
end

pca_feature_name = [pca_feature_input 'PcaFeatures'];

current_data_pipe = pca_feature_output;