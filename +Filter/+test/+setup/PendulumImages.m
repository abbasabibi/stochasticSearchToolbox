%

assert(exist('dataManager','var') && isa(dataManager,'Data.DataManager'));

if ~exist('settings','var')
    settings = Common.Settings();
end

if ~exist('picture_size','var')
    picture_size = 10;
end

if ~exist('picture_feature_input','var')
    picture_feature_input = current_data_pipe;
end

if ~exist('pca_feature_output','var')
    picture_feature_output = cellfun(@(A) [A 'Picture'],picture_feature_input, 'UniformOutput', false);
end

% imageFeatureGenerator settings
if exist('bluramount','var')
    settings.setProperty('bluramount',bluramount);
end

% preprocessors
imageFeatureGen = FeatureGenerators.PendulumPictureSingleFrame(dataManager,picture_feature_input,':',picture_size);

current_data_pipe = picture_feature_output;