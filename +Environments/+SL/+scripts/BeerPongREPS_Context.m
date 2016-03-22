close all;

Common.clearClasses();
%clear all;
clc;

category = 'BeerBong';
experimentName = mfilename;
numTrials = 10;
numIterations = 500;

configuredTask = Environments.SL.Tasks.SLBeerPongConfigurator();

%%
configuredTrajectoryGenerator = Experiments.Learner.TrajectoryBasedLearningSetup();
configuredLearner = Experiments.Learner.BanditLearningSetup('REPS');
configuredImitationLearner = Experiments.Learner.TrajectoryBasedImitationLearningSetup('+Environments/+SL/+barrett/BeerPong_InitTrajectory.mat');

evaluationCriterion = Experiments.EvaluationCriterion();

learner = Experiments.Evaluation(...
     {'learner'},{...
     @Learner.EpisodicRL.EpisodicREPS.CreateFromTrial; ...
     },numIterations,numTrials);
 

 
learner.setDefaultParameter('settings.numSamplesEpisodes', 10);
learner.setDefaultParameter('settings.numInitialSamplesEpisodes', 20); 
learner.setDefaultParameter('settings.maxSamples', 300); 
learner.setDefaultParameter('settings.numInitialSamplesVirtual', 100);
learner.setDefaultParameter('settings.initSigmaParameters', 0.001);
learner.setDefaultParameter('settings.numBasis', 5);
learner.setDefaultParameter('settings.useGoalPos', true);
%learner.setDefaultParameter('settings.useGoalVel', true);
learner.setDefaultParameter('settings.useWeights', true);
learner.setDefaultParameter('settings.basisEndTime', 1.0);
learner.setDefaultParameter('settings.useInitialCupPositionX', true);
learner.setDefaultParameter('settings.useInitialCupPositionY', true);

learner.setDefaultParameter('settings.InitialContextDistributionType', 'Uniform');
%learner.setDefaultParameter('settings.minGoalPos', -500);
%learner.setDefaultParameter('settings.maxGoalPos', 500);
%learner.setDefaultParameter('settings.useWeights', true);

learner.setDefaultParameter('settings.epsilonAction', 0.5);

evaluate = Experiments.Evaluation.getCartesianProductOf([learner]);

experiment = Experiments.Experiment.createByNameNew(experimentName, category, ...
    {configuredTask, configuredTrajectoryGenerator, configuredLearner, configuredImitationLearner}, evaluationCriterion, 5, ...
    {'127.0.0.1',2});

experiment.addEvaluation(evaluate);
experiment.startLocal();
%experiment.startRemote();
