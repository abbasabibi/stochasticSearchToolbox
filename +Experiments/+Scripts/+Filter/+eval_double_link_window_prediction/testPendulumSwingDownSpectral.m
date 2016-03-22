close all;

Common.clearClasses();
clear variables;
%clear all;
clc;

%MySQL.mym('closeall');

category = 'evalDoubleLinkWindowPrediction';
%category = 'test';
experimentName = 'SpectralDoubleLinkSwingDown';

% set some variables
numEigenvectors = {5; 10; 15; 20; 30};
numIterations = 5;
numTrials = 20;

% create a task
configuredTask = Experiments.Tasks.DoubleLinkSwingDownTask(false);

configuredWindowAliasAdder = Experiments.Filter.AddDataAliasConfigurator('windowAliasAdder');

configuredNoisePreprocessor = Experiments.Preprocessor.NoisePreprocessorConfigurator('noisePreprocessorConfigurator');
configuredWindowPreprocessor = Experiments.Preprocessor.WindowPreprocessorConfigurator('windowPreprocessorConfigurator');

configuredObservationPointsPreprocessor = Experiments.Preprocessor.ObservationPointsPreprocessorConfigurator('observationPointsPreprocessorConfigurator');

configuredLinearTransformFeature = Experiments.Features.FeatureLinearTransform();
configuredFeatureLearner = Experiments.FeatureLearner.FeatureLearner('stateFeatures');

configuredSpectral = Experiments.Filter.SpectralFilterConfigurator('spectralConfigurator');

settings = Common.Settings();
settings.setProperty('observationIndex',1:8);
evaluationCriterion = Experiments.EvaluationCriterion();
evaluationCriterion.registerEvaluator(Evaluator.WindowPredictionEvaluator());

evaluate = Experiments.Evaluation(...
    {'numEigenvectors'},numEigenvectors,numIterations,numTrials);

evaluate.setDefaultParameter('filter',@(trial) Filter.WindowPredictionSpectralFilter(trial.dataManager, trial.windowSize, trial.windowSize, trial.state1KernelReferenceSet, trial.state2KernelReferenceSet, trial.state3KernelReferenceSet));

evaluate.setDefaultParameter('settings.Noise_std', 1e-2);
evaluate.setDefaultParameter('settings.Noise_mode', 0);
evaluate.setDefaultParameter('settings.dt',1e-1);
evaluate.setDefaultParameter('settings.numSamplesEpisodes',[10 40 50 100 300]);
evaluate.setDefaultParameter('settings.numTimeSteps',30);

evaluate.setDefaultParameter('windowAliasAdderAliasNames', {'x1', 'x2', 'x3', 'x1g'});
evaluate.setDefaultParameter('windowAliasAdderAliasTargets', {'endEffPositionsNoisyWindows','endEffPositionsNoisyWindows','endEffPositionsNoisyWindows','endEffPositionsWindows'});
evaluate.setDefaultParameter('windowAliasAdderAliasIndices', {1:8, 3:10, 5:12, 1:8});

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
% settings.registerAlias([windowsPreproName '_indexPoint'], 'observationIndex');
evaluate.setDefaultParameter('settings.windowPreprocessor_indexPoint', 1);
evaluate.setDefaultParameter('settings.windowPreprocessor_windowSize', 6);

% referenceSet settings
evaluate.setDefaultParameter('state1KRS_maxSizeReferenceSet', 1000);
evaluate.setDefaultParameter('state2KRS_maxSizeReferenceSet', 1000);
evaluate.setDefaultParameter('state3KRS_maxSizeReferenceSet', 1000);
evaluate.setDefaultParameter('settings.state1KRS_inputDataEntry', 'x1');
evaluate.setDefaultParameter('settings.state1KRS_validityDataEntry', 'endEffPositionsNoisyWindowsValid');
evaluate.setDefaultParameter('settings.state2KRS_inputDataEntry', 'x2');
evaluate.setDefaultParameter('settings.state2KRS_validityDataEntry', 'endEffPositionsNoisyWindowsValid');
evaluate.setDefaultParameter('settings.state3KRS_inputDataEntry', 'x3');
evaluate.setDefaultParameter('settings.state3KRS_validityDataEntry', 'endEffPositionsNoisyWindowsValid');

evaluate.setDefaultParameter('settings.spectralLearner_observations',{'x1','obsPoints'});
evaluate.setDefaultParameter('settings.spectralLearner_outputDataName','endEffPositionsNoisy');

evaluate.setDefaultParameter('settings.spectralFilter_windowSize',4);

% optimization settings
evaluate.setDefaultParameter('settings.spectralOptimizer_inputDataEntry','endEffPositionsWindows');
evaluate.setDefaultParameter('settings.groundtruthName','x1g');
evaluate.setDefaultParameter('settings.CMAOptimizerInitialRangeSpectral_CMAES_optimization', .05);
evaluate.setDefaultParameter('settings.maxNumOptiIterationsSpectral_CMAES_optimization', 200);

evaluate.setDefaultParameter('windowSize',8);
evaluate.setDefaultParameter('outputDims',2);
% evaluate.setDefaultParameter('numEigenvectors',15);

evaluate.setDefaultParameter('evaluationGroundtruth','x1g');
evaluate.setDefaultParameter('evaluationObservations','x1');
evaluate.setDefaultParameter('evaluationValid','endEffPositionsNoisyWindowsValid');


experiment = Experiments.Experiment.createByNameNew(experimentName, category, ...
     {configuredTask, configuredNoisePreprocessor, ...
     configuredWindowPreprocessor, configuredWindowAliasAdder, ...
     configuredObservationPointsPreprocessor, configuredSpectral}, ...
     evaluationCriterion, 5, {'127.0.0.1',1});

experiment.addEvaluation(evaluate);
experiment.startBatch(16,8);
% experiment.startLocal