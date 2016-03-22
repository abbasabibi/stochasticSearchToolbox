close all;

Common.clearClasses();
clear variables;
clc;

category = 'evalTactile';
experimentName = 'SubGKKF';

% set some variables
numIterations = 1;

numTrials = 14;

state_size = 36;
obs_size = 36;

% create a task
configuredTask = Experiments.Tasks.TactileDatasetTask();

configuredWindowPreprocessor = Experiments.Preprocessor.WindowPreprocessorConfigurator('windowPreprocessorConfigurator');

configuredObservationPointsPreprocessor = Experiments.Preprocessor.ObservationPointsPreprocessorConfigurator('observationPointsPreprocessorConfigurator');

configuredAliasAdder = Experiments.Filter.AddDataAliasConfigurator('outputAliasAdder');

% configuredObservationPointsPreprocessor = Experiments.Preprocessor.ObservationPointsPreprocessorConfigurator('observationPointsPreprocessorConfigurator');

%configuredLinearTransformFeature = Experiments.Features.FeatureLinearTransform();
%configuredFeatureLearner = Experiments.FeatureLearner.FeatureLearner('stateFeatures');

configuredGkkf = Experiments.Filter.GeneralizedKernelKalmanFilterConfigurator('gkkfConfigurator');
evaluationCriterion = Experiments.EvaluationCriterion();

trainEvaluator = Evaluator.FilterMSETrainEvaluator();
evaluationCriterion.registerEvaluator(trainEvaluator);

testEvaluator = Evaluator.FilterMSETestEvaluator();
evaluationCriterion.registerEvaluator(testEvaluator);

evaluateReferenceSetSize = Experiments.Evaluation(...
    {'settings.reducedKRS_maxSizeReferenceSet'},{100; 200; 300; 400;},numIterations,numTrials);

evaluateWindowSize = Experiments.Evaluation(...
    {'settings.windowPreprocessor_windowSize'},{3; 4; 6; 8; 10; 12},numIterations,numTrials);

% evaluateCMAOptimizations = Experiments.Evaluation(...
%     {'settings.maxNumOptiIterationsGKKF_CMAES_optimization'},{0; 50; 100; 200},numIterations,numTrials);

evaluateStateBandWidthFactor = Experiments.Evaluation(...
    {'settings.stateKRS_kernelMedianBandwidthFactor'},{1; 5; 10; 15; 20},numIterations,numTrials);
evaluateObsBandWidthFactor = Experiments.Evaluation(...
    {'settings.obsKRS_kernelMedianBandwidthFactor'},{1; 5; 10; 15; 20},numIterations,numTrials);
% evaluateBandWidthFactor = Experiments.Evaluation.getCartesianProductOf([evaluateStateBandWidthFactor,evaluateObsBandWidthFactor]);

evaluateOptimization =  Experiments.Evaluation(...
    {'settings.maxNumOptiIterationsGKKF_CMAES_optimization'},{0; 25; 50;},numIterations,numTrials);

experiment = Experiments.Experiment.createById('Experiment4', category, ...
     {configuredTask, configuredAliasAdder, configuredWindowPreprocessor, configuredObservationPointsPreprocessor, configuredGkkf}, evaluationCriterion);
 
experiment.addEvaluation(evaluateReferenceSetSize);
experiment.addEvaluation(evaluateWindowSize );
% experiment.addEvaluation(evaluateCMAOptimizations);
experiment.addEvaluation(evaluateStateBandWidthFactor);
experiment.addEvaluation(evaluateObsBandWidthFactor);
experiment.addEvaluation(evaluateOptimization);

%experiment.setDefaultParameter('stateFeaturesName','PcaFeatures');
%experiment.setDefaultParameter('stateFeaturesVariables', 'inputsWindows');
%experiment.setDefaultParameter('stateNumFeatures', 10);

% experiment.setDefaultParameter('stateFeaturesLearner',@FeatureGenerators.FeatureLearner.PrimaryComponentsAnalysis.createFromTrial);
% experiment.setDefaultParameter('nextStateFeaturesLearner',@FeatureGenerators.FeatureLearner.PrimaryComponentsAnalysis.createFromTrial);

experiment.setDefaultParameter('outputAliasAdderAliasNames', {'handVelocities1'});
experiment.setDefaultParameter('outputAliasAdderAliasTargets', {'handVelocities'});
experiment.setDefaultParameter('outputAliasAdderAliasIndices', {1});

experiment.setDefaultParameter('settings.windowPreprocessor_windowSize', 8);
experiment.setDefaultParameter('settings.windowPreprocessor_indexPoint',8);
experiment.setDefaultParameter('settings.windowPreprocessor_inputNames', {'inputs'});

experiment.setDefaultParameter('settings.filterLearner_outputDataName', 'handVelocities1');
experiment.setDefaultParameter('settings.filterLearner_stateFeatureName', 'inputsWindows');
experiment.setDefaultParameter('settings.filterLearner_obsFeatureName', 'inputs');
experiment.setDefaultParameter('settings.filterLearner_obsFeatureSize', obs_size);
experiment.setDefaultParameter('settings.filterLearner_observations', {'inputs'});
experiment.setDefaultParameter('settings.filterLearner_stateKernelType', 'ScaledBandwidthExponentialQuadraticKernel');
experiment.setDefaultParameter('settings.filterLearner_obsKernelType', 'ScaledBandwidthExponentialQuadraticKernel');
experiment.setDefaultParameter('settings.filterLearner_referenceSetLearnerType', 'greedy');
experiment.setDefaultParameter('settings.filterLearner_conditionalOperatorType', 'reg');


experiment.setDefaultParameter('settings.GKKF_kappa',exp(-6));
experiment.setDefaultParameter('settings.GKKF_lambdaO',exp(-12));
experiment.setDefaultParameter('settings.GKKF_lambdaT',exp(-12));

experiment.setDefaultParameter('settings.stateKRS_kernelMedianBandwidthFactor', 20);
experiment.setDefaultParameter('settings.obsKRS_kernelMedianBandwidthFactor', 10);

% referenceSet settings
experiment.setDefaultParameter('settings.stateKRS_maxSizeReferenceSet', 15000);
experiment.setDefaultParameter('settings.obsKRS_maxSizeReferenceSet', 15000);
experiment.setDefaultParameter('settings.reducedKRS_maxSizeReferenceSet', 250);
experiment.setDefaultParameter('settings.stateKRS_inputDataEntry', 'inputsWindows');
experiment.setDefaultParameter('settings.stateKRS_validityDataEntry', 'inputsWindowsValid');
experiment.setDefaultParameter('settings.obsKRS_inputDataEntry', 'inputs');
experiment.setDefaultParameter('settings.obsKRS_validityDataEntry', 'inputsWindowsValid');
experiment.setDefaultParameter('settings.reducedKRS_inputDataEntry', 'inputsWindows');
experiment.setDefaultParameter('settings.reducedKRS_validityDataEntry', 'inputsWindowsValid');

experiment.setDefaultParameter('settings.reducedKRS_parentReferenceSetIndicator','stateKRSIndicator');
experiment.setDefaultParameter('settings.obsKRS_parentReferenceSetIndicator','stateKRSIndicator');

% optimization settings
experiment.setDefaultParameter('settings.GKKF_CMAES_optimization_groundtruthName','handVelocities1');
experiment.setDefaultParameter('settings.GKKF_CMAES_optimization_observationIndex',1);
experiment.setDefaultParameter('settings.GKKF_CMAES_optimization_validityDataEntry','inputsWindowsValid');
experiment.setDefaultParameter('settings.GKKF_CMAES_optimization_internalObjective','nmse');
experiment.setDefaultParameter('settings.CMAOptimizerInitialRangeGKKF_CMAES_optimization', .05);
experiment.setDefaultParameter('settings.maxNumOptiIterationsGKKF_CMAES_optimization', 0);

experiment.setDefaultParameter('evaluationGroundtruth','handVelocities1');
experiment.setDefaultParameter('evaluationObservations','inputs');

experiment.setDefaultParameter('settings.numImitationEpisodes',200);

%%

%experiment.startLocal
experiment.startBatch(16,8);

%%
experiment.evaluation(1).plotResults();

%%
experiment.evaluation(2).plotResults();

%%
experiment.evaluation(3).plotResults();

%%
experiment.evaluation(4).plotResults();


%experiment.startLocal