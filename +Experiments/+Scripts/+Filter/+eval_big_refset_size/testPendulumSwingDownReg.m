close all;

Common.clearClasses();
clear variables;
%clear all;
clc;

%MySQL.mym('closeall');

category = 'evalBigRefsetSize';
%category = 'test';
experimentName = 'GkkfRegPendulumSwingDown';

% set some variables
trainEmbeddings = repmat({'thetaNoisyWindows'; 'thetaWindows'},1,3);
numIterations = 3;
numTrials = 12;

% create a task
configuredTask = Experiments.Tasks.SwingDownTask(false);

configuredAliasAdder = Experiments.Filter.AddDataAliasConfigurator('stateAliasAdder');

configuredNoisePreprocessor = Experiments.Preprocessor.NoisePreprocessorConfigurator('noisePreprocessorConfigurator');
configuredWindowPreprocessor = Experiments.Preprocessor.WindowPreprocessorConfigurator('windowPreprocessorConfigurator');

configuredObservationPointsPreprocessor = Experiments.Preprocessor.ObservationPointsPreprocessorConfigurator('observationPointsPreprocessorConfigurator');

configuredGkkf = Experiments.Filter.GeneralizedKernelKalmanFilterConfigurator('gkkfConfigurator');

evaluationCriterion = Experiments.EvaluationCriterion();
evaluationCriterion.registerEvaluator(Evaluator.FilteredDataEvaluator());

evaluate = Experiments.Evaluation(...
    {'settings.filterLearner_stateFeatureName','settings.stateKRS_inputDataEntry','settings.reducedKRS_inputDataEntry'},trainEmbeddings,numIterations,numTrials);

evaluate.setDefaultParameter('settings.Noise_std', 1);
evaluate.setDefaultParameter('settings.Noise_mode', 0);
evaluate.setDefaultParameter('settings.dt',1e-1);
evaluate.setDefaultParameter('settings.numSamplesEpisodes',[200 200 200]);
evaluate.setDefaultParameter('settings.numTimeSteps',30);

evaluate.setDefaultParameter('stateAliasAdderAliasNames', {'theta'});
evaluate.setDefaultParameter('stateAliasAdderAliasTargets', {'states'});
evaluate.setDefaultParameter('stateAliasAdderAliasIndices', {1});

% general settings
evaluate.setDefaultParameter('settings.windowSize', 4);
evaluate.setDefaultParameter('settings.observationIndex', 1);

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


% filterLearner Settings
evaluate.setDefaultParameter('settings.filterLearner_outputDataName', 'thetaNoisy');
% evaluate.setDefaultParameter('settings.filterLearner_stateFeatureName', 'thetaNoisyWindows');
evaluate.setDefaultParameter('settings.filterLearner_obsFeatureName', 'thetaNoisy');
evaluate.setDefaultParameter('settings.filterLearner_stateFeatureSize', 4);
evaluate.setDefaultParameter('settings.filterLearner_obsFeatureSize', 1);
evaluate.setDefaultParameter('settings.filterLearner_observations', {'thetaNoisy','obsPoints'});
% filterLearner_stateKernelType: ExponentialQuadraticKernel
% filterLearner_obsKernelType: ExponentialQuadraticKernel
% filterLearner_transitionModelLearnerType: TransitionModelLearnerReg
% filterLearner_observationModelLearnerType: ObservationModelLearnerReg
evaluate.setDefaultParameter('settings.filterLearner_conditionalOperatorType','reg');

% gkkf settings
gkkfName = 'GKKF';
% GKKF_lambdaT
% GKKF_lambdaO
% GKKF_kappa

% referenceSet settings
evaluate.setDefaultParameter('settings.stateKRS_maxSizeReferenceSet', 5000);
evaluate.setDefaultParameter('settings.obsKRS_maxSizeReferenceSet', 5000);
evaluate.setDefaultParameter('settings.reducedKRS_maxSizeReferenceSet', 1000);
% evaluate.setDefaultParameter('settings.stateKRS_inputDataEntry', 'thetaNoisyWindows');
evaluate.setDefaultParameter('settings.stateKRS_validityDataEntry', 'thetaNoisyWindowsValid');
evaluate.setDefaultParameter('settings.obsKRS_inputDataEntry', 'thetaNoisy');
evaluate.setDefaultParameter('settings.obsKRS_validityDataEntry', 'thetaNoisyWindowsValid');
% evaluate.setDefaultParameter('settings.reducedKRS_inputDataEntry', 'thetaNoisyWindows');
evaluate.setDefaultParameter('settings.reducedKRS_validityDataEntry', 'thetaNoisyWindowsValid');

% optimization settings
evaluate.setDefaultParameter('settings.gkkfOptimizer_inputDataEntry','thetaWindows');
evaluate.setDefaultParameter('settings.groundtruthName','theta');
evaluate.setDefaultParameter('settings.CMAOptimizerInitialRangeGKKF_CMAES_optimization', .05);
evaluate.setDefaultParameter('settings.maxNumOptiIterationsGKKF_CMAES_optimization', 200);

evaluate.setDefaultParameter('evaluationGroundtruth','theta');
evaluate.setDefaultParameter('evaluationObservations','thetaNoisy');
evaluate.setDefaultParameter('evaluationValid','thetaNoisyWindowsValid');


experiment = Experiments.Experiment.createByNameNew(experimentName, category, ...
     {configuredTask, configuredAliasAdder, configuredNoisePreprocessor, configuredWindowPreprocessor, configuredObservationPointsPreprocessor, configuredGkkf}, evaluationCriterion, 5, ...
    {'127.0.0.1',1});

experiment.addEvaluation(evaluate);
experiment.startBatch(16,4,24);
% experiment.startLocal