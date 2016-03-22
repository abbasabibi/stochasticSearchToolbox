close all;

Common.clearClasses();
%clear all;
clc;

MySQL.mym('closeall');

category = 'test';
experimentName = 'numSamples';
numTrials = 5;
numIterations = 50;

configuredTask = Experiments.test.TestTask();

%%
configuredLearner = Experiments.test.TestLearner();

evaluationCriterion = Experiments.EvaluationCriterion();

evaluate = Experiments.Evaluation(...
    {'settings.numSamples'},{...
    10; 20; 30; 40; ...
    },numIterations,numTrials);

learner = Experiments.Evaluation(...
    {'trial.learner'},{...
    @Learner.StepBasedRL.StepBasedRLPower; ...
    },numIterations,numTrials);

evaluate = Experiments.Evaluation.getCartesianProductOf([evaluate, learner]);


experiment = Experiments.Experiment.createByName(experimentName, category, configuredTask, configuredLearner, evaluationCriterion, 5);
experiment.addEvaluation(evaluate);
experiment.startLocal();
