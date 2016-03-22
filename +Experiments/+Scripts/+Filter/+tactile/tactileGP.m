close all;

Common.clearClasses();
clear variables;
clc;

category = 'evalTactile';
experimentName = 'GP';

% set some variables
numIterations = 1;
numTrials = 14;

% create a task
configuredTask = Experiments.Tasks.TactileDatasetTask();

configuredWindowPreprocessor = Experiments.Preprocessor.WindowPreprocessorConfigurator('windowPreprocessorConfigurator');

configuredGP = Experiments.SupervisedLearning.GPLearner();

evaluationCriterion = Experiments.EvaluationCriterion();
evaluationCriterion.registerEvaluator(Evaluator.SupervisedLearningMSETrainEvaluator());
evaluationCriterion.registerEvaluator(Evaluator.SupervisedLearningMSETestEvaluator());

evaluateReferenceSetSize = Experiments.Evaluation(...
    {'settings.maxSizeReferenceSet'},{100;200;300;400;800},numIterations,numTrials);

evaluateWindowSize = Experiments.Evaluation(...
    {'settings.windowPreprocessor_windowSize'},{1; 2; 3; 4; 6; 8; 10; 12},numIterations,numTrials);

evaluateCMAOptimizations = Experiments.Evaluation(...
    {'settings.maxNumOptiIterationsGPOptimizationOutputs'},{0; 50; 100; 200},numIterations,numTrials);

evaluateBandWidthFactor = Experiments.Evaluation(...
    {'settings.kernelMedianBandwidthFactor'},{1; 5; 10; 15; 20},numIterations,numTrials);


experiment = Experiments.Experiment.createById('Experiment3', category, ...
     {configuredTask, configuredWindowPreprocessor, configuredGP}, evaluationCriterion);
 
experiment.addEvaluation(evaluateReferenceSetSize);
experiment.addEvaluation(evaluateWindowSize );
experiment.addEvaluation(evaluateCMAOptimizations);
experiment.addEvaluation(evaluateBandWidthFactor );

experiment.setDefaultParameter('outputIdx', 1);

experiment.setDefaultParameter('settings.windowPreprocessor_windowSize',8);
experiment.setDefaultParameter('settings.windowPreprocessor_indexPoint',8);
experiment.setDefaultParameter('settings.numImitationEpisodes', 200);
experiment.setDefaultParameter('settings.GPVarianceNoiseFactorOutputs', 10^-1);
experiment.setDefaultParameter('settings.maxNumOptiIterationsGPOptimizationOutputs', 0);
experiment.setDefaultParameter('settings.CMANumRestarts',1);
experiment.setDefaultParameter('settings.maxSizeReferenceSet',200);
experiment.setDefaultParameter('settings.kernelMedianBandwidthFactor', 10);
experiment.setDefaultParameter('settings.GPLearnerOutputs', 'GPSparse');

%%
% experiment.startLocal
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