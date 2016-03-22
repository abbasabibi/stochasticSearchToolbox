close all;

Common.clearClasses();
clear variables;
%clear all;
clc;

%MySQL.mym('closeall');

category = 'evalWindowPrediction';
%category = 'test';
experimentName = 'CeokkfPendulumSwingDown';

% set some variables
winRefSizes = {200};
numIterations = 5;
numTrials = 20;

% create a task
configuredTask = Experiments.Tasks.SwingDownTask(false);

configuredAliasAdder = Experiments.Filter.AddDataAliasConfigurator('stateAliasAdder');

configuredNoisePreprocessor = Experiments.Preprocessor.NoisePreprocessorConfigurator('noisePreprocessorConfigurator');
configuredWindowPreprocessor = Experiments.Preprocessor.WindowPreprocessorConfigurator('windowPreprocessorConfigurator');

configuredObservationPointsPreprocessor = Experiments.Preprocessor.ObservationPointsPreprocessorConfigurator('observationPointsPreprocessorConfigurator');

configuredCeokkf = Experiments.Filter.CEOKernelKalmanFilterConfigurator('ceokkfConfigurator');

settings = Common.Settings();
settings.setProperty('observationIndex',1:4);
evaluationCriterion = Experiments.EvaluationCriterion();
evaluationCriterion.registerEvaluator(Evaluator.WindowPredictionEvaluator());

evaluate = Experiments.Evaluation(...
    {'settings.kernelReferenceSet_maxSizeReferenceSet'},winRefSizes,numIterations,numTrials);

evaluate.setDefaultParameter('settings.Noise_std', 1);
evaluate.setDefaultParameter('settings.Noise_mode', 0);
evaluate.setDefaultParameter('settings.dt',1e-1);
evaluate.setDefaultParameter('settings.numSamplesEpisodes',[10 10 30 50 100]);
evaluate.setDefaultParameter('settings.numTimeSteps',30);

evaluate.setDefaultParameter('stateAliasAdderAliasNames', {'theta'});
evaluate.setDefaultParameter('stateAliasAdderAliasTargets', {'states'});
evaluate.setDefaultParameter('stateAliasAdderAliasIndices', {1});

% general settings
evaluate.setDefaultParameter('settings.windowSize', 4);
evaluate.setDefaultParameter('settings.observationIndex', 1:4);

% observation noise settings
noisePreproName = 'noisePrepro';
evaluate.setDefaultParameter('settings.noisePreprocessor_sigma', 1e-2);
evaluate.setDefaultParameter('settings.noisePreprocessor_inputNames', {'theta'});
% evaluate.setDefaultParameter('settings.noisePreprocessor_outputNames', {'thetaNoisy', 'nextThetaNoisy'});

evaluate.setDefaultParameter('settings.observationPointsPreprocessor_observationIndices',[1:30]);


% window settings
windowsPreproName = 'windowsPrepro';
evaluate.setDefaultParameter('settings.windowPreprocessor_inputNames', {'thetaNoisy', 'theta'});
% settings.registerAlias([windowsPreproName '_indexPoint'], 'observationIndex');
evaluate.setDefaultParameter('settings.windowPreprocessor_indexPoint', 1);


% gkkfLearner Settings
evaluate.setDefaultParameter('settings.filterLearner_outputDataName', 'thetaNoisy');
evaluate.setDefaultParameter('settings.filterLearner_featureName', 'thetaNoisyWindows');
evaluate.setDefaultParameter('settings.filterLearner_observations', {'thetaNoisyWindows', 'obsPoints'});
evaluate.setDefaultParameter('settings.filterLearner_featureSize', 4);% pca_features);
evaluate.setDefaultParameter('settings.filterLearner_sigma', 1e-6);
evaluate.setDefaultParameter('settings.filterLearner_lambda', 1e-6);
evaluate.setDefaultParameter('settings.filterLearner_q', .0001);
evaluate.setDefaultParameter('settings.filterLearner_r', .0003);
evaluate.setDefaultParameter('settings.filterLearner_windowPrediction',true);

evaluate.setDefaultParameter('settings.CEOKKF_windowSize',4);

evaluate.setDefaultParameter('settings.kernelReferenceSet_kernelMedianBandwidthFactor', 1);

% referenceSet settings
% evaluate.setDefaultParameter('settings.kernelReferenceSet_maxSizeReferenceSet', 200);
evaluate.setDefaultParameter('settings.kernelReferenceSet_inputDataEntry', 'thetaNoisyWindows');
evaluate.setDefaultParameter('settings.kernelReferenceSet_validityDataEntry', 'thetaNoisyWindowsValid');

% optimization settings
evaluate.setDefaultParameter('settings.ceokkfOptimizer_inputDataEntry','thetaWindows');
evaluate.setDefaultParameter('settings.groundtruthName','thetaWindows');
evaluate.setDefaultParameter('settings.CMAOptimizerInitialRangeCEOKKF_CMAES_optimization', .05);
evaluate.setDefaultParameter('settings.maxNumOptiIterationsCEOKKF_CMAES_optimization', 200);

evaluate.setDefaultParameter('evaluationGroundtruth','thetaWindows');
evaluate.setDefaultParameter('evaluationObservations','thetaNoisyWindows');
evaluate.setDefaultParameter('evaluationValid','thetaNoisyWindowsValid');

experiment = Experiments.Experiment.createByNameNew(experimentName, category, ...
     {configuredTask, configuredAliasAdder, configuredNoisePreprocessor, configuredWindowPreprocessor, configuredObservationPointsPreprocessor, configuredCeokkf}, evaluationCriterion, 5, ...
    {'127.0.0.1',1});

experiment.addEvaluation(evaluate);
experiment.startBatch(16,8);
% experiment.startLocal