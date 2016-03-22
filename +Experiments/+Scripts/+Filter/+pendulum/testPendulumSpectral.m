close all;

Common.clearClasses();
clear variables;
clc;


category = 'evalPendulum';
experimentName = 'SPECTRAL';

% set some variables
kernelSize = repmat( ...
             {  25
                50
                75
               100
               150
               300
               500},1,3);
numEigenvectors = {20
                   40
                   40
                   40
                   40
                   40
                   40};
numIterations = 7;
numTrials = 20;

% create a task
configuredTask = Experiments.Tasks.SwingDownTask(false);

configuredStateAliasAdder = Experiments.Filter.AddDataAliasConfigurator('stateAliasAdder');
configuredWindowAliasAdder = Experiments.Filter.AddDataAliasConfigurator('windowAliasAdder');

configuredNoisePreprocessor = Experiments.Preprocessor.NoisePreprocessorConfigurator('noisePreproConf');
configuredWindowPreprocessor = Experiments.Preprocessor.WindowPreprocessorConfigurator('windowPreproConf');

configuredObservationPointsPreprocessor = Experiments.Preprocessor.ObservationPointsPreprocessorConfigurator('obsPointsPreproConf');

configuredLinearTransformFeature = Experiments.Features.FeatureLinearTransform();
configuredFeatureLearner = Experiments.FeatureLearner.FeatureLearner('stateFeatures');

configuredSpectral = Experiments.Filter.SpectralFilterConfigurator('spectralConf');

evaluationCriterion = Experiments.EvaluationCriterion();
evaluationCriterion.registerEvaluator(Evaluator.FilteredDataEvaluator());
evaluationCriterion.registerEvaluator(Evaluator.FilterTimeEvaluator());

evaluate = Experiments.Evaluation(...
    {'settings.state1KRS_maxSizeReferenceSet','settings.state2KRS_maxSizeReferenceSet','settings.state3KRS_maxSizeReferenceSet','numEigenvectors'},cat(2,kernelSize,numEigenvectors),numIterations,numTrials);

evaluate.setDefaultParameter('settings.Noise_std', 1);
evaluate.setDefaultParameter('settings.Noise_mode', 0);
evaluate.setDefaultParameter('settings.dt',1e-1);
evaluate.setDefaultParameter('settings.numSamplesEpisodes',[5 5 15 25 50 150 250]);
evaluate.setDefaultParameter('settings.numTimeSteps',30);

evaluate.setDefaultParameter('stateAliasAdderAliasNames', {'theta'});
evaluate.setDefaultParameter('stateAliasAdderAliasTargets', {'states'});
evaluate.setDefaultParameter('stateAliasAdderAliasIndices', {1});

evaluate.setDefaultParameter('windowAliasAdderAliasNames', {'x1', 'x2', 'x3'});
evaluate.setDefaultParameter('windowAliasAdderAliasTargets', {'thetaNoisyWindows','thetaNoisyWindows','thetaNoisyWindows'});
evaluate.setDefaultParameter('windowAliasAdderAliasIndices', {1:4, 2:4+1, 3:4+2});

% general settings
evaluate.setDefaultParameter('settings.windowSize', 4);
evaluate.setDefaultParameter('settings.observationIndex', 1);

% observation noise settings
evaluate.setDefaultParameter('settings.noisePreprocessor_sigma', 1e-2);
evaluate.setDefaultParameter('settings.noisePreprocessor_inputNames', {'theta'});
% evaluate.setDefaultParameter('settings.noisePreprocessor_outputNames', {'thetaNoisy', 'nextThetaNoisy'});

evaluate.setDefaultParameter('settings.observationPointsPreprocessor_observationIndices',[1:30]);


% window settings
windowsPreproName = 'windowsPrepro';
evaluate.setDefaultParameter('settings.windowPreprocessor_inputNames', {'thetaNoisy', 'theta'});
% settings.registerAlias([windowsPreproName '_indexPoint'], 'observationIndex');
evaluate.setDefaultParameter('settings.windowPreprocessor_indexPoint', 4);
evaluate.setDefaultParameter('settings.windowPreprocessor_windowSize', 4+2);

% referenceSet settings
% settings.setProperty('state1KRS_maxSizeReferenceSet', 100);
% settings.setProperty('state2KRS_maxSizeReferenceSet', 100);
% settings.setProperty('state3KRS_maxSizeReferenceSet', 100);
evaluate.setDefaultParameter('settings.state1KRS_inputDataEntry', 'x1');
evaluate.setDefaultParameter('settings.state1KRS_validityDataEntry', 'thetaNoisyWindowsValid');
evaluate.setDefaultParameter('settings.state2KRS_inputDataEntry', 'x2');
evaluate.setDefaultParameter('settings.state2KRS_validityDataEntry', 'thetaNoisyWindowsValid');
evaluate.setDefaultParameter('settings.state3KRS_inputDataEntry', 'x3');
evaluate.setDefaultParameter('settings.state3KRS_validityDataEntry', 'thetaNoisyWindowsValid');
evaluate.setDefaultParameter('kernelType','ScaledBandwidthExponentialQuadraticKernel');

evaluate.setDefaultParameter('settings.state1KRS_kernelMedianBandwidthFactor', 1);

evaluate.setDefaultParameter('settings.spectralLearner_observations',{'x1','obsPoints'});
evaluate.setDefaultParameter('settings.spectralLearner_outputDataName','thetaNoisy');

evaluate.setDefaultParameter('windowSize',4);
evaluate.setDefaultParameter('outputDims',{1});
% evaluate.setDefaultParameter('numEigenvectors',30);

% optimization settings
evaluate.setDefaultParameter('settings.spectralOptimizer_groundtruthName', 'theta');
evaluate.setDefaultParameter('settings.spectralOptimizer_observationIndex', 1);
evaluate.setDefaultParameter('settings.spectralOptimizer_validityDataEntry', 'thetaNoisyWindowsValid');
evaluate.setDefaultParameter('settings.CMAOptimizerInitialRangeSpectral_CMAES_optimization', .05);
evaluate.setDefaultParameter('settings.maxNumOptiIterationsSpectral_CMAES_optimization', 50);

evaluate.setDefaultParameter('evaluationGroundtruth','theta');
evaluate.setDefaultParameter('evaluationObservations',{'x1', 'obsPoints'});
evaluate.setDefaultParameter('evaluationObservationIndex',1);
evaluate.setDefaultParameter('evaluationValid','thetaNoisyWindowsValid');
evaluate.setDefaultParameter('evaluationMetric','mse');


experiment = Experiments.Experiment.createByNameNew(experimentName, category, ...
     {configuredTask, configuredStateAliasAdder, configuredNoisePreprocessor, ...
     configuredWindowPreprocessor, configuredWindowAliasAdder, ...
     configuredObservationPointsPreprocessor, configuredSpectral}, ...
     evaluationCriterion, 5, {'127.0.0.1',1});

experiment.addEvaluation(evaluate);
experiment.startBatch(32,8);
% experiment.startLocal