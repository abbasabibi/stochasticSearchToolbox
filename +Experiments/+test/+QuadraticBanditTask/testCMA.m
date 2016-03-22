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
configuredLearner = Experiments.Learner.BanditLearningSetup('REPS');

evaluationCriterion = Experiments.EvaluationCriterion();
evaluator = Evaluator.ReturnEvaluatorEvaluationSamples();
evaluationCriterion.registerEvaluator(evaluator);

evaluate = Experiments.Evaluation(...
    {'settings.maxCorrParameters',  'settings.initSigmaParameters'},{...
    1.0, 0.05...
    },numIterations,numTrials);

evaluate2 = Experiments.Evaluation(...
    {'settings.rewardNoise'},{...
    0.5;1 ...
    },numIterations,numTrials);

 learner = Experiments.Evaluation(...
     {'learner'},{...
     @Learner.EpisodicRL.CMALearner.CreateFromTrial; ...
     },numIterations,numTrials);

evaluate = Experiments.Evaluation.getCartesianProductOf([evaluate,evaluate2, learner]);


experiment = Experiments.Experiment.createByName(experimentName, category, ...
    configuredTask, configuredLearner, evaluationCriterion, 5, ...
    {'127.0.0.1',2});

experiment.addEvaluation(evaluate);
experiment.startLocal();
%experiment.startRemote();
