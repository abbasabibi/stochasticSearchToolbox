%

assert(exist('dataManager','var') && isa(dataManager,'Data.DataManager'));

if ~exist('settings','var')
    settings = Common.Settings();
end

if ~exist('kernel_size','var')
    kernel_size = 600;
end

if ~exist('obs_kernel_size','var')
    obs_kernel_size = kernel_size;
end

if ~exist('red_kernel_size','var')
    red_kernel_size = 300;
end

if ~exist('state_bandwidth_factor','var')
    state_bandwidth_factor = 1;
end

if ~exist('obs_bandwidth_factor','var')
    obs_bandwidth_factor = 1;
end

if ~exist('lambdaT','var')
    lambdaT = 1e-6;
end

if ~exist('lambdaO','var')
    lambdaO = 1e-6;
end

if ~exist('kappa','var')
    kappa = 1e-4;
end

if ~exist('num_features','var')
    num_features = window_size;
end

if ~exist('num_obs_features','var')
    num_obs_features = 1;
end

if ~exist('feature_name','var')
    feature_name = 'thetaNoisyWindows';
end

if ~exist('obs_feature_name','var')
    obs_feature_name = 'thetaNoisy';
end

if ~exist('output_data_name','var')
    output_data_name = 'thetaNoisy';
end

if ~exist('valid_data_name','var')
    valid_data_name = 'thetaNoisyWindowsValid';
end

if ~exist('refset_learner_type','var')
    refset_learner_type = 'greedy';
end

if ~exist('cond_operator_type','var')
    cond_operator_type = 'std';
end


% gkkfLearner Settings
gkkfLearnerName = 'gkkfLearner';
settings.setProperty([gkkfLearnerName '_outputDataName'], output_data_name);
settings.setProperty([gkkfLearnerName '_stateFeatureName'], feature_name);
settings.setProperty([gkkfLearnerName '_obsFeatureName'], obs_feature_name);
settings.setProperty([gkkfLearnerName '_observations'], {obs_feature_name, 'obsPoints'});
settings.setProperty([gkkfLearnerName '_stateFeatureSize'], num_features);% pca_features);
settings.setProperty([gkkfLearnerName '_obsFeatureSize'], num_obs_features);
% gkkfLearner_stateKernelType: ExponentialQuadraticKernel
% gkkfLearner_obsKernelType: ExponentialQuadraticKernel
settings.setProperty([gkkfLearnerName '_conditionalOperatorType'], cond_operator_type);
settings.setProperty([gkkfLearnerName '_referenceSetLearnerType'], refset_learner_type);

settings.setProperty('obsKRS_kernelMedianBandwidthFactor', obs_bandwidth_factor);
settings.setProperty('stateKRS_kernelMedianBandwidthFactor', state_bandwidth_factor);

% gkkf settings
gkkfName = 'GKKF';
settings.setProperty('GKKF_lambdaT',lambdaT);
settings.setProperty('GKKF_lambdaO',lambdaO);
settings.setProperty('GKKF_kappa',kappa);


% referenceSet settings
settings.setProperty('stateKRS_maxSizeReferenceSet', kernel_size);
settings.setProperty('obsKRS_maxSizeReferenceSet', obs_kernel_size);
settings.setProperty('reducedKRS_maxSizeReferenceSet', red_kernel_size);
settings.setProperty('stateKRS_inputDataEntry', feature_name);
settings.setProperty('stateKRS_validityDataEntry', valid_data_name);
settings.setProperty('obsKRS_inputDataEntry', obs_feature_name);
settings.setProperty('obsKRS_validityDataEntry', valid_data_name);
settings.setProperty('reducedKRS_inputDataEntry', feature_name);
settings.setProperty('reducedKRS_validityDataEntry', valid_data_name);

settings.setProperty([gkkfLearnerName '_windowPrediction'],true);
gkkfLearner = Filter.Learner.GeneralizedKernelKalmanFilterLearner(dataManager,gkkfLearnerName);