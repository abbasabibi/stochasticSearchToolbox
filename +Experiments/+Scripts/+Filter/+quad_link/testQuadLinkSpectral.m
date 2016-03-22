close all;

Common.clearClasses();
clear variables;
clc;


category = 'evalQuadLink';
experimentName = 'SPECTRAL';

% set some variables
kernelSize = { 600
               800
              1000
              1200
              1400};
kernelSize = repmat(kernelSize,1,3);
numIterations = 5;
numTrials = 20;

% create a task
configuredTask = Experiments.Tasks.QuadLinkSwingDownTask(false);

configuredWindowAliasAdder = Experiments.Filter.AddDataAliasConfigurator('windowAliasAdder');

configuredValidAliasAdder = Experiments.Filter.AddDataAliasConfigurator('validAliasAdder');

configuredNoisePreprocessor = Experiments.Preprocessor.NoisePreprocessorConfigurator('noisePreproConf');
configuredWindowPreprocessor = Experiments.Preprocessor.WindowPreprocessorConfigurator('windowPreproConf');

configuredObservationPointsPreprocessor = Experiments.Preprocessor.ObservationPointsPreprocessorConfigurator('obsPointsPreproConf');

configuredLinearTransformFeature = Experiments.Features.FeatureLinearTransform();
configuredFeatureLearner = Experiments.FeatureLearner.FeatureLearner('stateFeatures');

configuredSpectral = Experiments.Filter.SpectralFilterConfiguratorNoOpt('spectralConf');

evaluationCriterion = Experiments.EvaluationCriterion();
evaluationCriterion.registerEvaluator(Evaluator.WindowPredictionEvaluator());
evaluationCriterion.registerEvaluator(Evaluator.FilterTimeEvaluator());

evaluate = Experiments.Evaluation(...
    {'settings.state1KRS_maxSizeReferenceSet','settings.state2KRS_maxSizeReferenceSet','settings.state3KRS_maxSizeReferenceSet'},kernelSize,numIterations,numTrials);

evaluate.setDefaultParameter('settings.Noise_std', 1);
evaluate.setDefaultParameter('settings.Noise_mode', 0);
evaluate.setDefaultParameter('settings.dt',1e-1);
evaluate.setDefaultParameter('settings.numSamplesEpisodes',[200 200 200 200 200]);
evaluate.setDefaultParameter('settings.numTimeSteps',47);

evaluate.setDefaultParameter('windowAliasAdderAliasNames', {'x1', 'x2', 'x3'});
evaluate.setDefaultParameter('windowAliasAdderAliasTargets', {'endEffPositionsNoisyWindows','endEffPositionsNoisyWindows','endEffPositionsNoisyWindows'});
evaluate.setDefaultParameter('windowAliasAdderAliasIndices', {1:16, 3:18, 5:20});

% general settings
% evaluate.setDefaultParameter('settings.windowSize', 8);
% evaluate.setDefaultParameter('settings.observationIndex', 1);

% observation noise settings
evaluate.setDefaultParameter('settings.noisePreprocessor_sigma', 1e-3);
evaluate.setDefaultParameter('settings.noisePreprocessor_inputNames', {'endEffPositions'});
% evaluate.setDefaultParameter('settings.noisePreprocessor_outputNames', {'thetaNoisy', 'nextThetaNoisy'});

evaluate.setDefaultParameter('settings.observationPointsPreprocessor_observationIndices',[8:43]);


% window settings
evaluate.setDefaultParameter('settings.windowPreprocessor_inputNames', {'endEffPositionsNoisy', 'endEffPositions'});
evaluate.setDefaultParameter('settings.windowPreprocessor_windowSize', {8+2, 4});
evaluate.setDefaultParameter('settings.windowPreprocessor_indexPoint', {8, 1});

evaluate.setDefaultParameter('validAliasAdderAliasNames', {'allValid'});
evaluate.setDefaultParameter('validAliasAdderAliasTargets', {{'endEffPositionsNoisyWindowsValid','endEffPositionsWindowsValid'}});

% referenceSet settings
% settings.setProperty('state1KRS_maxSizeReferenceSet', 100);
% settings.setProperty('state2KRS_maxSizeReferenceSet', 100);
% settings.setProperty('state3KRS_maxSizeReferenceSet', 100);
evaluate.setDefaultParameter('settings.state1KRS_inputDataEntry', 'x1');
evaluate.setDefaultParameter('settings.state1KRS_validityDataEntry', 'endEffPositionsNoisyWindowsValid');
evaluate.setDefaultParameter('settings.state2KRS_inputDataEntry', 'x2');
evaluate.setDefaultParameter('settings.state2KRS_validityDataEntry', 'endEffPositionsNoisyWindowsValid');
evaluate.setDefaultParameter('settings.state3KRS_inputDataEntry', 'x3');
evaluate.setDefaultParameter('settings.state3KRS_validityDataEntry', 'endEffPositionsNoisyWindowsValid');
evaluate.setDefaultParameter('kernelType','ScaledBandwidthExponentialQuadraticKernel');

evaluate.setDefaultParameter('settings.state1KRS_kernelMedianBandwidthFactor', .9);
evaluate.setDefaultParameter('settings.spectralLearner_lambda',exp(-4));
evaluate.setDefaultParameter('filter', @(trial) Filter.WindowPredictionSpectralFilter(trial.dataManager, ...
    trial.windowSize, trial.windowSize, trial.state1KernelReferenceSet, ...
    trial.state2KernelReferenceSet, trial.state3KernelReferenceSet));
evaluate.setDefaultParameter('settings.SpectralFilter_windowSize',4);

evaluate.setDefaultParameter('settings.spectralLearner_observations',{'x1','obsPoints'});
evaluate.setDefaultParameter('settings.spectralLearner_outputDataName','endEffPositionsNoisy');

evaluate.setDefaultParameter('windowSize',16);
evaluate.setDefaultParameter('outputDims',{2});
evaluate.setDefaultParameter('numEigenvectors',300);

% optimization settings
% evaluate.setDefaultParameter('settings.spectralOptimizer_groundtruthName', 'endEffPositionsWindows');
% evaluate.setDefaultParameter('settings.spectralOptimizer_observationIndex', 1:8);
% evaluate.setDefaultParameter('settings.CMAOptimizerInitialRangeSpectral_CMAES_optimization', .05);
% evaluate.setDefaultParameter('settings.maxNumOptiIterationsSpectral_CMAES_optimization', 20);

evaluate.setDefaultParameter('evaluationGroundtruth','endEffPositionsWindows');
evaluate.setDefaultParameter('evaluationObservations','x1');
evaluate.setDefaultParameter('evaluationObservationIndex',1:8);
evaluate.setDefaultParameter('evaluationValid','allValid');
evaluate.setDefaultParameter('evaluationMetric','euclidean');


experiment = Experiments.Experiment.createByNameNew(experimentName, category, ...
     {configuredTask, configuredNoisePreprocessor, configuredWindowPreprocessor, ...
     configuredWindowAliasAdder, configuredValidAliasAdder, ...
     configuredObservationPointsPreprocessor, configuredSpectral}, ...
     evaluationCriterion, 5, {'127.0.0.1',1});

experiment.addEvaluation(evaluate);
experiment.startBatch(32,8);
% experiment.startLocal