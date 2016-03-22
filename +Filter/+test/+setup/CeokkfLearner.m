%

assert(exist('dataManager','var') && isa(dataManager,'Data.DataManager'));

if ~exist('settings','var')
    settings = Common.Settings();
end

if ~exist('kernel_size','var')
    kernel_size = 600;
end

if ~exist('bandwidth_factor','var')
    bandwidth_factor = 1;
end

if ~exist('q','var')
    q = 4e-4;
end

if ~exist('r','var')
    r = 1e-3;
end

if ~exist('lambda','var')
    lambda = .9e-7;
end

if ~exist('sigma','var')
    sigma = 2.5e-9;
end

if ~exist('num_features','var')
    num_features = window_size;
end

if ~exist('feature_name','var')
    feature_name = current_data_pipe{1};
end

if ~exist('output_data_name','var')
%     output_data_name = window_prepro_input(1);
    output_data_name = {feature_name};
end

if ~exist('window_prediction','var')
    window_prediction = false;
end

if ~exist('valid_data_name','var')
    valid_data_name = [feature_name 'Valid'];
end

if ~exist('kernel_type','var')
    kernel_type = 'ExponentialQuadraticKernel';
end



% gkkfLearner Settings
ceokkfLearnerName = 'ceokkfLearner';
settings.setProperty([ceokkfLearnerName '_outputDataName'], output_data_name);
settings.setProperty([ceokkfLearnerName '_featureName'], feature_name);
settings.setProperty([ceokkfLearnerName '_observations'], {feature_name, 'obsPoints'});
settings.setProperty([ceokkfLearnerName '_featureSize'], num_features);% pca_features);
settings.setProperty([ceokkfLearnerName '_sigma'], sigma);
settings.setProperty([ceokkfLearnerName '_lambda'], lambda);
settings.setProperty([ceokkfLearnerName '_q'], q);
settings.setProperty([ceokkfLearnerName '_r'], r);
settings.setProperty([ceokkfLearnerName '_kernelType'], kernel_type);
% gkkfLearner_outputDataName:
% gkkfLearner_stateFeatureName: stateFeatures
% gkkfLearner_nextStateFeatureName: nextStateFeatures
% gkkfLearner_obsFeatureName: obsFeatures
% gkkfLearner_stateFeatureSize:
% gkkfLearner_obsFeatureSize:
% gkkfLearner_stateKernelType: ExponentialQuadraticKernel
% gkkfLearner_obsKernelType: ExponentialQuadraticKernel

settings.setProperty('kernelReferenceSet_kernelMedianBandwidthFactor', bandwidth_factor);



% referenceSet settings
settings.setProperty('kernelReferenceSet_maxSizeReferenceSet', kernel_size);
settings.setProperty('kernelReferenceSet_inputDataEntry', feature_name);
settings.setProperty('kernelReferenceSet_validityDataEntry', valid_data_name);

settings.setProperty([ceokkfLearnerName '_windowPrediction'], window_prediction);
settings.setProperty(['CEOKKF_windowSize'], window_size);

ceokkfLearner = Filter.Learner.CEOKernelKalmanFilterLearner(dataManager, ceokkfLearnerName);