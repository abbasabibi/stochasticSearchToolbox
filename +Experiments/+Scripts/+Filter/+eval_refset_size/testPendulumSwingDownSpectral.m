close all;

Common.clearClasses();
clear variables;
%clear all;
clc;

%MySQL.mym('closeall');

category = 'evalReferenceSetSize';
%category = 'test';
experimentName = 'GkkfPendulumSwingDown';

% set some variables
winRefSizes = {100 100 100; 300 300 300; 500 500 500};
numIterations = 5;
numTrials = 20;

% create a task
configuredTask = Experiments.Tasks.SwingDownTask(false);

configuredStateAliasAdder = Experiments.Filter.AddDataAliasConfigurator('stateAliasAdder');
configuredWindowAliasAdder = Experiments.Filter.AddDataAliasConfigurator('windowAliasAdder');

configuredNoisePreprocessor = Experiments.Preprocessor.NoisePreprocessorConfigurator('noisePreprocessorConfigurator');
configuredWindowPreprocessor = Experiments.Preprocessor.WindowPreprocessorConfigurator('windowPreprocessorConfigurator');

configuredObservationPointsPreprocessor = Experiments.Preprocessor.ObservationPointsPreprocessorConfigurator('observationPointsPreprocessorConfigurator');

configuredLinearTransformFeature = Experiments.Features.FeatureLinearTransform();
configuredFeatureLearner = Experiments.FeatureLearner.FeatureLearner('stateFeatures');

configuredSpectral = Experiments.Filter.SpectralFilterConfigurator('spectralConfigurator');

evaluationCriterion = Experiments.EvaluationCriterion();
evaluationCriterion.registerEvaluator(Evaluator.FilteredDataEvaluator());

evaluate = Experiments.Evaluation(...
    {'settings.state1KRS_maxSizeReferenceSet','settings.state2KRS_maxSizeReferenceSet','settings.state3KRS_maxSizeReferenceSet'},winRefSizes,numIterations,numTrials);

evaluate.setDefaultParameter('settings.Noise_std', 1);
evaluate.setDefaultParameter('settings.Noise_mode', 0);
evaluate.setDefaultParameter('settings.dt',1e-1);
evaluate.setDefaultParameter('settings.numSamplesEpisodes',[100 100 100 100 100]);
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
noisePreproName = 'noisePrepro';
evaluate.setDefaultParameter('settings.noisePreprocessor_sigma', 1e-2);
evaluate.setDefaultParameter('settings.noisePreprocessor_inputNames', {'theta'});
% evaluate.setDefaultParameter('settings.noisePreprocessor_outputNames', {'thetaNoisy', 'nextThetaNoisy'});

evaluate.setDefaultParameter('settings.observationPointsPreprocessor_observationIndices',[1:5,20]);


% window settings
windowsPreproName = 'windowsPrepro';
evaluate.setDefaultParameter('settings.windowPreprocessor_inputNames', {'thetaNoisy', 'theta'});
% settings.registerAlias([windowsPreproName '_indexPoint'], 'observationIndex');
evaluate.setDefaultParameter('settings.windowPreprocessor_indexPoint', 1);
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

evaluate.setDefaultParameter('settings.spectralLearner_observations',{'x1','obsPoints'});

% optimization settings
evaluate.setDefaultParameter('settings.spectralOptimizer_inputDataEntry','thetaWindows');
evaluate.setDefaultParameter('settings.groundtruthName','theta');
evaluate.setDefaultParameter('settings.CMAOptimizerInitialRangeSpectral_CMAES_optimization', .05);
evaluate.setDefaultParameter('settings.maxNumOptiIterationsSpectral_CMAES_optimization', 250);

evaluate.setDefaultParameter('windowSize',4);
evaluate.setDefaultParameter('numEigenvectors',30);

evaluate.setDefaultParameter('evaluationGroundtruth','theta');
evaluate.setDefaultParameter('evaluationObservations','x1');
evaluate.setDefaultParameter('evaluationValid','thetaNoisyWindowsValid');


experiment = Experiments.Experiment.createByNameNew(experimentName, category, ...
     {configuredTask, configuredStateAliasAdder, configuredNoisePreprocessor, ...
     configuredWindowPreprocessor, configuredWindowAliasAdder, ...
     configuredObservationPointsPreprocessor, configuredSpectral}, ...
     evaluationCriterion, 5, {'127.0.0.1',1});

experiment.addEvaluation(evaluate);
experiment.startBatch(16,4);
% experiment.startLocal