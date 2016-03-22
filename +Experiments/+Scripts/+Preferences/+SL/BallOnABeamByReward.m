close all;

Common.clearClasses();
%clear all;
clc;

category = 'BallOnABeamByReward';
experimentName = mfilename;
numTrials = 10;
numIterations = 50;

%%% used controls etc.
ndofs = 7;
usedStates = zeros(1, 1 + ndofs * 2 + 2); % bias + joint pos/vel + ball pos/vel
usedStates(1) = 1; % we use bias
usedStates(1 + ndofs * 2 + 1) = 1; %ball pos
usedStates(1 + ndofs * 2 + 2) = 1; %ball vel
controlledJoints = zeros(1, ndofs);
controlledJoints(ndofs) = 1;
settings = Common.Settings();

%%
configuredTask = Environments.SL.Tasks.SLBallOnABeamConfiguratorByReward();
settings.setProperty('lengthSupraStep', 20);
settings.setProperty('nbSupraSteps', 50);
settings.setProperty('usedStates', usedStates);
settings.setProperty('controlledJoints', controlledJoints);

configuredLearner = Experiments.Learner.BanditLearningSetup('REPS');

evaluationCriterion = Experiments.EvaluationCriterion();

learner = Experiments.Evaluation(...
     {'learner'},{...
     @Learner.EpisodicRL.CMALearner.CreateFromTrial; ...
     },numIterations,numTrials);
 

 
learner.setDefaultParameter('settings.numInitialSamplesEpisodes', 0); 
learner.setDefaultParameter('settings.numInitialSamplesVirtual', 20);
learner.setDefaultParameter('settings.initSigmaParameters', 1);

evaluate = Experiments.Evaluation.getCartesianProductOf([learner]);

experiment = Experiments.Experiment.createByNameNew(experimentName, category, ...
    {configuredTask, configuredLearner}, evaluationCriterion, 5, ...
    {'127.0.0.1',2});

experiment.addEvaluation(evaluate);
experiment.startLocal();
%experiment.startRemote();
