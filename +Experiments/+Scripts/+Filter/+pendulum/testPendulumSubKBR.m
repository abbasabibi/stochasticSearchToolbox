close all;

Common.clearClasses();
clear variables;
clc;


category = 'evalPendulum';
experimentName = 'subKBR';

% set some variables
kernelSize = { 50
              100
              150
              200
              250};
numIterations = 6;
numTrials = 20;

% create a task
configuredTask = Experiments.Tasks.SwingDownTask(false);

configuredAliasAdder = Experiments.Filter.AddDataAliasConfigurator('stateAliasAdder');

configuredNoisePreprocessor = Experiments.Preprocessor.NoisePreprocessorConfigurator('noisePreproConf');
configuredWindowPreprocessor = Experiments.Preprocessor.WindowPreprocessorConfigurator('windowPreproConf');

configuredObservationPointsPreprocessor = Experiments.Preprocessor.ObservationPointsPreprocessorConfigurator('obsPointsPreproConf');

configuredGkkf = Experiments.Filter.KernelBayesFilterConfiguratorNoOpt('kbfConf');

evaluationCriterion = Experiments.EvaluationCriterion();
evaluationCriterion.registerEvaluator(Evaluator.FilteredDataEvaluator());
evaluationCriterion.registerEvaluator(Evaluator.FilterTimeEvaluator());

evaluate = Experiments.Evaluation(...
    {'settings.reducedKRS_maxSizeReferenceSet'},kernelSize,numIterations,numTrials);

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
evaluate.setDefaultParameter('settings.windowPreprocessor_indexPoint', 1);


% gkkfLearner Settings
evaluate.setDefaultParameter('settings.filterLearner_outputDataName', {'thetaNoisy'});
evaluate.setDefaultParameter('settings.filterLearner_stateFeatureName', 'thetaNoisyWindows');
evaluate.setDefaultParameter('settings.filterLearner_obsFeatureName', 'thetaNoisy');
evaluate.setDefaultParameter('settings.filterLearner_stateFeatureSize', 4);
evaluate.setDefaultParameter('settings.filterLearner_obsFeatureSize', 1);
evaluate.setDefaultParameter('settings.filterLearner_observations', {'thetaNoisy','obsPoints'});
evaluate.setDefaultParameter('settings.filterLearner_stateKernelType', 'ScaledBandwidthExponentialQuadraticKernel');
evaluate.setDefaultParameter('settings.filterLearner_obsKernelType', 'ScaledBandwidthExponentialQuadraticKernel');
evaluate.setDefaultParameter('settings.filterLearner_conditionalOperatorType','reg');
evaluate.setDefaultParameter('settings.filterLearner_referenceSetLearnerType','greedy');

evaluate.setDefaultParameter('settings.GKKS_kappa',exp(-11));
evaluate.setDefaultParameter('settings.GKKS_lambdaO',exp(-6));
evaluate.setDefaultParameter('settings.GKKS_lambdaT',exp(-6));

evaluate.setDefaultParameter('settings.stateKRS_kernelMedianBandwidthFactor', 6);
evaluate.setDefaultParameter('settings.obsKRS_kernelMedianBandwidthFactor', 4.3);

% referenceSet settings
evaluate.setDefaultParameter('settings.stateKRS_maxSizeReferenceSet', 5000);
evaluate.setDefaultParameter('settings.obsKRS_maxSizeReferenceSet', 5000);
%evaluate.setDefaultParameter('settings.reducedKRS_maxSizeReferenceSet', 200);
evaluate.setDefaultParameter('settings.stateKRS_inputDataEntry', 'thetaNoisyWindows');
evaluate.setDefaultParameter('settings.stateKRS_validityDataEntry', 'thetaNoisyWindowsValid');
evaluate.setDefaultParameter('settings.obsKRS_inputDataEntry', 'thetaNoisy');
evaluate.setDefaultParameter('settings.obsKRS_validityDataEntry', 'thetaNoisyWindowsValid');
evaluate.setDefaultParameter('settings.reducedKRS_inputDataEntry', 'thetaNoisyWindows');
evaluate.setDefaultParameter('settings.reducedKRS_validityDataEntry', 'thetaNoisyWindowsValid');

evaluate.setDefaultParameter('settings.reducedKRS_parentReferenceSetIndicator','stateKRSIndicator');
evaluate.setDefaultParameter('settings.obsKRS_parentReferenceSetIndicator','stateKRSIndicator');

% evaluation settings
evaluate.setDefaultParameter('evaluationGroundtruth','theta');
evaluate.setDefaultParameter('evaluationObservations','thetaNoisy');
evaluate.setDefaultParameter('evaluationValid','thetaNoisyWindowsValid');


experiment = Experiments.Experiment.createByNameNew(experimentName, category, ...
     {configuredTask, configuredAliasAdder, configuredNoisePreprocessor, configuredWindowPreprocessor, configuredObservationPointsPreprocessor, configuredGkkf}, evaluationCriterion, 5, ...
    {'127.0.0.1',1});

experiment.addEvaluation(evaluate);
experiment.startBatch(32,8);
% experiment.startLocal