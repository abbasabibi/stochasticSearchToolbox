close all;

Common.clearClasses();
clear variables;
clc;


category = 'evalQuadLink';
experimentName = 'CEOKKF';

% set some variables
kernelSize = { 600
               800
              1000
              1200
              1400};
kernelSize = repmat(kernelSize,1,2);
numIterations = 5;
numTrials = 20;

% create a task
configuredTask = Experiments.Tasks.QuadLinkSwingDownTask(false);

configuredValidAliasAdder = Experiments.Filter.AddDataAliasConfigurator('validAliasAdder');

configuredNoisePreprocessor = Experiments.Preprocessor.NoisePreprocessorConfigurator('noisePreproConf');
configuredWindowPreprocessor = Experiments.Preprocessor.WindowPreprocessorConfigurator('windowPreprConf');

configuredObservationPointsPreprocessor = Experiments.Preprocessor.ObservationPointsPreprocessorConfigurator('obsPointsPreproConf');

configuredCeokkf = Experiments.Filter.CEOKernelKalmanFilterConfiguratorNoOpt('ceokkfConf');

evaluationCriterion = Experiments.EvaluationCriterion();
evaluationCriterion.registerEvaluator(Evaluator.WindowPredictionEvaluator());
evaluationCriterion.registerEvaluator(Evaluator.FilterTimeEvaluator());

evaluate = Experiments.Evaluation(...
    {'settings.kernelReferenceSet_maxSizeReferenceSet'},kernelSize,numIterations,numTrials);

evaluate.setDefaultParameter('settings.Noise_std', .1);
evaluate.setDefaultParameter('settings.Noise_mode', 0);
evaluate.setDefaultParameter('settings.dt',1e-1);
evaluate.setDefaultParameter('settings.numSamplesEpisodes',[200 200 200 200 200]);
evaluate.setDefaultParameter('settings.numTimeSteps',43);

% observation noise settings
evaluate.setDefaultParameter('settings.noisePreprocessor_sigma', 1e-3);
evaluate.setDefaultParameter('settings.noisePreprocessor_inputNames', {'endEffPositions'});
% evaluate.setDefaultParameter('settings.noisePreprocessor_outputNames', {'thetaNoisy', 'nextThetaNoisy'});

evaluate.setDefaultParameter('settings.observationPointsPreprocessor_observationIndices',[8:43]);


% window settings
evaluate.setDefaultParameter('settings.windowPreprocessor_inputNames', {'endEffPositionsNoisy', 'endEffPositions'});
evaluate.setDefaultParameter('settings.windowPreprocessor_windowSize', {8, 4});
evaluate.setDefaultParameter('settings.windowPreprocessor_indexPoint', {8, 1});

evaluate.setDefaultParameter('validAliasAdderAliasNames', {'allValid'});
evaluate.setDefaultParameter('validAliasAdderAliasTargets', {{'endEffPositionsNoisyWindowsValid','endEffPositionsWindowsValid'}});
% evaluate.setDefaultParameter('validAliasAdderAliasIndices', {});

% gkkfLearner Settings
evaluate.setDefaultParameter('settings.filterLearner_outputDataName', {'endEffPositionsNoisyWindows'});
evaluate.setDefaultParameter('settings.filterLearner_featureName', 'endEffPositionsNoisyWindows');
evaluate.setDefaultParameter('settings.filterLearner_observations', {'endEffPositionsNoisyWindows', 'obsPoints'});
evaluate.setDefaultParameter('settings.filterLearner_featureSize', 16);
evaluate.setDefaultParameter('settings.filterLearner_kernelType', 'ScaledBandwidthExponentialQuadraticKernel');
evaluate.setDefaultParameter('settings.filterLearner_referenceSetLearnerType','greedy');


evaluate.setDefaultParameter('settings.filterLearner_windowPrediction',true);
evaluate.setDefaultParameter('settings.CEOKKF_windowSize',4);

evaluate.setDefaultParameter('settings.filterLearner_sigma', exp(-20));
evaluate.setDefaultParameter('settings.filterLearner_lambda', exp(-16));
evaluate.setDefaultParameter('settings.filterLearner_q', exp(-7.6));
evaluate.setDefaultParameter('settings.filterLearner_r', exp(-7.8));

evaluate.setDefaultParameter('settings.kernelReferenceSet_kernelMedianBandwidthFactor', .86);

% referenceSet settings
% evaluate.setDefaultParameter('settings.kernelReferenceSet_maxSizeReferenceSet', 500);
evaluate.setDefaultParameter('settings.kernelReferenceSet_inputDataEntry', 'endEffPositionsNoisyWindows');
evaluate.setDefaultParameter('settings.kernelReferenceSet_validityDataEntry', 'endEffPositionsNoisyWindowsValid');

% optimization settings
% evaluate.setDefaultParameter('settings.ceokkfOptimizer_groundtruthName','endEffPositionsWindows');
% evaluate.setDefaultParameter('settings.ceokkfOptimizer_observationIndex',[15 16 31 32 47 48 63 64]);
% evaluate.setDefaultParameter('settings.ceokkfOptimizer_validityDataEntry','allValid');
% evaluate.setDefaultParameter('settings.ceokkfOptimizer_internalObjective','euclidean');
% evaluate.setDefaultParameter('settings.CMAOptimizerInitialRangeCEOKKF_CMAES_optimization', 0.05);
% evaluate.setDefaultParameter('settings.maxNumOptiIterationsCEOKKF_CMAES_optimization', 50);

% evaluation settings
evaluate.setDefaultParameter('evaluationGroundtruth','endEffPositionsWindows');
evaluate.setDefaultParameter('evaluationObservations',{'endEffPositionsNoisyWindows' 'obsPoints'});
evaluate.setDefaultParameter('evaluationValid','allValid');
evaluate.setDefaultParameter('evaluationObservationIndex',[15 16 31 32 47 48 63 64]);

evaluate.setDefaultParameter('evaluationMetric','euclidean');

experiment = Experiments.Experiment.createByNameNew(experimentName, category, ...
     {configuredTask, configuredNoisePreprocessor, configuredWindowPreprocessor, ...
     configuredValidAliasAdder, configuredObservationPointsPreprocessor, ...
     configuredCeokkf}, evaluationCriterion, 5, ...
    {'127.0.0.1',1});

experiment.addEvaluation(evaluate);
experiment.startBatch(32,8);
% experiment.startLocal