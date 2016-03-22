close all;

Common.clearClasses();
%clear all;
clc;

MySQL.mym('closeall');

category = 'test';
experimentName = 'numSamples';
numTrials = 1;
numIterations = 2500;

configuredTask = Experiments.Tasks.SinDistQuadraticBanditTask();

%%
configuredLearner = Experiments.Learner.BanditLearningSetup('LocalREPSDistSinQuadratictask');

evaluationCriterion = Experiments.EvaluationCriterion();
%evaluator = Evaluator.ReturnEvaluatorEvaluationSamples();
%evaluationCriterion.registerEvaluator(evaluator);
evaluator2 = Evaluator.ReturnEvaluatorAllSamples();
evaluationCriterion.registerEvaluator(evaluator2);

default = Experiments.Evaluation(...
    {'learner'},{...
    @Learner.EpisodicRL.EpisodicREPS.CreateFromTrial; ...
    },numIterations,numTrials);

default.setDefaultParameter('settings.numSamplesEpisodes',20);
default.setDefaultParameter('settings.numInitialSamplesEpisodes', 1001);
default.setDefaultParameter('settings.maxSamples', 2000);
default.setDefaultParameter('settings.maxCorrParameters', 1.0);
default.setDefaultParameter('settings.initSigmaParameters', 0.5);
default.setDefaultParameter('settings.epsilonAction', 0.5);
default.setDefaultParameter('useFeaturesForPolicy',true);
default.setDefaultParameter('settings.numDuplication', 10);

experiment = Experiments.Experiment.createByName(experimentName, category, ...
    configuredTask, configuredLearner, evaluationCriterion, 5, ...
    {'127.0.0.1',2});

experiment.addEvaluation(default);
experiment.startLocal();
%experiment.startRemote();
%experiment.startBatch(10);