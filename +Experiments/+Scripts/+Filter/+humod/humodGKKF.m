close all;

Common.clearClasses();
clear variables;
clc;

category = 'evalHuMoD';
experimentName = 'SubGKKF';

% set some variables
numIterations = 1;
numTrials = 1;

obs_size = 36;

% create a task
configuredTask = Experiments.Tasks.HuMoDTask('data/HuMoD/dataHuMoD_train_batches.mat');

configuredWindowPreprocessor = Experiments.Preprocessor.WindowPreprocessorConfigurator('windowPreprocessorConfigurator');

configuredObservationPointsPreprocessor = Experiments.Preprocessor.ObservationPointsPreprocessorConfigurator('observationPointsPreprocessorConfigurator');

%configuredLinearTransformFeature = Experiments.Features.FeatureLinearTransform();
%configuredFeatureLearner = Experiments.FeatureLearner.FeatureLearner('stateFeatures');

configuredGkkf = Experiments.Filter.GeneralizedKernelKalmanFilterConfigurator('gkkfConfigurator');
evaluationCriterion = Experiments.EvaluationCriterion();

trainEvaluator = Evaluator.FilterMSETrainEvaluator();
evaluationCriterion.registerEvaluator(trainEvaluator);

testEvaluator = Evaluator.FilterMSETestEvaluator('data/HuMoD/dataHuMoD_test.mat');
testEvaluator.numSamplesEvaluation = 1;
evaluationCriterion.registerEvaluator(testEvaluator);

evaluateReferenceSetSize = Experiments.Evaluation(...
    {'settings.reducedKRS_maxSizeReferenceSet'},{800; 1000; 1200; 1400; 1600; 1800; 2000},numIterations,numTrials);

evaluateWindowSize = Experiments.Evaluation(...
    {'settings.windowPreprocessor_windowSize'},{2; 3; 4; 6; 8},numIterations,numTrials);

evaluateCMAOptimizations = Experiments.Evaluation(...
    {'settings.maxNumOptiIterationsGKKF_CMAES_optimization'},{0; 50; 100; 200},numIterations,numTrials);

evaluateStateBandWidthFactor = Experiments.Evaluation(...
    {'settings.stateKRS_kernelMedianBandwidthFactor'},{1; 2; 5; 10; 15; 25},numIterations,numTrials);
evaluateObsBandWidthFactor = Experiments.Evaluation(...
    {'settings.obsKRS_kernelMedianBandwidthFactor'},{1; 2; 5; 10; 15; 25},numIterations,numTrials);

experiment = Experiments.Experiment.createById('ExperimentX', category, ...
     {configuredTask, configuredWindowPreprocessor, configuredObservationPointsPreprocessor, configuredGkkf}, evaluationCriterion);
 
experiment.addEvaluation(evaluateReferenceSetSize);
% experiment.addEvaluation(evaluateWindowSize);
% experiment.addEvaluation(evaluateCMAOptimizations);
% experiment.addEvaluation(evaluateStateBandWidthFactor);
% experiment.addEvaluation(evaluateObsBandWidthFactor);

%experiment.setDefaultParameter('stateFeaturesName','PcaFeatures');
%experiment.setDefaultParameter('stateFeaturesVariables', 'inputsWindows');
%experiment.setDefaultParameter('stateNumFeatures', 10);

% experiment.setDefaultParameter('stateFeaturesLearner',@FeatureGenerators.FeatureLearner.PrimaryComponentsAnalysis.createFromTrial);
% experiment.setDefaultParameter('nextStateFeaturesLearner',@FeatureGenerators.FeatureLearner.PrimaryComponentsAnalysis.createFromTrial);

experiment.setDefaultParameter('settings.numImitationEpisodes', 200);

experiment.setDefaultParameter('settings.windowPreprocessor_windowSize', 3);
experiment.setDefaultParameter('settings.windowPreprocessor_inputNames', {'states'});

experiment.setDefaultParameter('settings.filterLearner_outputDataName', 'subjectVelocity');
experiment.setDefaultParameter('settings.filterLearner_stateFeatureName', 'statesWindows');
experiment.setDefaultParameter('settings.filterLearner_obsFeatureName', 'observations');
experiment.setDefaultParameter('settings.filterLearner_obsFeatureSize', obs_size);
experiment.setDefaultParameter('settings.filterLearner_observations', {'observations'});
experiment.setDefaultParameter('settings.filterLearner_stateKernelType', 'ScaledBandwidthExponentialQuadraticKernel');
experiment.setDefaultParameter('settings.filterLearner_obsKernelType', 'ScaledBandwidthExponentialQuadraticKernel');
experiment.setDefaultParameter('settings.filterLearner_referenceSetLearnerType', 'greedy');
experiment.setDefaultParameter('settings.filterLearner_conditionalOperatorType', 'reg');


experiment.setDefaultParameter('settings.GKKF_kappa',exp(-9));
experiment.setDefaultParameter('settings.GKKF_lambdaO',exp(-12));
experiment.setDefaultParameter('settings.GKKF_lambdaT',exp(-12));

experiment.setDefaultParameter('settings.stateKRS_kernelMedianBandwidthFactor', 25);
experiment.setDefaultParameter('settings.obsKRS_kernelMedianBandwidthFactor', 20);

% referenceSet settings
experiment.setDefaultParameter('settings.stateKRS_maxSizeReferenceSet', 15000);
experiment.setDefaultParameter('settings.obsKRS_maxSizeReferenceSet', 15000);
experiment.setDefaultParameter('settings.reducedKRS_maxSizeReferenceSet', 1200);
experiment.setDefaultParameter('settings.stateKRS_inputDataEntry', 'statesWindows');
experiment.setDefaultParameter('settings.stateKRS_validityDataEntry', 'statesWindowsValid');
experiment.setDefaultParameter('settings.obsKRS_inputDataEntry', 'observations');
experiment.setDefaultParameter('settings.obsKRS_validityDataEntry', 'statesWindowsValid');
experiment.setDefaultParameter('settings.reducedKRS_inputDataEntry', 'statesWindows');
experiment.setDefaultParameter('settings.reducedKRS_validityDataEntry', 'statesWindowsValid');

experiment.setDefaultParameter('settings.reducedKRS_parentReferenceSetIndicator','stateKRSIndicator');
experiment.setDefaultParameter('settings.obsKRS_parentReferenceSetIndicator','stateKRSIndicator');

% optimization settings
experiment.setDefaultParameter('settings.GKKF_CMAES_optimization_groundtruthName','subjectVelocity');
experiment.setDefaultParameter('settings.GKKF_CMAES_optimization_observationIndex',1);
experiment.setDefaultParameter('settings.GKKF_CMAES_optimization_validityDataEntry','statesWindowsValid');
experiment.setDefaultParameter('settings.GKKF_CMAES_optimization_internalObjective','mse');
experiment.setDefaultParameter('settings.CMAOptimizerInitialRangeGKKF_CMAES_optimization', .05);
experiment.setDefaultParameter('settings.maxNumOptiIterationsGKKF_CMAES_optimization', 50);

experiment.setDefaultParameter('evaluationGroundtruth','subjectVelocity');
experiment.setDefaultParameter('evaluationObservations','observations');

%%
experiment.startLocal
% experiment.startBatch(16,16);
%%
experiment.evaluation(1).plotResults();

%%
experiment.evaluation(2).plotResults();

%%
experiment.evaluation(3).plotResults();

%%
experiment.evaluation(4).plotResults();

%%
experiment.evaluation(5).plotResults();


%experiment.startLocal