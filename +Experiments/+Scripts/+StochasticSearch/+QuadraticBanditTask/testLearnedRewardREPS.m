close all;

Common.clearClasses();
%clear all;
clc;

%MySQL.mym('closeall');

category = 'test';
experimentName = 'numSamples';
numTrials = 10;
numIterations = 500;

configuredTask = Experiments.Tasks.QuadraticBanditTask();

%%
configuredLearner = Experiments.Learner.BanditLearnedRewardModelLearningSetup('REPSLearnedRewardQuadraticWithMultNoise');

evaluationCriterion = Experiments.EvaluationCriterion();
evaluator = Evaluator.ReturnEvaluatorEvaluationSamples();
evaluationCriterion.registerEvaluator(evaluator);


default = Experiments.Evaluation(...
    {'learner'},{...
    @Learner.EpisodicRL.EntropyREPSClosedFormWithContextNoBaseline.CreateFromTrial; ...
    },numIterations,numTrials);

default.setDefaultParameter('settings.numSamplesEpisodes',10);
default.setDefaultParameter('settings.numInitialSamplesEpisodes', 25);
default.setDefaultParameter('settings.maxSamples', 150);
default.setDefaultParameter('settings.maxCorrParameters', 1.0);
default.setDefaultParameter('settings.numBasis', 5);
default.setDefaultParameter('settings.initSigmaParameters', 0.005);
default.setDefaultParameter('numJoints', 20);
default.setDefaultParameter('settings.numSamplesEpisodesVirtual', 1000);
default.setDefaultParameter('settings.epsilonAction', 0.5);
default.setDefaultParameter('settings.numPara', 3);
default.setDefaultParameter('settings.bayesParametersSigma', 0.1);
default.setDefaultParameter('settings.viaPointNoise', 0.0);
default.setDefaultParameter('settings.numProjMat', 1000);
default.setDefaultParameter('settings.bayesNoiseSigma',1);
default.setDefaultParameter('useVirtualSamples', false);
default.setDefaultParameter('settings.entropyBeta', 0);
default.setDefaultParameter('settings.entropyBetaDiscount', 0.984);
default.setDefaultParameter('settings.rewardNoiseMult',1);


evaluate1 = Experiments.Evaluation(...
    {'settings.numPara'},{0.1,0.01},numIterations,numTrials);
evaluate1.setDefaultParametersFromEvaluation(default);


experiment = Experiments.Experiment.createByName(experimentName, category, ...
    configuredTask, configuredLearner, evaluationCriterion, 5, ...
    {'127.0.0.1',2});

experiment.addEvaluation(evaluate1);
%experiment.startLocal();
%experiment.startRemote();
experiment.startBatch(10);