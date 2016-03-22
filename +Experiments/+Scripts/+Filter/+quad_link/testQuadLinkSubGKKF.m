close all;

Common.clearClasses();
clear variables;
clc;


category = 'evalQuadLink';
experimentName = 'SubGKKF';

% set some variables
kernelSize = { 600
               800
              1000
              1200
              1400};
numIterations = 5;
numTrials = 20;

% create a task
configuredTask = Experiments.Tasks.QuadLinkSwingDownTask(false);

configuredNoisePreprocessor = Experiments.Preprocessor.NoisePreprocessorConfigurator('noisePreproConf');
configuredWindowPreprocessor = Experiments.Preprocessor.WindowPreprocessorConfigurator('winPreproConf');

configuredObservationPointsPreprocessor = Experiments.Preprocessor.ObservationPointsPreprocessorConfigurator('obsPointsPreproConf');

configuredGkkf = Experiments.Filter.GeneralizedKernelKalmanFilterConfiguratorNoOpt('gkkfConf');

evaluationCriterion = Experiments.EvaluationCriterion();
evaluationCriterion.registerEvaluator(Evaluator.WindowPredictionEvaluator());
evaluationCriterion.registerEvaluator(Evaluator.FilterTimeEvaluator());

evaluate = Experiments.Evaluation(...
    {'settings.reducedKRS_maxSizeReferenceSet'},kernelSize,numIterations,numTrials);

evaluate.setDefaultParameter('settings.Noise_std', .1);
evaluate.setDefaultParameter('settings.Noise_mode', 0);
evaluate.setDefaultParameter('settings.dt',1e-1);
evaluate.setDefaultParameter('settings.numSamplesEpisodes',[200 200 200 200 200]);
evaluate.setDefaultParameter('settings.numTimeSteps',43);

% observation noise settings
evaluate.setDefaultParameter('settings.noisePreprocessor_sigma', 1e-3);
evaluate.setDefaultParameter('settings.noisePreprocessor_inputNames', {'endEffPositions'});
% evaluate.setDefaultParameter('settings.noisePreprocessor_outputNames', {'thetaNoisy', 'nextThetaNoisy'});

evaluate.setDefaultParameter('settings.observationPointsPreprocessor_observationIndices',[1:35]);


% window settings
evaluate.setDefaultParameter('settings.windowPreprocessor_inputNames', {'endEffPositionsNoisy', 'endEffPositions'});
evaluate.setDefaultParameter('settings.windowPreprocessor_windowSize', {8, 4});
evaluate.setDefaultParameter('settings.windowPreprocessor_indexPoint', 1);


% gkkfLearner Settings
evaluate.setDefaultParameter('settings.filterLearner_outputDataName', {'endEffPositionsNoisy'});
evaluate.setDefaultParameter('settings.filterLearner_stateFeatureName', 'endEffPositionsNoisyWindows');
evaluate.setDefaultParameter('settings.filterLearner_obsFeatureName', 'endEffPositionsNoisy');
evaluate.setDefaultParameter('settings.filterLearner_stateFeatureSize', 16);
evaluate.setDefaultParameter('settings.filterLearner_obsFeatureSize', 2);
evaluate.setDefaultParameter('settings.filterLearner_observations', {'endEffPositionsNoisy','obsPoints'});
evaluate.setDefaultParameter('settings.filterLearner_stateKernelType', 'ScaledBandwidthExponentialQuadraticKernel');
evaluate.setDefaultParameter('settings.filterLearner_obsKernelType', 'ScaledBandwidthExponentialQuadraticKernel');
evaluate.setDefaultParameter('settings.filterLearner_conditionalOperatorType','reg');
evaluate.setDefaultParameter('settings.filterLearner_referenceSetLearnerType','greedy');

evaluate.setDefaultParameter('settings.filterLearner_windowPrediction',true);
evaluate.setDefaultParameter('settings.GKKF_windowSize',4);

evaluate.setDefaultParameter('settings.GKKF_kappa',exp(-9));
evaluate.setDefaultParameter('settings.GKKF_lambdaO',exp(-12));
evaluate.setDefaultParameter('settings.GKKF_lambdaT',exp(-12));

evaluate.setDefaultParameter('settings.stateKRS_kernelMedianBandwidthFactor', 1);
evaluate.setDefaultParameter('settings.obsKRS_kernelMedianBandwidthFactor', .5);

% referenceSet settings
evaluate.setDefaultParameter('settings.stateKRS_maxSizeReferenceSet', 5000);
evaluate.setDefaultParameter('settings.obsKRS_maxSizeReferenceSet', 5000);
% evaluate.setDefaultParameter('settings.reducedKRS_maxSizeReferenceSet', 100);
evaluate.setDefaultParameter('settings.stateKRS_inputDataEntry', 'endEffPositionsNoisyWindows');
evaluate.setDefaultParameter('settings.stateKRS_validityDataEntry', 'endEffPositionsNoisyWindowsValid');
evaluate.setDefaultParameter('settings.obsKRS_inputDataEntry', 'endEffPositionsNoisy');
evaluate.setDefaultParameter('settings.obsKRS_validityDataEntry', 'endEffPositionsNoisyWindowsValid');
evaluate.setDefaultParameter('settings.reducedKRS_inputDataEntry', 'endEffPositionsNoisyWindows');
evaluate.setDefaultParameter('settings.reducedKRS_validityDataEntry', 'endEffPositionsNoisyWindowsValid');

evaluate.setDefaultParameter('settings.reducedKRS_parentReferenceSetIndicator','stateKRSIndicator');
evaluate.setDefaultParameter('settings.obsKRS_parentReferenceSetIndicator','stateKRSIndicator');

% optimization settings
% evaluate.setDefaultParameter('settings.GKKF_CMAES_optimization_groundtruthName','theta');
% evaluate.setDefaultParameter('settings.GKKF_CMAES_optimization_observationIndex',1);
% evaluate.setDefaultParameter('settings.GKKF_CMAES_optimization_validityDataEntry','thetaNoisyWindowsValid');
% evaluate.setDefaultParameter('settings.GKKF_CMAES_optimization_internalObjective','mse');
% evaluate.setDefaultParameter('settings.CMAOptimizerInitialRangeGKKF_CMAES_optimization', .05);
% evaluate.setDefaultParameter('settings.maxNumOptiIterationsGKKF_CMAES_optimization', 50);

% evaluation settings
evaluate.setDefaultParameter('evaluationGroundtruth','endEffPositionsWindows');
evaluate.setDefaultParameter('evaluationObservations',{'endEffPositionsNoisy' 'obsPoints'});
evaluate.setDefaultParameter('evaluationValid','endEffPositionsWindowsValid');
evaluate.setDefaultParameter('evaluationObservationIndex',1:8);
evaluate.setDefaultParameter('evaluationMetric','euclidean');


experiment = Experiments.Experiment.createByNameNew(experimentName, category, ...
     {configuredTask, configuredNoisePreprocessor, configuredWindowPreprocessor, ...
     configuredObservationPointsPreprocessor, configuredGkkf}, evaluationCriterion, 5, ...
    {'127.0.0.1',1});

experiment.addEvaluation(evaluate);
experiment.startBatch(32,8);
% experiment.startLocal