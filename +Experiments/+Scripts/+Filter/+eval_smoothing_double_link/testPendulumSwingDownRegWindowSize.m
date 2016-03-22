close all;

Common.clearClasses();
clear variables;
%clear all;
clc;

%MySQL.mym('closeall');

category = 'evalDoubleLinkSmoothing';
%category = 'test';
experimentName = 'windowSize';

% set some variables
windowSize = num2cell(bsxfun(@times,[4;6;8;10],[1 1 2]));
numIterations = 2;
numTrials = 4;

% create a task
configuredTask = Experiments.Tasks.DoubleLinkSwingDownTask(false);

configuredNoisePreprocessor = Experiments.Preprocessor.NoisePreprocessorConfigurator('noisePreproConf');
configuredWindowPreprocessor = Experiments.Preprocessor.WindowPreprocessorConfigurator('winPreproConf');

configuredObservationPointsPreprocessor = Experiments.Preprocessor.ObservationPointsPreprocessorConfigurator('obsPointsPreproConf');

configuredGkkf = Experiments.Smoother.GeneralizedKernelKalmanSmootherConfigurator('gkksConf');

settings = Common.Settings();
settings.setProperty('observationIndex',1:2);
evaluationCriterion = Experiments.EvaluationCriterion();
evaluationCriterion.registerEvaluator(Evaluator.SmoothedDataEvaluator());

evaluate = Experiments.Evaluation(...
    {'settings.windowSize','settings.windowPreprocessor_windowSize','settings.filterLearner_stateFeatureSize'},windowSize,numIterations,numTrials);

evaluate.setDefaultParameter('settings.Noise_std', 1e-1);
evaluate.setDefaultParameter('settings.Noise_mode', 0);
evaluate.setDefaultParameter('settings.dt',1e-1);
evaluate.setDefaultParameter('settings.numSamplesEpisodes',[500 500]);
evaluate.setDefaultParameter('settings.numTimeSteps',30);

% evaluate.setDefaultParameter('stateAliasAdderAliasNames', {'theta'});
% evaluate.setDefaultParameter('stateAliasAdderAliasTargets', {'states'});
% evaluate.setDefaultParameter('stateAliasAdderAliasIndices', {1});

% general settings
% evaluate.setDefaultParameter('settings.windowSize', 6);
evaluate.setDefaultParameter('settings.observationIndex', 1:2);

% observation noise settings
noisePreproName = 'noisePrepro';
evaluate.setDefaultParameter('settings.noisePreprocessor_sigma', 1e-4);
evaluate.setDefaultParameter('settings.noisePreprocessor_inputNames', {'endEffPositions'});
% evaluate.setDefaultParameter('settings.noisePreprocessor_outputNames', {'thetaNoisy', 'nextThetaNoisy'});

evaluate.setDefaultParameter('settings.observationPointsPreprocessor_observationIndices',[1:6,14:16,28:30]);


% window settings
windowsPreproName = 'windowsPrepro';
evaluate.setDefaultParameter('settings.windowPreprocessor_inputNames', {'endEffPositionsNoisy'});
% evaluate.setDefaultParameter('settings.windowPreprocessor_windowSize', 6);
% settings.registerAlias([windowsPreproName '_indexPoint'], 'observationIndex');
evaluate.setDefaultParameter('settings.windowPreprocessor_indexPoint', 1);


% filterLearner Settings
evaluate.setDefaultParameter('settings.filterLearner_outputDataName', {'endEffPositionsNoisy'});
evaluate.setDefaultParameter('settings.filterLearner_stateFeatureName', 'endEffPositionsNoisyWindows');
evaluate.setDefaultParameter('settings.filterLearner_obsFeatureName', 'endEffPositionsNoisy');
% evaluate.setDefaultParameter('settings.filterLearner_stateFeatureSize', 12);
evaluate.setDefaultParameter('settings.filterLearner_obsFeatureSize', 2);
evaluate.setDefaultParameter('settings.filterLearner_observations', {'endEffPositionsNoisy','obsPoints'});
% filterLearner_stateKernelType: ExponentialQuadraticKernel
% filterLearner_obsKernelType: ExponentialQuadraticKernel
% filterLearner_transitionModelLearnerType: TransitionModelLearnerReg
% filterLearner_observationModelLearnerType: ObservationModelLearnerReg
evaluate.setDefaultParameter('settings.filterLearner_conditionalOperatorType','reg');

evaluate.setDefaultParameter('settings.GKKS_kappa',1e-1);



% gkkf settings
% gkkfName = 'GKKF';
% GKKF_lambdaT
% GKKF_lambdaO
% GKKF_kappa

% referenceSet settings
evaluate.setDefaultParameter('settings.stateKRS_maxSizeReferenceSet', 5000);
evaluate.setDefaultParameter('settings.obsKRS_maxSizeReferenceSet', 5000);
evaluate.setDefaultParameter('settings.reducedKRS_maxSizeReferenceSet', 600);
evaluate.setDefaultParameter('settings.stateKRS_inputDataEntry', 'endEffPositionsNoisyWindows');
evaluate.setDefaultParameter('settings.stateKRS_validityDataEntry', 'endEffPositionsNoisyWindowsValid');
evaluate.setDefaultParameter('settings.obsKRS_inputDataEntry', 'endEffPositionsNoisy');
evaluate.setDefaultParameter('settings.obsKRS_validityDataEntry', 'endEffPositionsNoisyWindowsValid');
evaluate.setDefaultParameter('settings.reducedKRS_inputDataEntry', 'endEffPositionsNoisyWindows');
evaluate.setDefaultParameter('settings.reducedKRS_validityDataEntry', 'endEffPositionsNoisyWindowsValid');

evaluate.setDefaultParameter('settings.obsKRS_kernelMedianBandwidthFactor', 10);
evaluate.setDefaultParameter('settings.stateKRS_kernelMedianBandwidthFactor', 10);

evaluate.setDefaultParameter('settings.reducedKRS_parentReferenceSetIndicator','stateKRSIndicator');
evaluate.setDefaultParameter('settings.obsKRS_parentReferenceSetIndicator','stateKRSIndicator');

% optimization settings
evaluate.setDefaultParameter('settings.GKKF_CMAES_optimization_groundtruthName','endEffPositions');
evaluate.setDefaultParameter('settings.GKKF_CMAES_optimization_observationIndex',1:2);
evaluate.setDefaultParameter('settings.GKKF_CMAES_optimization_validityDataEntry','');
evaluate.setDefaultParameter('settings.CMAOptimizerInitialRangeGKKF_CMAES_optimization', .05);
evaluate.setDefaultParameter('settings.maxNumOptiIterationsGKKF_CMAES_optimization', 175);

evaluate.setDefaultParameter('evaluationGroundtruth','endEffPositions');
evaluate.setDefaultParameter('evaluationObservations','endEffPositionsNoisy');
evaluate.setDefaultParameter('evaluationValid','');


experiment = Experiments.Experiment.createByNameNew(experimentName, category, ...
     {configuredTask, configuredNoisePreprocessor, ...
     configuredWindowPreprocessor, configuredObservationPointsPreprocessor, ...
     configuredGkkf}, evaluationCriterion, 5, ...
    {'127.0.0.1',1});

experiment.addEvaluation(evaluate);
experiment.startBatch(16,4);
%experiment.startLocal