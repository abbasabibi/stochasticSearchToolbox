close all;

Common.clearClasses();
%clear all;
clc;

category = 'test';
experimentName = 'numSamples';
numTrials = 1;
numIterations = 500;

configuredTask = Environments.SL.Tasks.SLBallInACup();

%%
configuredLearner = Experiments.Learner.TrajectoryBasedLearningSetup('REPS', '+SL/+barrett/BallInACup_InitTrajectory.mat');

evaluationCriterion = Experiments.EvaluationCriterion();

learner = Experiments.Evaluation(...
     {'learner'},{...
     @Learner.EpisodicRL.EpisodicREPS.CreateFromTrial; ...
     },numIterations,numTrials);
 
learner.setDefaultParameter('settings.numSamplesEpisodes', 10);
learner.setDefaultParameter('settings.numInitialSamplesEpisodes', 10); 
learner.setDefaultParameter('settings.maxSamplesEpisodes', 100); 
learner.setDefaultParameter('settings.numInitialSamplesVirtual', 100);
learner.setDefaultParameter('settings.initSigmaParameters', 0.001);
learner.setDefaultParameter('settings.numBasis', 10);
learner.setDefaultParameter('settings.epsilonAction', 0.5);
learner.setDefaultParameter('settings.basisEndTime', 0.5);

evaluate = Experiments.Evaluation.getCartesianProductOf([learner]);


experiment = Experiments.Experiment.createByNameNew(experimentName, category, ...
    {configuredTask, configuredLearner}, evaluationCriterion, 5, ...
    {'127.0.0.1',2});

experiment.addEvaluation(evaluate);
experiment.startLocal();
%experiment.startRemote();
