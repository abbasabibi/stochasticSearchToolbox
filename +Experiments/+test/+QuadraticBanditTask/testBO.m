close all;

Common.clearClasses();
%clear all;
clc;

MySQL.mym('closeall');

category = 'test';
experimentName = 'numSamples';
numTrials = 2;
numIterations = 100;

configuredTask = Experiments.Tasks.QuadraticBanditTask();

%%
configuredLearner = Experiments.Learner.BayesianOptimisationLearningSetup('REPS');

evaluationCriterion = Experiments.EvaluationCriterion();
% evaluator = Evaluator.ReturnEvaluatorEvaluationSamples();
% evaluationCriterion.registerEvaluator(evaluator);

evaluate = Experiments.Evaluation(...
    {'settings.numSamplesEpisodes', 'settings.numInitialSamplesEpisodes'},{...
    1.0,20 ...
    },numIterations,numTrials);

evaluate.setDefaultParameter('dimParameters', 5);

evaluate = Experiments.Evaluation.getCartesianProductOf([evaluate]);


experiment = Experiments.Experiment.createByName(experimentName, category, ...
    configuredTask, configuredLearner, evaluationCriterion, 5, ...
    {'127.0.0.1',2});

experiment.addEvaluation(evaluate);
experiment.startLocal();
%experiment.startRemote();
