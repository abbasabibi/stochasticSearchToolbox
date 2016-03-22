close all;

Common.clearClasses();
clear variables;
%clear all;
clc;

%MySQL.mym('closeall');

category = 'evalQuadLinkWindowPrediction';
%category = 'test';
experimentName = 'GkkfRegQuadLinkSwingDown';

% set some variables
%             window_size feature_size index_point
window_size = [4 6 8 10]';
multiplier = [1 2 1];
windowSize = num2cell(bsxfun(@times,window_size,multiplier));
numIterations = 4;
numTrials = 2;

% create a task
configuredTask = Experiments.Tasks.QuadLinkSwingDownTask(false);

configuredNoisePreprocessor = Experiments.Preprocessor.NoisePreprocessorConfigurator('noisePreprocessorConfigurator');
configuredWindowPreprocessor = Experiments.Preprocessor.WindowPreprocessorConfigurator('windowPreprocessorConfigurator');
groundtruthConfiguredWindowPreprocessor = Experiments.Preprocessor.WindowPreprocessorConfigurator('groundtruthWindowPreprocessorConfigurator');

configuredObservationPointsPreprocessor = Experiments.Preprocessor.ObservationPointsPreprocessorConfigurator('observationPointsPreprocessorConfigurator');

configuredGkkf = Experiments.Filter.GeneralizedKernelKalmanFilterConfigurator('gkkfConfigurator');

settings = Common.Settings();
settings.setProperty('observationIndex',1:8);
evaluationCriterion = Experiments.EvaluationCriterion();
evaluationCriterion.registerEvaluator(Evaluator.WindowPredictionEvaluator());

evaluate = Experiments.Evaluation(...
    {'settings.windowPreprocessor_windowSize', 'settings.filterLearner_stateFeatureSize', 'settings.windowPreprocessor_indexPoint'},windowSize,numIterations,numTrials);

evaluate.setDefaultParameter('settings.Noise_std', 1e-2);
evaluate.setDefaultParameter('settings.Noise_mode', 0);
evaluate.setDefaultParameter('settings.dt',1e-1);
evaluate.setDefaultParameter('settings.numSamplesEpisodes',[100 100 100 100]);
evaluate.setDefaultParameter('settings.numTimeSteps',30);

% evaluate.setDefaultParameter('stateAliasAdderAliasNames', {'theta'});
% evaluate.setDefaultParameter('stateAliasAdderAliasTargets', {'states'});
% evaluate.setDefaultParameter('stateAliasAdderAliasIndices', {1});

% general settings
% evaluate.setDefaultParameter('settings.windowSize', 8);
% evaluate.setDefaultParameter('settings.observationIndex', 1:8);

% observation noise settings
noisePreproName = 'noisePrepro';
evaluate.setDefaultParameter('settings.noisePreprocessor_sigma', 1e-3);
evaluate.setDefaultParameter('settings.noisePreprocessor_inputNames', {'endEffPositions'});
% evaluate.setDefaultParameter('settings.noisePreprocessor_outputNames', {'thetaNoisy', 'nextThetaNoisy'});

evaluate.setDefaultParameter('settings.observationPointsPreprocessor_observationIndices',[1:30]);


% window settings
windowsPreproName = 'windowsPrepro';
evaluate.setDefaultParameter('settings.windowPreprocessor_inputNames', {'endEffPositionsNoisy'});
% settings.registerAlias([windowsPreproName '_indexPoint'], 'observationIndex');
% evaluate.setDefaultParameter('settings.windowPreprocessor_indexPoint', 1);
% evaluate.setDefaultParameter('settings.windowPreprocessor_windowSize', 4);

evaluate.setDefaultParameter('groundtruthWindowPreprocessorConfiguratorWindowPreprocessorName','groundtruthWindowPreprocessor');
evaluate.setDefaultParameter('settings.groundtruthWindowPreprocessor_inputNames', {'endEffPositions'});
evaluate.setDefaultParameter('settings.groundtruthWindowPreprocessor_indexPoint', 1);
evaluate.setDefaultParameter('settings.groundtruthWindowPreprocessor_windowSize', 4);


% filterLearner Settings
evaluate.setDefaultParameter('settings.filterLearner_outputDataName', 'endEffPositionsNoisy');
evaluate.setDefaultParameter('settings.filterLearner_stateFeatureName', 'endEffPositionsNoisyWindows');
evaluate.setDefaultParameter('settings.filterLearner_obsFeatureName', 'endEffPositionsNoisy');
% evaluate.setDefaultParameter('settings.filterLearner_stateFeatureSize', 8);
evaluate.setDefaultParameter('settings.filterLearner_obsFeatureSize', 2);
evaluate.setDefaultParameter('settings.filterLearner_observations', {'endEffPositionsNoisy','obsPoints'});
evaluate.setDefaultParameter('settings.filterLearner_conditionalOperatorType','reg');
evaluate.setDefaultParameter('settings.filterLearner_windowPrediction',true);

evaluate.setDefaultParameter('settings.GKKF_windowSize',4);
evaluate.setDefaultParameter('settings.GKKF_alpha',1e-8);
evaluate.setDefaultParameter('settings.GKKF_learnTcov',false);

% gkkf settings
gkkfName = 'GKKF';
% GKKF_lambdaT
% GKKF_lambdaO
% GKKF_kappa

% referenceSet settings
evaluate.setDefaultParameter('settings.stateKRS_maxSizeReferenceSet', 5000);
evaluate.setDefaultParameter('settings.obsKRS_maxSizeReferenceSet', 5000);
evaluate.setDefaultParameter('settings.reducedKRS_maxSizeReferenceSet', 500);
evaluate.setDefaultParameter('settings.stateKRS_inputDataEntry', 'endEffPositionsNoisyWindows');
evaluate.setDefaultParameter('settings.stateKRS_validityDataEntry', 'endEffPositionsNoisyWindowsValid');
evaluate.setDefaultParameter('settings.obsKRS_inputDataEntry', 'endEffPositionsNoisy');
evaluate.setDefaultParameter('settings.obsKRS_validityDataEntry', 'endEffPositionsNoisyWindowsValid');
evaluate.setDefaultParameter('settings.reducedKRS_inputDataEntry', 'endEffPositionsNoisyWindows');
evaluate.setDefaultParameter('settings.reducedKRS_validityDataEntry', 'endEffPositionsNoisyWindowsValid');

% optimization settings
evaluate.setDefaultParameter('settings.GKKF_CMAES_optimization_groundtruthName','endEffPositionsWindows');
evaluate.setDefaultParameter('settings.GKKF_CMAES_optimization_observationIndex',1:8);
evaluate.setDefaultParameter('settings.GKKF_CMAES_optimization_validityDataEntry','endEffPositionsWindowsValid');
evaluate.setDefaultParameter('settings.GKKF_CMAES_optimization_internalObjective','mse');

evaluate.setDefaultParameter('settings.CMAOptimizerInitialRangeGKKF_CMAES_optimization', .05);
evaluate.setDefaultParameter('settings.maxNumOptiIterationsGKKF_CMAES_optimization', 200);

evaluate.setDefaultParameter('evaluationGroundtruth','endEffPositionsWindows');
evaluate.setDefaultParameter('evaluationObservations',{'endEffPositionsNoisy', 'obsPoints'});
evaluate.setDefaultParameter('evaluationValid','endEffPositionsWindowsValid');
evaluate.setDefaultParameter('evaluationObservationIndex',1:8);


experiment = Experiments.Experiment.createByNameNew(experimentName, category, ...
     {configuredTask, configuredNoisePreprocessor, ...
     configuredWindowPreprocessor, groundtruthConfiguredWindowPreprocessor, ...
     configuredObservationPointsPreprocessor, ...
     configuredGkkf}, evaluationCriterion, 5, ...
    {'127.0.0.1',1});

experiment.addEvaluation(evaluate);
experiment.startBatch(16,8,24);
% experiment.startLocal