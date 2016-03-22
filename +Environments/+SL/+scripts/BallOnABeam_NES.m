close all;

Common.clearClasses();
%clear all;
clc;

category = 'BallOnABeam';
experimentName = mfilename;
numTrials = 10;
numIterations = 50;

configuredTask = Environments.SL.Tasks.SLBallOnABeamConfigurator();

%%
configuredLearner = Experiments.Learner.BanditLearningSetup('NES');

evaluationCriterion = Experiments.EvaluationCriterion();

learner = Experiments.Evaluation(...
     {'learner'},{...
     @Learner.EpisodicRL.NESLearner2.CreateFromTrial; ...
     },numIterations,numTrials);
 

learner.setDefaultParameter('settings.numSamplesEpisodes', 6); 
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
