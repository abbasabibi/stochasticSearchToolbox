close all;

Common.clearClasses();
%clear all;
clc;

category = 'test';
experimentName = 'numSamples';
numTrials = 10;
numIterations = 70;

configuredTask = Environments.SL.Tasks.SLBallInACupConfigurator();

%%

configuredTrajectoryGenerator = Experiments.Learner.TrajectoryBasedLearningSetup();
configuredLearner = Experiments.Learner.BanditLearningSetup('CMA');
configuredImitationLearner = Experiments.Learner.TrajectoryBasedImitationLearningSetup('+Environments/+SL/+barrett/BallInACup_InitTrajectory.mat');


evaluationCriterion = Experiments.EvaluationCriterion();

learner = Experiments.Evaluation(...
     {},{...     
     },numIterations,numTrials);
 
%learner.setDefaultParameter('settings.numSamplesEpisodes', 10);
%learner.setDefaultParameter('settings.numInitialSamplesEpisodes', 10); 
%learner.setDefaultParameter('settings.maxSamplesEpisodes', 100); 
%learner.setDefaultParameter('settings.numInitialSamplesVirtual', 100);
learner.setDefaultParameter('settings.initSigmaParameters', 0.0001);
learner.setDefaultParameter('settings.numBasis', 10);
learner.setDefaultParameter('settings.temperatureScalingPower', 10);
learner.setDefaultParameter('settings.basisEndTime', 0.5);
learner.setDefaultParameter('learner', @Learner.EpisodicRL.CMALearner.CreateFromTrial);


evaluate = Experiments.Evaluation.getCartesianProductOf([learner]);


experiment = Experiments.Experiment.createByNameNew(experimentName, category, ...
    {configuredTask, configuredTrajectoryGenerator, configuredLearner, configuredImitationLearner}, evaluationCriterion, 5, ...
    {'127.0.0.1',2});

experiment.addEvaluation(evaluate);
experiment.startLocal();
%experiment.startRemote();