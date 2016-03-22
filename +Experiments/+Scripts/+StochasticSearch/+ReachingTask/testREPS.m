close all;

Common.clearClasses();
%clear all;
clc;

MySQL.mym('closeall');

category = 'test';
experimentName = 'numSamples';
numTrials = 50;
numIterations = 200;

configuredTask = Experiments.Tasks.PlanarReaching();

%%
configuredLearner = Experiments.Learner.TrajectoryBasedLearningSetup('REPSwithoutnoise');

evaluationCriterion = Experiments.EvaluationCriterion();

standard = Experiments.Evaluation(...
    {'settings.numSamplesEpisodes', 'settings.numInitialSamplesEpisodes', ...
    'settings.maxSamplesEpisodes', 'settings.maxCorrParameters',...
    'settings.initSigmaParameters', 'settings.rewardNoise',...
    'settings.numBasis', 'settings.numJoints','settings.epsilonAction','settings.viaPointNoise'},{...
    10, 100, 100, 1.0, 0.05, 10,5,5,1,0.0; ...
    },numIterations,numTrials);

 learner = Experiments.Evaluation(...
     {'learner'},{...
     @Learner.EpisodicRL.EpisodicREPS.CreateFromTrial; ...
     },numIterations,numTrials);

evaluate = Experiments.Evaluation.getCartesianProductOf([standard, learner]);


experiment = Experiments.Experiment.createByName(experimentName, category, ...
    configuredTask, configuredLearner, evaluationCriterion, 5, ...
    {'127.0.0.1',2});

experiment.addEvaluation(evaluate);
experiment.startLocal();
%experiment.startRemote();
