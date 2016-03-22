close all;

Common.clearClasses();
clear variables;
%clear all;
clc;

%MySQL.mym('closeall');

category = 'evalDoubleLinkWindowPrediction';
%category = 'test';
experimentName = 'CeokkfDoubleLinkSwingDown';

% set some variables
numElem = num2cell(cumsum([10;40;50;100;300]));
numIterations = 1;
numTrials = 20;

% create a task
configuredTask = Experiments.Tasks.DoubleLinkSwingDownTask(false);

configuredNoisePreprocessor = Experiments.Preprocessor.NoisePreprocessorConfigurator('noisePreprocessorConfigurator');
configuredWindowPreprocessor = Experiments.Preprocessor.WindowPreprocessorConfigurator('windowPreprocessorConfigurator');

configuredObservationPointsPreprocessor = Experiments.Preprocessor.ObservationPointsPreprocessorConfigurator('observationPointsPreprocessorConfigurator');

configuredCeokkf = Experiments.Filter.CEOKernelKalmanFilterConfigurator('ceokkfConfigurator');

settings = Common.Settings();
settings.setProperty('observationIndex',1:8);
evaluationCriterion = Experiments.EvaluationCriterion();
evaluationCriterion.registerEvaluator(Evaluator.WindowPredictionEvaluator());

evaluate = Experiments.Evaluation(...
    {'settings.numSamplesEpisodes'},numElem,numIterations,numTrials);

evaluate.setDefaultParameter('settings.Noise_std', 1e-2);
evaluate.setDefaultParameter('settings.Noise_mode', 0);
evaluate.setDefaultParameter('settings.dt',1e-1);
%evaluate.setDefaultParameter('settings.numSamplesEpisodes',[10 40 50 100 300]);
evaluate.setDefaultParameter('settings.numTimeSteps',30);

% general settings
evaluate.setDefaultParameter('settings.windowSize', 8);
evaluate.setDefaultParameter('settings.observationIndex', 1:8);

% observation noise settings
noisePreproName = 'noisePrepro';
evaluate.setDefaultParameter('settings.noisePreprocessor_sigma', 1e-4);
evaluate.setDefaultParameter('settings.noisePreprocessor_inputNames', {'endEffPositions'});

evaluate.setDefaultParameter('settings.observationPointsPreprocessor_observationIndices',[1:30]);


% window settings
windowsPreproName = 'windowsPrepro';
evaluate.setDefaultParameter('settings.windowPreprocessor_inputNames', {'endEffPositionsNoisy', 'endEffPositions'});
evaluate.setDefaultParameter('settings.windowPreprocessor_indexPoint', 1);


% gkkfLearner Settings
evaluate.setDefaultParameter('settings.filterLearner_outputDataName', 'endEffPositionsNoisy');
evaluate.setDefaultParameter('settings.filterLearner_featureName', 'endEffPositionsNoisyWindows');
evaluate.setDefaultParameter('settings.filterLearner_observations', {'endEffPositionsNoisyWindows', 'obsPoints'});
evaluate.setDefaultParameter('settings.filterLearner_featureSize', 8);% pca_features);
evaluate.setDefaultParameter('settings.filterLearner_sigma', 1e-6);
evaluate.setDefaultParameter('settings.filterLearner_lambda', 1e-6);
evaluate.setDefaultParameter('settings.filterLearner_q', .0001);
evaluate.setDefaultParameter('settings.filterLearner_r', .0003);
evaluate.setDefaultParameter('settings.filterLearner_windowPrediction',true);

evaluate.setDefaultParameter('settings.CEOKKF_windowSize',4);

evaluate.setDefaultParameter('settings.kernelReferenceSet_kernelMedianBandwidthFactor', 1);

% referenceSet settings
% evaluate.setDefaultParameter('settings.kernelReferenceSet_maxSizeReferenceSet', 200);
evaluate.setDefaultParameter('settings.kernelReferenceSet_inputDataEntry', 'endEffPositionsNoisyWindows');
evaluate.setDefaultParameter('settings.kernelReferenceSet_validityDataEntry', 'endEffPositionsNoisyWindowsValid');

% optimization settings
evaluate.setDefaultParameter('settings.ceokkfOptimizer_inputDataEntry','endEffPositionsWindows');
evaluate.setDefaultParameter('settings.groundtruthName','endEffPositionsWindows');
evaluate.setDefaultParameter('settings.CMAOptimizerInitialRangeCEOKKF_CMAES_optimization', .05);
evaluate.setDefaultParameter('settings.maxNumOptiIterationsCEOKKF_CMAES_optimization', 200);

evaluate.setDefaultParameter('evaluationGroundtruth','endEffPositionsWindows');
evaluate.setDefaultParameter('evaluationObservations','endEffPositionsNoisyWindows');
evaluate.setDefaultParameter('evaluationValid','endEffPositionsNoisyWindowsValid');

experiment = Experiments.Experiment.createByNameNew(experimentName, category, ...
     {configuredTask, configuredNoisePreprocessor, configuredWindowPreprocessor, ...
     configuredObservationPointsPreprocessor, configuredCeokkf}, evaluationCriterion, 5, ...
    {'127.0.0.1',1});

experiment.addEvaluation(evaluate);
experiment.startBatch(16,8);
% experiment.startLocal