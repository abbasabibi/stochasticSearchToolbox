close all;

Common.clearClasses();
clear variables;
clc;


category = 'evalPendulum';
experimentName = 'GKKF';

% set some variables
kernelSize = repmat( ...
             {  25
                50
                75
               100
               150
               300
               500},1,2);
numIterations = 7;
numTrials = 20;

% create a task
configuredTask = Experiments.Tasks.SwingDownTask(false);

configuredAliasAdder = Experiments.Filter.AddDataAliasConfigurator('stateAliasAdder');

configuredNoisePreprocessor = Experiments.Preprocessor.NoisePreprocessorConfigurator('noisePreproConf');
configuredWindowPreprocessor = Experiments.Preprocessor.WindowPreprocessorConfigurator('winPreproConf');

configuredObservationPointsPreprocessor = Experiments.Preprocessor.ObservationPointsPreprocessorConfigurator('obsPointsPreproConf');

configuredGkkf = Experiments.Filter.GeneralizedKernelKalmanFilterConfigurator('gkkfConf');

configuredMcFilter = Experiments.Filter.MonteCarloFilterConfigurator('mcConf');

evaluationCriterion = Experiments.EvaluationCriterion();
evaluationCriterion.registerEvaluator(Evaluator.KldFilteredDataEvaluator());
evaluationCriterion.registerEvaluator(Evaluator.FilteredDataEvaluator());
evaluationCriterion.registerEvaluator(Evaluator.FilterTimeEvaluator());

evaluate = Experiments.Evaluation(...
    {'settings.stateKRS_maxSizeReferenceSet', 'settings.obsKRS_maxSizeReferenceSet'},kernelSize,numIterations,numTrials);

evaluate.setDefaultParameter('settings.Noise_std', 1);
evaluate.setDefaultParameter('settings.Noise_mode', 0);
evaluate.setDefaultParameter('settings.dt',1e-1);
evaluate.setDefaultParameter('settings.numSamplesEpisodes',[5 5 15 25 50 150 250]);
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
evaluate.setDefaultParameter('settings.filterLearner_conditionalOperatorType','std');
evaluate.setDefaultParameter('settings.filterLearner_referenceSetLearnerType','greedy');

evaluate.setDefaultParameter('settings.GKKF_kappa',exp(-7));
evaluate.setDefaultParameter('settings.GKKF_lambdaO',exp(-12));
evaluate.setDefaultParameter('settings.GKKF_lambdaT',exp(-4));

evaluate.setDefaultParameter('settings.stateKRS_kernelMedianBandwidthFactor', 6);
evaluate.setDefaultParameter('settings.obsKRS_kernelMedianBandwidthFactor', 4.3);

% referenceSet settings
% evaluate.setDefaultParameter('settings.stateKRS_maxSizeReferenceSet', 100);
% evaluate.setDefaultParameter('settings.obsKRS_maxSizeReferenceSet', 100);
evaluate.setDefaultParameter('settings.reducedKRS_maxSizeReferenceSet', 100);
evaluate.setDefaultParameter('settings.stateKRS_inputDataEntry', 'thetaNoisyWindows');
evaluate.setDefaultParameter('settings.stateKRS_validityDataEntry', 'thetaNoisyWindowsValid');
evaluate.setDefaultParameter('settings.obsKRS_inputDataEntry', 'thetaNoisy');
evaluate.setDefaultParameter('settings.obsKRS_validityDataEntry', 'thetaNoisyWindowsValid');
evaluate.setDefaultParameter('settings.reducedKRS_inputDataEntry', 'thetaNoisyWindows');
evaluate.setDefaultParameter('settings.reducedKRS_validityDataEntry', 'thetaNoisyWindowsValid');

evaluate.setDefaultParameter('settings.reducedKRS_parentReferenceSetIndicator','stateKRSIndicator');
evaluate.setDefaultParameter('settings.obsKRS_parentReferenceSetIndicator','stateKRSIndicator');

% optimization settings
evaluate.setDefaultParameter('settings.GKKF_CMAES_optimization_groundtruthName','theta');
evaluate.setDefaultParameter('settings.GKKF_CMAES_optimization_observationIndex',1);
evaluate.setDefaultParameter('settings.GKKF_CMAES_optimization_validityDataEntry','thetaNoisyWindowsValid');
evaluate.setDefaultParameter('settings.GKKF_CMAES_optimization_internalObjective','mse');
evaluate.setDefaultParameter('settings.CMAOptimizerInitialRangeGKKF_CMAES_optimization', .05);
evaluate.setDefaultParameter('settings.maxNumOptiIterationsGKKF_CMAES_optimization', 50);

% evaluation settings
evaluate.setDefaultParameter('mcConf_dataEntry','theta');
evaluate.setDefaultParameter('mcConf_numSamples',1e4);
evaluate.setDefaultParameter('evaluationGroundtruth','theta');
evaluate.setDefaultParameter('evaluationObservations',{'thetaNoisy' 'obsPoints'});
evaluate.setDefaultParameter('evaluationObservationIndex',1);
evaluate.setDefaultParameter('evaluationValid','thetaNoisyWindowsValid');


experiment = Experiments.Experiment.createByNameNew(experimentName, category, ...
     {configuredTask, configuredAliasAdder, configuredNoisePreprocessor, ...
     configuredWindowPreprocessor, configuredObservationPointsPreprocessor, ...
     configuredGkkf, configuredMcFilter}, evaluationCriterion, 5, ...
    {'127.0.0.1',1});

experiment.addEvaluation(evaluate);
experiment.startBatch(32,8);
% experiment.startLocal