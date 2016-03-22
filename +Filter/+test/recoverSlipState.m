Common.clearClasses
clear variables

settings = Common.Settings();

BALL = 1;
BOX = 2;
CUP = 3;
MARKER = 4;
MESURER = 5;
TAPE = 6;
WATERINGCAN = 7;

filename = {'ball' 'box' 'cup' 'marker' 'mesurer' 'tape' 'wateringcan'};

objectTypeDataManager = Data.DataManager('objectType');
episodesDataManager =  Data.DataManager('episodes');
stepsDataManager = Data.DataManager('steps');
stepsDataManager.addDataEntry('states',45);
dataManager = episodesDataManager;

objectTypeDataManager.setSubDataManager(episodesDataManager);
episodesDataManager.setSubDataManager(stepsDataManager);

objectTypeDataManager.addDataAlias('Electrodes','states',1:19);
objectTypeDataManager.addDataAlias('AcPressure','states',20:41);
objectTypeDataManager.addDataAlias('DcPressure','states',42);
objectTypeDataManager.addDataAlias('AcTemperature','states',43);
objectTypeDataManager.addDataAlias('DcTemperature','states',44);
objectTypeDataManager.addDataAlias('slipState','states',45);

objectTypeDataManager.addDataAlias('stateFeatures','states',20:42);
objectTypeDataManager.addDataAlias('obsFeatures','states',20:42);

% pca_feature_input = {'stateFeatures'};
% num_pca_features = 10;
% Filter.test.setup.PcaFeatureGenerators;

window_prepro_input = {'stateFeatures'};
window_size = 1;
Filter.test.setup.WindowPreprocessor;

kernel_size = 1000;
red_kernel_size = 300;

num_features = window_size * 23;
num_obs_features = 23;
feature_name = 'stateFeaturesWindows';
obs_feature_name = 'obsFeatures';
output_data_name = 'obsFeatures';
valid_data_name = 'stateFeaturesWindowsValid';

obs_bandwidth_factor = 1;
state_bandwidth_factor = 100;
obs_bandwidht_num_datapoints = 1000;
state_bandwidth_num_datapoints = 1000;

cond_operator_type = 'reg';

state_kernel_type = 'ScaledBandwidthExponentialQuadraticKernel';
obs_kernel_type = 'ScaledBandwidthExponentialQuadraticKernel';

settings.setProperty('GKKF_enableConstCovApprox',false);

window_prediction = false;

Filter.test.setup.GkkfLearner;
gkkfLearner.addDataPreprocessor(windowsPrepro);

% settings.setProperty('GKKF_CMAES_optimization_trainEpisodesRatio',.9);
settings.setProperty('GKKF_CMAES_optimization_groundtruthName','obsFeatures');
settings.setProperty('GKKF_CMAES_optimization_observationIndex',1:23);
settings.setProperty('GKKF_CMAES_optimization_validityDataEntry','valid');
settings.setProperty('GKKF_CMAES_optimization_testMethod','oneStep');
settings.setProperty('ParameterMapGKKF_CMAES_optimization',[true false true true false]);
settings.setProperty('CMAOptimizerInitialRangeGKKF_CMAES_optimization', 0.05);
settings.setProperty('maxNumOptiIterationsGKKF_CMAES_optimization', 200);

objectTypeDataManager.addDataEntry('steps.obsPoints',1);
objectTypeDataManager.addDataEntry('steps.valid',1);

optimizer = Filter.Learner.GeneralizedKernelKalmanFilterOptimizer(objectTypeDataManager, gkkfLearner, 'GKKF_CMAES_optimization');

objectTypeDataManager.finalizeDataManager();

data = objectTypeDataManager.getDataObject();
data.reserveStorage(7);

max_steps = 0;
for object_type = 1:7
    data.reserveStorage(10,object_type);
    for i = 1:10
        D = load(['/local_data/slip_data/' filename{object_type} sprintf('%03d',i) '.data']);
        num_steps = size(D,1);
        if max_steps < num_steps
            max_steps = num_steps;
        end
        data.reserveStorage(num_steps,object_type,i);
        data.setDataEntry('states',D,object_type,i,:);
        obsPoints = true(num_steps,1);
        data.setDataEntry('obsPoints',obsPoints,object_type,i,:);
        valid = false(num_steps,1);
        valid(find(D(:,45) == 1,1,'last')-300:find(D(:,45) == 2,1,'last')+300) = true;
        data.setDataEntry('valid',valid,object_type,i,:);
    end
end
data.reserveStorage(max_steps,:,:);

%%
% pcaFeatureLearner.updateModel(data.getSubDataObject(1));
optimizer.updateModel(data.getSubDataObject(1));
