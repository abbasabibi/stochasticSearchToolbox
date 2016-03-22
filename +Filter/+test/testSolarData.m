Common.clearClasses();
clc;
close all;

D = importdata('data/solar-0726/train.csv',',',1);

dataManager = Data.DataManager('episodes');
stepDataManager = Data.DataManager('steps');

% add time to observations
[Y_, M, D_, H, MN_, S_] = datevec(D.textdata(2:end,1));

[H(:,1), H(:,2)] = pol2cart(H./24 .* 2 * pi,1);

stepDataManager.addDataEntry('u',1);
stepDataManager.addDataEntry('v',1);
stepDataManager.addDataEntry('temp',1);
stepDataManager.addDataEntry('rh',1);
stepDataManager.addDataEntry('prmsl',1);
stepDataManager.addDataEntry('H',2);
stepDataManager.addDataEntry('M',1);
stepDataManager.addDataAlias('observations',{'u','v','temp','rh','prmsl','H','M'});
stepDataManager.addDataEntry('targets',1);
% stepDataManager.addDataAlias('states',{'u','v','temp','rh','prmsl','H','targets'});
stepDataManager.addDataAlias('states',{'u','v','temp','rh','prmsl','H','M','targets'});
% stepDataManager.addDataAlias('states',{'targets'});
stepDataManager.addDataEntry('obsPoints',1);

dataManager.setSubDataManager(stepDataManager);

dataManager.finalizeDataManager();

current_data_pipe = {'states'};
window_size = 4;
obs_ind = 1;
Filter.test.setup.WindowPreprocessor;
num_features = window_size * stepDataManager.getNumDimensions('states');
obs_feature_name = 'observations';
num_obs_features = stepDataManager.getNumDimensions('observations');
output_data_name = {'targets'};
cond_operator_type = 'reg';
kernel_size = 500;
red_kernel_size = 500;
state_bandwidth_factor = 2;
obs_bandwidth_factor = .8;
lambdaO = exp(-12);
lambdaT = exp(-12);
kappa = exp(-8);

% state_kernel_type = 'ExpQuadLinearKernel';
% obs_kernel_type = 'ExpQuadLinearKernel';
% state_kernel_type = 'ScaledBandwidthExponentialQuadraticKernel';
% obs_kernel_type = 'ScaledBandwidthExponentialQuadraticKernel';
state_kernel_type = 'ExpQuadExpQuadLinearKernel';
obs_kernel_type = 'ExpQuadExpQuadLinearKernel';

Smoother.test.setup.GkkfLearner;

gkkfLearner.addDataPreprocessor(windowsPrepro);

settings.setProperty('GKKF_CMAES_optimization_groundtruthName','targets');
settings.setProperty('GKKF_CMAES_optimization_validityDataEntry','statesWindowsValid');
settings.setProperty('GKKF_CMAES_optimization_observationIndex',1);
settings.setProperty('GKKF_CMAES_optimization_testMethod','smooth');
settings.setProperty('GKKF_CMAES_optimization_internalObjective','abs');
% settings.setProperty('gkkfOptimizer_inputDataEntry','thetaWindows');%feature_name);
settings.setProperty('HyperParametersOptimizerGKKF_CMAES_optimization','CMAES');
% settings.setProperty('GKKF_CMAES_optimization_initUpperParamLogBounds', []);
% settings.setProperty('GKKF_CMAES_optimization_initLowerParamLogBounds', [-9.5]);
% settings.setProperty('GKKF_CMAES_optimization_initUpperParamLogBoundsIdx', []);
% settings.setProperty('GKKF_CMAES_optimization_initLowerParamLogBoundsIdx', 'end');
% settings.setProperty('ParameterMapGKKF_CMAES_optimization',[false(1,3) true(1,12)]);
settings.setProperty('CMAOptimizerInitialRangeGKKF_CMAES_optimization', 0.05);
settings.setProperty('maxNumOptiIterationsGKKF_CMAES_optimization', 300);

optimizer = Smoother.Learner.GeneralizedKernelKalmanSmootherOptimizer(dataManager, gkkfLearner);
optimizer.trainEpisodesRatio = .5;

dataManager.finalizeDataManager();
%%%%%%

lengthEpisodes = 32;
episodeSkip = 24;
numEpisodes = floor((520-lengthEpisodes)/episodeSkip);
data = dataManager.getDataObject([numEpisodes,lengthEpisodes]);
observations = zeros(lengthEpisodes,numEpisodes,num_obs_features);
targets = zeros(lengthEpisodes,numEpisodes);
rand_idx = randperm(numEpisodes);
for i = 1:numEpisodes
    range = 8+(i-1)*episodeSkip+(1:lengthEpisodes);
    observations(:,rand_idx(i),:) = [D.data(range,2:6) H(range,:) M(range,:)];
    targets(:,rand_idx(i)) = D.data(range,1);
end

observations = reshape(observations,[],num_obs_features);
targets = reshape(targets,[],1);

min_observations = min(observations);
range_observations = max(observations) - min_observations;
observations = bsxfun(@rdivide,bsxfun(@minus,observations,min_observations),range_observations);

data.setDataEntry('observations',observations);
data.setDataEntry('targets',targets);
data.setDataEntry('obsPoints',ones(lengthEpisodes*numEpisodes,1));

windowsPrepro.preprocessData(data);

% gkkfLearner.setHyperParameters([...
%     5.8387e-07   ...
%     1.3575e+00   2.9178e+00   1.3723e+01   1.2334e+02   6.3833e+02   9.7033e-01   2.5898e+00   5.2380e-02 ...
%     9.0365e-01   1.2946e+00   8.0541e+00   2.8137e+01   1.0602e+03   3.8074e-01   3.5803e-01   2.7401e-01 ...
%     1.1943e+00   2.8468e+00   1.4482e+00   1.9768e+00   4.3408e+02   6.7868e-01   1.6918e+00   9.4202e-01 ...
%     4.8534e-01   2.7568e+00   1.8989e+00   4.0750e+01   7.8228e+02   2.7428e-01   1.6627e-01   1.7403e-01 ...
%     1.4530e+01   5.0654e+01   2.4526e+02   8.2446e+01   6.9737e+03   4.6574e-01   8.5860e-01   ...
%     3.0585e-04   2.7357e-04   1.4130e-02]);
% 
% gkkfLearner.updateModel(data);


fprintf('starting optimization\n');
optimizer.processTrainingData(data);
optimizer.initializeParameters(data);
optimizer.updateModel(data);

data2 = dataManager.getDataObject([1,520]);
data2.setDataEntry('observations',bsxfun(@rdivide,bsxfun(@minus,[D.data(9:end,2:6) H(9:end,:) M(9:end)],min_observations),range_observations));
data2.setDataEntry('targets',D.data(9:end,1));
data2.setDataEntry('obsPoints',ones(520,1));
windowsPrepro.preprocessData(data2);

% gkkfLearner.updateModel(data);

%%
gkkfLearner.filter.outputFullCov = true;
[filteredMu, filteredVar] = gkkfLearner.filter.callDataFunctionOutput('smoothData',data2);

clearedFilteredMu = filteredMu;
clearedFilteredMu(clearedFilteredMu < 0.06) = 0;
groundtruth = data2.getDataEntry('targets');

Plotter.shadedErrorBar([],clearedFilteredMu,filteredVar,'b'); hold on; plot(groundtruth,'r');
mse = sum(abs(clearedFilteredMu - groundtruth))./length(groundtruth);

%%
D_test = importdata('data/solar-0726/test.csv',',',1);
[Y_, M, D_, H, MN_, S_] = datevec(D_test.textdata(2:end,1));
[H(:,1), H(:,2)] = pol2cart(H./24 .* 2 * pi,1);

data_test = dataManager.getDataObject([1,247]);
data_test.setDataEntry('observations',bsxfun(@rdivide,bsxfun(@minus,[D_test.data(:,1:5) H M],min_observations),range_observations));
data_test.setDataEntry('obsPoints',ones(247,1));

[filteredMu, filteredVar] = gkkfLearner.filter.callDataFunctionOutput('filterData',data_test);

filteredMu(filteredMu < 0.05) = 0;

submission_filename = ['data/solar-0726/submission_' datestr(now,'yymmdd-HHMMSS') '.csv'];
dlmwrite(submission_filename,filteredMu,'precision','%.4f');