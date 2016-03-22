close all;

Common.clearClasses();
clear variables;
clc;


category = 'evalPendulum';
experimentName = 'CEOKKF';

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
configuredWindowPreprocessor = Experiments.Preprocessor.WindowPreprocessorConfigurator('windowPreprConf');

configuredObservationPointsPreprocessor = Experiments.Preprocessor.ObservationPointsPreprocessorConfigurator('obsPointsPreproConf');

configuredCeokkf = Experiments.Filter.CEOKernelKalmanFilterConfigurator('ceokkfConf');

configuredMcFilter = Experiments.Filter.MonteCarloFilterConfigurator('mcConf');

evaluationCriterion = Experiments.EvaluationCriterion();
evaluationCriterion.registerEvaluator(Evaluator.KldFilteredDataEvaluator());
evaluationCriterion.registerEvaluator(Evaluator.FilteredDataEvaluator());
evaluationCriterion.registerEvaluator(Evaluator.FilterTimeEvaluator());

evaluate = Experiments.Evaluation(...
    {'settings.kernelReferenceSet_maxSizeReferenceSet'},kernelSize,numIterations,numTrials);

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

evaluate.setDefaultParameter('settings.observationPointsPreprocessor_observationIndices',[4:30]);


% window settings
evaluate.setDefaultParameter('settings.windowPreprocessor_inputNames', {'thetaNoisy', 'theta'});
evaluate.setDefaultParameter('settings.windowPreprocessor_indexPoint', 4);


% gkkfLearner Settings
evaluate.setDefaultParameter('settings.filterLearner_outputDataName', {'thetaNoisyWindows'});
evaluate.setDefaultParameter('settings.filterLearner_featureName', 'thetaNoisyWindows');
evaluate.setDefaultParameter('settings.filterLearner_observations', {'thetaNoisyWindows', 'obsPoints'});
evaluate.setDefaultParameter('settings.filterLearner_featureSize', 4);
evaluate.setDefaultParameter('settings.filterLearner_stateKernelType', 'ScaledBandwidthExponentialQuadraticKernel');
evaluate.setDefaultParameter('settings.filterLearner_referenceSetLearnerType','greedy');

evaluate.setDefaultParameter('settings.filterLearner_sigma', exp(-10));
evaluate.setDefaultParameter('settings.filterLearner_lambda', exp(1));
evaluate.setDefaultParameter('settings.filterLearner_q', exp(3.9));
evaluate.setDefaultParameter('settings.filterLearner_r', exp(.27));

evaluate.setDefaultParameter('settings.kernelReferenceSet_kernelMedianBandwidthFactor', exp(-1.5));

% referenceSet settings
% evaluate.setDefaultParameter('settings.kernelReferenceSet_maxSizeReferenceSet', 500);
evaluate.setDefaultParameter('settings.kernelReferenceSet_inputDataEntry', 'thetaNoisyWindows');
evaluate.setDefaultParameter('settings.kernelReferenceSet_validityDataEntry', 'thetaNoisyWindowsValid');

% optimization settings
evaluate.setDefaultParameter('settings.ceokkfOptimizer_groundtruthName','theta');
evaluate.setDefaultParameter('settings.ceokkfOptimizer_observationIndex',4);
evaluate.setDefaultParameter('settings.ceokkfOptimizer_validityDataEntry','thetaNoisyWindowsValid');
evaluate.setDefaultParameter('settings.ceokkfOptimizer_internalObjective','mse');
evaluate.setDefaultParameter('settings.CMAOptimizerInitialRangeCEOKKF_CMAES_optimization', 0.05);
evaluate.setDefaultParameter('settings.maxNumOptiIterationsCEOKKF_CMAES_optimization', 50);

% evaluation settings
evaluate.setDefaultParameter('mcConf_dataEntry','theta');
evaluate.setDefaultParameter('mcConf_numSamples',1e4);
evaluate.setDefaultParameter('evaluationGroundtruth','theta');
evaluate.setDefaultParameter('evaluationObservations',{'thetaNoisyWindows' 'obsPoints'});
evaluate.setDefaultParameter('evaluationValid','thetaNoisyWindowsValid');
evaluate.setDefaultParameter('evaluationObservationIndex',4);

experiment = Experiments.Experiment.createByNameNew(experimentName, category, ...
     {configuredTask, configuredAliasAdder, configuredNoisePreprocessor, ...
     configuredWindowPreprocessor, configuredObservationPointsPreprocessor, ...
     configuredCeokkf, configuredMcFilter}, evaluationCriterion, 5, ...
    {'127.0.0.1',1});

experiment.addEvaluation(evaluate);
experiment.startBatch(32,8);
% experiment.startLocal