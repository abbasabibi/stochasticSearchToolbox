close all;

Common.clearClasses();
clear variables;
clc;


category = 'evalKernelBayesFiltering';
experimentName = 'fixedKernelSize';

% set some variables
conditionalOperatorTyp = {'std' 100 100; 'reg' 10000 10000};
% conditionalOperatorTyp = {'reg' 10000 10000};
numIterations = 5;
numTrials = 8;

% create a task
configuredTask = Experiments.Tasks.SwingTask(false);

configuredAliasAdder = Experiments.Filter.AddDataAliasConfigurator('stateAliasAdder');

configuredNoisePreprocessor = Experiments.Preprocessor.NoisePreprocessorConfigurator('noisePreproConf');
configuredWindowPreprocessor = Experiments.Preprocessor.WindowPreprocessorConfigurator('windowPreproConf');

configuredObservationPointsPreprocessor = Experiments.Preprocessor.ObservationPointsPreprocessorConfigurator('obsPointsPreproConf');

configuredGkkf = Experiments.Filter.KernelBayesFilterConfigurator('kbfConf');

evaluationCriterion = Experiments.EvaluationCriterion();
evaluationCriterion.registerEvaluator(Evaluator.FilteredDataEvaluator());

evaluate = Experiments.Evaluation(...
    {'settings.filterLearner_conditionalOperatorType', 'settings.stateKRS_maxSizeReferenceSet', 'settings.obsKRS_maxSizeReferenceSet'},conditionalOperatorTyp,numIterations,numTrials);


evaluate.setDefaultParameter('settings.Noise_std', 1e-2);
evaluate.setDefaultParameter('settings.Noise_mode', 0);
evaluate.setDefaultParameter('settings.dt',1e-1);
% evaluate.setDefaultParameter('settings.numSamplesEpisodes',[5 5 10 30 50]);
evaluate.setDefaultParameter('settings.numSamplesEpisodes',[5 5]);
evaluate.setDefaultParameter('settings.numTimeSteps',30);

evaluate.setDefaultParameter('stateAliasAdderAliasNames', {'theta'});
evaluate.setDefaultParameter('stateAliasAdderAliasTargets', {'states'});
evaluate.setDefaultParameter('stateAliasAdderAliasIndices', {1});

% general settings
% evaluate.setDefaultParameter('settings.windowSize', 4);
% evaluate.setDefaultParameter('settings.observationIndex', 1);

% observation noise settings
noisePreproName = 'noisePrepro';
evaluate.setDefaultParameter('settings.noisePreprocessor_sigma', 1e-2);
evaluate.setDefaultParameter('settings.noisePreprocessor_inputNames', {'theta'});
% evaluate.setDefaultParameter('settings.noisePreprocessor_outputNames', {'thetaNoisy', 'nextThetaNoisy'});

evaluate.setDefaultParameter('settings.observationPointsPreprocessor_observationIndices',[1:30]);


% window settings
% windowsPreproName = 'windowsPrepro';
evaluate.setDefaultParameter('settings.windowPreprocessor_inputNames', {'thetaNoisy', 'theta'});
evaluate.setDefaultParameter('settings.windowPreprocessor_indexPoint', 1);
evaluate.setDefaultParameter('settings.windowPreprocessor_windowSize', 1);


% gkkfLearner Settings
evaluate.setDefaultParameter('settings.filterLearner_outputDataName', 'thetaNoisy');
evaluate.setDefaultParameter('settings.filterLearner_stateFeatureName', 'states');
evaluate.setDefaultParameter('settings.filterLearner_obsFeatureName', 'thetaNoisy');
evaluate.setDefaultParameter('settings.filterLearner_stateFeatureSize', 2);
evaluate.setDefaultParameter('settings.filterLearner_obsFeatureSize', 1);
evaluate.setDefaultParameter('settings.filterLearner_observations', {'thetaNoisy','obsPoints'});
% evaluate.setDefaultParameter('settings.filterLearner_conditionalOperatorType','std');
evaluate.setDefaultParameter('settings.filterLearner_referenceSetLearnerType','random');

% gkkf settings
gkkfName = 'GKKF';
evaluate.setDefaultParameter('settings.GKKF_lambdaT',1e-4);
evaluate.setDefaultParameter('settings.GKKF_lambdaO',1e-4);
evaluate.setDefaultParameter('settings.GKKF_kappa',1e-2);

% referenceSet settings
% evaluate.setDefaultParameter('settings.stateKRS_maxSizeReferenceSet', 10000);
% evaluate.setDefaultParameter('settings.obsKRS_maxSizeReferenceSet', 10000);
evaluate.setDefaultParameter('settings.reducedKRS_maxSizeReferenceSet', 100);
evaluate.setDefaultParameter('settings.stateKRS_inputDataEntry', 'states');
evaluate.setDefaultParameter('settings.stateKRS_validityDataEntry', 'thetaNoisyWindowsValid');
evaluate.setDefaultParameter('settings.obsKRS_inputDataEntry', 'thetaNoisy');
evaluate.setDefaultParameter('settings.obsKRS_validityDataEntry', 'thetaNoisyWindowsValid');
evaluate.setDefaultParameter('settings.reducedKRS_inputDataEntry', 'states');
evaluate.setDefaultParameter('settings.reducedKRS_validityDataEntry', 'thetaNoisyWindowsValid');

% optimization settings
evaluate.setDefaultParameter('settings.GKKF_CMAES_optimization_groundtruthName','theta');
evaluate.setDefaultParameter('settings.CMAOptimizerInitialRangeGKKF_CMAES_optimization', .05);
evaluate.setDefaultParameter('settings.maxNumOptiIterationsGKKF_CMAES_optimization', 100);
evaluate.setDefaultParameter('settings.HyperParametersOptimizerGKKF_CMAES_optimization', 'ConstrainedCMAES');
evaluate.setDefaultParameter('settings.GKKF_CMAES_optimization_initLowerParamLogBounds',-9);
evaluate.setDefaultParameter('settings.GKKF_CMAES_optimization_initLowerParamLogBoundsIdx','end');
evaluate.setDefaultParameter('settings.ReinitializeHyperParametersGKKF_CMAES_optimization',true);
evaluate.setDefaultParameter('settings.ParameterMapGKKF_CMAES_optimization',[false(1,3) true(1,3)]);

evaluate.setDefaultParameter('evaluationGroundtruth','theta');
evaluate.setDefaultParameter('evaluationObservations','thetaNoisy');
evaluate.setDefaultParameter('evaluationValid','');


experiment = Experiments.Experiment.createByNameNew(experimentName, category, ...
     {configuredTask, configuredAliasAdder, configuredNoisePreprocessor, configuredWindowPreprocessor, configuredObservationPointsPreprocessor, configuredGkkf}, evaluationCriterion, 5, ...
    {'127.0.0.1',1});

experiment.addEvaluation(evaluate);
experiment.startBatch(32,8);
% experiment.startLocal