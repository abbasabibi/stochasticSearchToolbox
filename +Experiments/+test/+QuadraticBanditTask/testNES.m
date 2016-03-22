close all;

Common.clearClasses();
%clear all;
clc;

<<<<<<< HEAD
%MySQL.mym('closeall');
=======
MySQL.mym('closeall');
>>>>>>> SL

category = 'test';
experimentName = 'numSamples';
numTrials = 2;
numIterations = 100;

configuredTask = Experiments.Tasks.QuadraticBanditTask();

%%
configuredLearner = Experiments.Learner.BanditLearningSetup('NES');

evaluationCriterion = Experiments.EvaluationCriterion();
<<<<<<< HEAD


test = Experiments.Evaluation(...
     {'learner'},{...
     @Learner.EpisodicRL.NESLearner2.CreateFromTrial; ...
     },numIterations,numTrials);

%test.setDefaultParameter('settings.learnRateNESMeans', 0.1);
%test.setDefaultParameter('settings.learnRateNESSigmas', 0.01);

test.setDefaultParameter('settings.initSigmaParameters', 0.001);
=======
evaluator = Evaluator.ReturnEvaluatorEvaluationSamples();
evaluationCriterion.registerEvaluator(evaluator);

test = Experiments.Evaluation(...
     {'learner'},{...
     @Learner.EpisodicRL.NESLearner.CreateFromTrial; ...
     },numIterations,numTrials);

test.setDefaultParameter('learnRateNESMeans', 0.0001);
test.setDefaultParameter('learnRateNESSigmas', 0.000001);

test.setDefaultParameter('initialSigmaParameters', 0.05);
>>>>>>> SL

experiment = Experiments.Experiment.createByName(experimentName, category, ...
    configuredTask, configuredLearner, evaluationCriterion, 5, ...
    {'127.0.0.1',2});

experiment.addEvaluation(test);
experiment.startLocal();
%experiment.startRemote();
