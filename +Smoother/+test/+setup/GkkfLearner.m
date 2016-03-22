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
    feature_name = current_data_pipe{1};
end

if ~exist('obs_feature_name','var')
    obs_feature_name = window_prepro_input{1};
end

if ~exist('output_data_name','var')
    output_data_name = window_prepro_input(1);
end

if ~exist('valid_data_name','var')
    valid_data_name = [current_data_pipe{1} 'Valid'];
end

if ~exist('refset_learner_type','var')
    refset_learner_type = 'greedy';
end

if ~exist('cond_operator_type','var')
    cond_operator_type = 'std';
end

if ~exist('window_prediction','var')
    window_prediction = false;
end

if ~exist('state_kernel_type','var')
    state_kernel_type = 'ExponentialQuadraticKernel';
end

if ~exist('obs_kernel_type','var')
    obs_kernel_type = 'ExponentialQuadraticKernel';
end

if ~exist('obs_bandwidth_num_datapoints','var')
    obs_bandwidth_num_datapoints = 500;
end

if ~exist('state_bandwidth_num_datapoints','var')
    state_bandwidth_num_datapoints = 500;
end


% gkkfLearner Settings
gkkfLearnerName = 'gkkfLearner';
settings.setProperty([gkkfLearnerName '_outputDataName'], output_data_name);
settings.setProperty([gkkfLearnerName '_stateFeatureName'], feature_name);
settings.setProperty([gkkfLearnerName '_obsFeatureName'], obs_feature_name);
settings.setProperty([gkkfLearnerName '_observations'], {obs_feature_name, 'obsPoints'});
settings.setProperty([gkkfLearnerName '_stateFeatureSize'], num_features);% pca_features);
settings.setProperty([gkkfLearnerName '_obsFeatureSize'], num_obs_features);
settings.setProperty([gkkfLearnerName '_stateKernelType'], state_kernel_type);
settings.setProperty([gkkfLearnerName '_obsKernelType'], obs_kernel_type);
settings.setProperty([gkkfLearnerName '_conditionalOperatorType'], cond_operator_type);
settings.setProperty([gkkfLearnerName '_referenceSetLearnerType'], refset_learner_type);

settings.setProperty('obsKRS_kernelMedianBandwidthFactor', obs_bandwidth_factor);
settings.setProperty('stateKRS_kernelMedianBandwidthFactor', state_bandwidth_factor);
settings.setProperty('obsKRS_numDataPointsForBandwidthSelection', obs_bandwidth_num_datapoints);
settings.setProperty('stateKRS_numDataPointsForBandwidthSelection', state_bandwidth_num_datapoints);

% gkkf settings
gkkfName = 'GKKS';
settings.setProperty('GKKS_lambdaT',lambdaT);
settings.setProperty('GKKS_lambdaO',lambdaO);
settings.setProperty('GKKS_kappa',kappa);


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

settings.setProperty([gkkfLearnerName '_windowPrediction'],window_prediction);
gkkfLearner = Smoother.Learner.GeneralizedKernelKalmanSmootherLearner(dataManager,gkkfLearnerName);