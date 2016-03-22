close all;

Common.clearClasses();
%clear all;
clc;

%MySQL.mym('closeall');

category = 'test';
experimentName = 'numSamples';
numTrials = 1;
numIterations = 20000;

configuredTask = Experiments.Tasks.SinDistQuadraticBanditTask();

%%
configuredLearner = Experiments.Learner.BanditLearningSetupForLocalReps();

evaluationCriterion = Experiments.EvaluationCriterion();
%evaluator = Evaluator.ReturnEvaluatorEvaluationSamples();
%evaluationCriterion.registerEvaluator(evaluator);
evaluator2 = Evaluator.ReturnEvaluatorAllSamples();
evaluationCriterion.registerEvaluator(evaluator2);

default = Experiments.Evaluation(...
    {'parameterPolicy'},{...
    @Learner.EpisodicRL.LocalREPS.CreateFromTrial; ...
    },numIterations,numTrials);

default.setDefaultParameter('settings.numSamplesEpisodes',40);
default.setDefaultParameter('settings.numInitialSamplesEpisodes', 10000);
default.setDefaultParameter('settings.maxSamples', 10000);
default.setDefaultParameter('settings.maxCorrParameters', 1.0);
default.setDefaultParameter('settings.initSigmaParameters', 0.5);
default.setDefaultParameter('settings.epsilonAction', 0.5);
default.setDefaultParameter('settings.bandwidthFactor', 0.3);
default.setDefaultParameter('useFeaturesForPolicy',false);
default.setDefaultParameter('settings.numDuplication', 40);
default.setDefaultParameter('settings.InitialContextDistributionType', 'Uniform');


experiment = Experiments.Experiment.createByName(experimentName, category, ...
    configuredTask, configuredLearner, evaluationCriterion, 5, ...
    {'127.0.0.1',2});

experiment.addEvaluation(default);
experiment.startLocal();
%experiment.startRemote();
%experiment.startBatch(10);