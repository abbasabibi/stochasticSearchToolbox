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
configuredLearner = Experiments.Learner.BanditLearnedRewardModelLearningSetup('REPSLearnedRewardMaxSampleEpsilonActionCorRewardNoiseVar');

evaluationCriterion = Experiments.EvaluationCriterion();
evaluator = Evaluator.ReturnEvaluatorEvaluationSamples();
evaluationCriterion.registerEvaluator(evaluator);

standard = Experiments.Evaluation(...
    { 'settings.numSamplesEpisodes', 'settings.numInitialSamplesEpisodes', 'settings.maxCorrParameters',  'settings.initSigmaParameters', 'settings.numSamplesEpisodesVirtual', ...
    'settings.rewardNoise','settings.rewardNoiseMult','settings.bayesNoiseSigma','settings.bayesParametersSigma'},{...
    10,100,1.0, 0.05, 1000,0,1,1,10^-3; ...
    },numIterations,numTrials);


variablesMaxSamples = Experiments.Evaluation(...
    {'settings.maxSamples' },{...
    %50; ...
    %150; ...
    250; ...
    %350; ...
    },numIterations,numTrials);



variablesEpsilonAction = Experiments.Evaluation(...
    {'settings.epsilonAction'},{...
    0.5; ...
%     1; ...
%     1.5; ...
%     2; ...
%     3; ...
    },numIterations,numTrials);



learner = Experiments.Evaluation(...
     {'learner'},{...
     @Learner.EpisodicRL.EpisodicREPS.CreateFromTrial; ...
     },numIterations,numTrials);

evaluate = Experiments.Evaluation.getCartesianProductOf([standard,variablesMaxSamples,variablesEpsilonAction,learner ]);
                                                           


experiment = Experiments.Experiment.createByName(experimentName, category, ...
    configuredTask, configuredLearner, evaluationCriterion, 5, ...
    {'127.0.0.1',2});

experiment.addEvaluation(evaluate);
experiment.startLocal();
%experiment.startRemote();
