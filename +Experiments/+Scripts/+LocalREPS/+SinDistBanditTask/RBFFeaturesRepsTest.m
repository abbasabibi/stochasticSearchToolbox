close all;

Common.clearClasses();
%clear all;
clc;

MySQL.mym('closeall');

category = 'test';
experimentName = 'numSamples';
numTrials = 1;
numIterations = 2000;

configuredTask = Experiments.Tasks.SinDistQuadraticBanditTask();

%%
configuredLearner = Experiments.Learner.BanditLearningSetup('RBFFeaturesRepsTest');

evaluationCriterion = Experiments.EvaluationCriterion();
%evaluator = Evaluator.ReturnEvaluatorEvaluationSamples();
%evaluationCriterion.registerEvaluator(evaluator);
evaluator2 = Evaluator.ReturnEvaluatorAllSamples();
evaluationCriterion.registerEvaluator(evaluator2);

default = Experiments.Evaluation(...
    {'learner'},{...
    @Learner.EpisodicRL.EpisodicREPS.CreateFromTrial; ...
    },numIterations,numTrials);


default.setDefaultParameter('useFeaturesForPolicy',true);
default.setDefaultParameter('contextFeatures',@FeatureGenerators.RBF.RadialFeatures);
default.setDefaultParameter('settings.rbfBandwidth',2);
default.setDefaultParameter('settings.rbfNumDimCenters', 3);
default.setDefaultParameter('settings.maxSamples', 2500);
default.setDefaultParameter('settings.numSamplesEpisodes',50);
default.setDefaultParameter('settings.numInitialSamplesEpisodes', 1000);
default.setDefaultParameter('settings.maxCorrParameters', 1.0);
default.setDefaultParameter('settings.initSigmaParameters', 0.5);
default.setDefaultParameter('settings.epsilonAction', 0.5);
default.setDefaultParameter('settings.numDuplication', 1);
default.setDefaultParameter('settings.InitialContextDistributionType', 'Uniform');


experiment = Experiments.Experiment.createByName(experimentName, category, ...
    configuredTask, configuredLearner, evaluationCriterion, 5, ...
    {'127.0.0.1',2});

experiment.addEvaluation(default);
experiment.startLocal();
%experiment.startRemote();
%experiment.startBatch(10);