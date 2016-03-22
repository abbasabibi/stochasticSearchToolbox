close all;

Common.clearClasses();
clear variables;
clc;

category = 'evalHuMoD';
experimentName = 'GP';

% set some variables
numIterations = 1;
numTrials = 5;

% create a task
configuredTask = Experiments.Tasks.HuMoDTask('data/HuMoD/dataHuMoD_train_batches.mat');

configuredWindowPreprocessor = Experiments.Preprocessor.WindowPreprocessorConfigurator('windowPreprocessorConfigurator');

configuredObservationPointsPreprocessor = Experiments.Preprocessor.ObservationPointsPreprocessorConfigurator('observationPointsPreprocessorConfigurator');

configuredGP = Experiments.SupervisedLearning.GPLearner();

evaluationCriterion = Experiments.EvaluationCriterion();
evaluationCriterion.registerEvaluator(Evaluator.SupervisedLearningMSETrainEvaluator());
evaluationCriterion.registerEvaluator(Evaluator.SupervisedLearningMSETestEvaluator('data/HuMoD/dataHuMoD_test.mat'));


evaluateReferenceSetSize = Experiments.Evaluation(...
    {'settings.maxSizeReferenceSet'},{800; 1000; 1200; 1400; 1600; 1800; 2000},numIterations,numTrials);

evaluateWindowSize = Experiments.Evaluation(...
    {'settings.windowPreprocessor_windowSize','settings.windowPreprocessor_indexPoint'},repmat({1; 2; 3; 4; 6; 8},1,2),numIterations,numTrials);

evaluateCMAOptimizations = Experiments.Evaluation(...
    {'settings.maxNumOptiIterationsGPOptimizationOutputs'},{0; 50; 100; 200},numIterations,numTrials);

evaluateBandWidthFactor = Experiments.Evaluation(...
    {'settings.kernelMedianBandwidthFactor'},{1; 2; 5; 10; 15; 25},numIterations,numTrials);


experiment = Experiments.Experiment.createById('ExperimentOpt1', category, ...
     {configuredTask, configuredWindowPreprocessor, configuredObservationPointsPreprocessor, configuredGP}, evaluationCriterion);
 
experiment.addEvaluation(evaluateReferenceSetSize);
experiment.addEvaluation(evaluateWindowSize );
experiment.addEvaluation(evaluateCMAOptimizations);
experiment.addEvaluation(evaluateBandWidthFactor );


experiment.setDefaultParameter('settings.windowPreprocessor_windowSize',3);
experiment.setDefaultParameter('settings.windowPreprocessor_indexPoint',3);
experiment.setDefaultParameter('settings.numImitationEpisodes', 200);
experiment.setDefaultParameter('settings.GPVarianceNoiseFactorOutputs', 10^-1);
experiment.setDefaultParameter('settings.maxNumOptiIterationsGPOptimizationOutputs', 50);
experiment.setDefaultParameter('settings.CMANumRestarts',1);
experiment.setDefaultParameter('settings.maxSizeReferenceSet',1200);
experiment.setDefaultParameter('settings.kernelMedianBandwidthFactor', 25);
experiment.setDefaultParameter('settings.GPLearnerOutputs', 'GPSparse');

%%
% experiment.startLocal
experiment.startBatch(16,16);
%%
experiment.evaluation(1).plotResults();

%%
experiment.evaluation(2).plotResults();

%%
experiment.evaluation(3).plotResults();

%%
experiment.evaluation(4).plotResults();


%experiment.startLocal