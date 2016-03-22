close all;

Common.clearClasses();
clear variables;
clc;


category = 'evalPendulum';
experimentName = 'CEOKKF';

% set some variables
kernelSize = { 50  50
              100 100
              150 150
              200 200
              250 250};
numIterations = 6;
numTrials = 20;

% create a task
configuredTask = Experiments.Tasks.SwingDownTask(false);

configuredAliasAdder = Experiments.Filter.AddDataAliasConfigurator('stateAliasAdder');

configuredNoisePreprocessor = Experiments.Preprocessor.NoisePreprocessorConfigurator('noisePreproConf');
configuredWindowPreprocessor = Experiments.Preprocessor.WindowPreprocessorConfigurator('windowPreprConf');

configuredObservationPointsPreprocessor = Experiments.Preprocessor.ObservationPointsPreprocessorConfigurator('obsPointsPreproConf');

configuredCeokkf = Experiments.Filter.CEOKernelKalmanFilterConfiguratorNoOpt('ceokkfConf');

evaluationCriterion = Experiments.EvaluationCriterion();
evaluationCriterion.registerEvaluator(Evaluator.FilteredDataEvaluator());

evaluate = Experiments.Evaluation(...
    {'settings.kernelReferenceSet_maxSizeReferenceSet'},kernelSize,numIterations,numTrials);

evaluate.setDefaultParameter('settings.Noise_std', 1);
evaluate.setDefaultParameter('settings.Noise_mode', 0);
evaluate.setDefaultParameter('settings.dt',1e-1);
evaluate.setDefaultParameter('settings.numSamplesEpisodes',[5 5 10 10 20 50]);
evaluate.setDefaultParameter('settings.numTimeSteps',30);

evaluate.setDefaultParameter('stateAliasAdderAliasNames', {'theta'});
evaluate.setDefaultParameter('stateAliasAdderAliasTargets', {'states'});
evaluate.setDefaultParameter('stateAliasAdderAliasIndices', {1});

% observation noise settings
evaluate.setDefaultParameter('settings.noisePreprocessor_sigma', 1e-2);
evaluate.setDefaultParameter('settings.noisePreprocessor_inputNames', {'theta'});
% evaluate.setDefaultParameter('settings.noisePreprocessor_outputNames', {'thetaNoisy', 'nextThetaNoisy'});

evaluate.setDefaultParameter('settings.observationPointsPreprocessor_observationIndices',[1:30]);


% window settings
evaluate.setDefaultParameter('settings.windowPreprocessor_inputNames', {'thetaNoisy', 'theta'});
evaluate.setDefaultParameter('settings.windowPreprocessor_windowSize', 1);
evaluate.setDefaultParameter('settings.windowPreprocessor_indexPoint', 1);


% gkkfLearner Settings
evaluate.setDefaultParameter('settings.filterLearner_outputDataName', {'thetaNoisyWindows'});
evaluate.setDefaultParameter('settings.filterLearner_featureName', 'thetaNoisyWindows');
evaluate.setDefaultParameter('settings.filterLearner_observations', {'thetaNoisyWindows', 'obsPoints'});
evaluate.setDefaultParameter('settings.filterLearner_featureSize', 1);
evaluate.setDefaultParameter('settings.filterLearner_stateKernelType', 'ScaledBandwidthExponentialQuadraticKernel');
evaluate.setDefaultParameter('settings.filterLearner_referenceSetLearnerType','greedy');

evaluate.setDefaultParameter('settings.filterLearner_sigma', 1e-15);
evaluate.setDefaultParameter('settings.filterLearner_lambda', 1.6e-1);
evaluate.setDefaultParameter('settings.filterLearner_q', 3.5);
evaluate.setDefaultParameter('settings.filterLearner_r', 9e-1);

evaluate.setDefaultParameter('settings.kernelReferenceSet_kernelMedianBandwidthFactor', 1.9);

% referenceSet settings
% evaluate.setDefaultParameter('settings.kernelReferenceSet_maxSizeReferenceSet', 500);
evaluate.setDefaultParameter('settings.kernelReferenceSet_inputDataEntry', 'thetaNoisyWindows');
evaluate.setDefaultParameter('settings.kernelReferenceSet_validityDataEntry', 'thetaNoisyWindowsValid');

% evaluation settings
evaluate.setDefaultParameter('evaluationGroundtruth','theta');
evaluate.setDefaultParameter('evaluationObservations','thetaNoisyWindows');
evaluate.setDefaultParameter('evaluationValid','thetaNoisyWindowsValid');
evaluate.setDefaultParameter('evaluationObservationIndex',1);

experiment = Experiments.Experiment.createByNameNew(experimentName, category, ...
     {configuredTask, configuredAliasAdder, configuredNoisePreprocessor, ...
     configuredWindowPreprocessor, configuredObservationPointsPreprocessor, ...
     configuredCeokkf}, evaluationCriterion, 5, ...
    {'127.0.0.1',1});

experiment.addEvaluation(evaluate);
experiment.startBatch(32,8);
% experiment.startLocal