close all;

Common.clearClasses();
%clear all;
clc;

MySQL.mym('closeall');

category = 'test';
experimentName = 'numSamples';
numTrials = 10;
numIterations = 100;

configuredTask = Experiments.Tasks.QuadraticBanditTask();

%%
configuredLearner = Experiments.Learner.BanditLearnedRewardModelLearningSetupPCA('REPSLearnedRewardPCARewardNoiseMultBayesPara');

evaluationCriterion = Experiments.EvaluationCriterion();
evaluator = Evaluator.ReturnEvaluatorEvaluationSamples();
evaluationCriterion.registerEvaluator(evaluator);

standard = Experiments.Evaluation(...
    { 'settings.numSamplesEpisodes', 'settings.numInitialSamplesEpisodes', 'settings.maxCorrParameters', ...
    'settings.initSigmaParameters', 'settings.numSamplesEpisodesVirtual', ...
    'settings.rewardNoise','settings.bayesNoiseSigma','settings.maxSamples','settings.epsilonAction' },{...
    10,100,1.0, 0.05, 1000,0,1,100,0.5; ...
    },numIterations,numTrials);


variablesRewardNoiseMult = Experiments.Evaluation(...
    {'settings.rewardNoiseMult'},{...
    0; ...
    1; ...
    2; ...
    3; ...
    },numIterations,numTrials);



variablesBayesParametersSigma = Experiments.Evaluation(...
    {'settings.bayesParametersSigma'},{...
    10^-3; ...
    10^-2; ...
    10^-1; ...
    1; ...
    10; ...
    10^2;
    },numIterations,numTrials);



learner = Experiments.Evaluation(...
     {'learner'},{...
     @Learner.EpisodicRL.EpisodicREPS.CreateFromTrial; ...
     },numIterations,numTrials);

evaluate = Experiments.Evaluation.getCartesianProductOf([standard,variablesRewardNoiseMult,variablesBayesParametersSigma,learner ]);
                                                           


experiment = Experiments.Experiment.createByName(experimentName, category, ...
    configuredTask, configuredLearner, evaluationCriterion, 5, ...
    {'127.0.0.1',2});

experiment.addEvaluation(evaluate);
experiment.startLocal();
%experiment.startRemote();
