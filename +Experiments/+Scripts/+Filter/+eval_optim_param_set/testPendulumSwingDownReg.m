close all;

Common.clearClasses();
clear variables;
%clear all;
clc;

%MySQL.mym('closeall');

category = 'evalOptimParamSet';
%category = 'test';
experimentName = 'GkkfRegPendulumSwingDown';

% set some variables
optimParamSet = {[false true  true  true  true  true  true true true] 'state bw: all - obs bw: on'
                 [true  false false false false true  true true true] 'state bw: one - obs bw: on'
                 [false false false false false true  true true true] 'state bw: off - obs bw: on'
                 [false true  true  true  true  false true true true] 'state bw: all - obs bw: off'
                 [true  false false false false false true true true] 'state bw: one - obs bw: off'
                 [false false false false false false true true true] 'state bw: off - obs bw: off'};
numIterations = 3;
numTrials = 10;

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
    {'settings.ParameterMapOptimizer','plotLabelName'},optimParamSet,numIterations,numTrials);

evaluate.setDefaultParameter('settings.Noise_std', 1);
evaluate.setDefaultParameter('settings.Noise_mode', 0);
evaluate.setDefaultParameter('settings.dt',1e-1);
evaluate.setDefaultParameter('settings.numSamplesEpisodes',[50 50 100]);
evaluate.setDefaultParameter('settings.numTimeSteps',30);

evaluate.setDefaultParameter('stateAliasAdderAliasNames', {'theta'});
evaluate.setDefaultParameter('stateAliasAdderAliasTargets', {'states'});
evaluate.setDefaultParameter('stateAliasAdderAliasIndices', {1});

% general settings
evaluate.setDefaultParameter('settings.windowSize', 4);
evaluate.setDefaultParameter('settings.observationIndex', 4);

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
evaluate.setDefaultParameter('settings.windowPreprocessor_indexPoint', 4);


% filterLearner Settings
evaluate.setDefaultParameter('settings.filterLearner_outputDataName', 'thetaNoisy');
evaluate.setDefaultParameter('settings.filterLearner_stateFeatureName', 'thetaNoisyWindows');
evaluate.setDefaultParameter('settings.filterLearner_obsFeatureName', 'thetaNoisy');
evaluate.setDefaultParameter('settings.filterLearner_stateFeatureSize', 4);
evaluate.setDefaultParameter('settings.filterLearner_obsFeatureSize', 1);
evaluate.setDefaultParameter('settings.filterLearner_observations', {'thetaNoisy','obsPoints'});
evaluate.setDefaultParameter('settings.filterLearner_conditionalOperatorType','reg');
% evaluate.setDefaultParameter('settings.filterLearner_windowPrediction',true);
evaluate.setDefaultParameter('settings.filterLearner_stateKernelType','ScaledBandwidthExponentialQuadraticKernel');
% 
evaluate.setDefaultParameter('settings.stateKernel_transparentBandwidth',true);

% evaluate.setDefaultParameter('settings.GKKF_windowSize',4);
% evaluate.setDefaultParameter('settings.GKKF_learnTcov', true);
% evaluate.setDefaultParameter('settings.GKKF_alpha', 1e-8);


% referenceSet settings
evaluate.setDefaultParameter('settings.stateKRS_maxSizeReferenceSet', 5000);
evaluate.setDefaultParameter('settings.obsKRS_maxSizeReferenceSet', 5000);
evaluate.setDefaultParameter('settings.reducedKRS_maxSizeReferenceSet', 300);
evaluate.setDefaultParameter('settings.stateKRS_inputDataEntry', 'thetaNoisyWindows');
evaluate.setDefaultParameter('settings.stateKRS_validityDataEntry', 'thetaNoisyWindowsValid');
evaluate.setDefaultParameter('settings.obsKRS_inputDataEntry', 'thetaNoisy');
evaluate.setDefaultParameter('settings.obsKRS_validityDataEntry', 'thetaNoisyWindowsValid');
evaluate.setDefaultParameter('settings.reducedKRS_inputDataEntry', 'thetaNoisyWindows');
evaluate.setDefaultParameter('settings.reducedKRS_validityDataEntry', 'thetaNoisyWindowsValid');

% evaluate.setDefaultParameter('gkkfConfigurator_optimizationName',repmat({'transOptimizer', 'obsOptimizer'},1,5));
evaluate.setDefaultParameter('gkkfConfigurator_optimizationName',{'Optimizer'});

% optimization settings
evaluate.setDefaultParameter('settings.Optimizer_internalObjective','mse');
evaluate.setDefaultParameter('settings.Optimizer_testMethod','longTerm2');
evaluate.setDefaultParameter('settings.Optimizer_groundtruthName','theta');
evaluate.setDefaultParameter('settings.Optimizer_validityDataEntry','thetaWindowsValid');
evaluate.setDefaultParameter('settings.Optimizer_preprocessTrainingDataEnabled', true);

evaluate.setDefaultParameter('settings.CMAOptimizerInitialRangeOptimizer', .05);
evaluate.setDefaultParameter('settings.maxNumOptiIterationsOptimizer', 200);
% evaluate.setDefaultParameter('settings.ParameterMapOptimizer',[true true true true true true true true]);
% evaluate.setDefaultParameter('settings.ParameterMapOptimizer',[false true true true true true true true true]);

evaluate.setDefaultParameter('evaluationGroundtruth','theta');
evaluate.setDefaultParameter('evaluationObservations','thetaNoisy');
evaluate.setDefaultParameter('evaluationValid','thetaNoisyWindowsValid');
evaluate.setDefaultParameter('evaluationObservationIndex',1);




experiment = Experiments.Experiment.createByNameNew(experimentName, category, ...
     {configuredTask, configuredAliasAdder, configuredNoisePreprocessor, ...
     configuredWindowPreprocessor, configuredObservationPointsPreprocessor, ...
     configuredGkkf}, evaluationCriterion, 5, ...
    {'127.0.0.1',1});

experiment.addEvaluation(evaluate);
experiment.startBatch(32,8);
% experiment.startLocal