close all;

Common.clearClasses();
%clear all;
clc;

category = 'BallOnABeam';
experimentName = mfilename;
numTrials = 1;
numIterations = 50;

configuredTask = Environments.SL.Tasks.SLBallOnABeamConfigurator();

%%
configuredLearner = Experiments.Learner.BanditLearningSetup('REPS');

evaluationCriterion = Experiments.EvaluationCriterion();

learner = Experiments.Evaluation(...
     {'learner'},{...
     @Learner.EpisodicRL.EpisodicREPS.CreateFromTrial; ...
     @Learner.EpisodicRL.EpisodicPower.CreateFromTrial; ...
     @Learner.EpisodicRL.CMALearner.CreateFromTrial; ...
     @Learner.EpisodicRL.NESLearner2.CreateFromTrial; ...
     },numIterations,numTrials);
 

 
learner.setDefaultParameter('settings.numSamplesEpisodes', 4);
learner.setDefaultParameter('settings.numInitialSamplesEpisodes', 0); 
learner.setDefaultParameter('settings.maxSamples', 20); 
learner.setDefaultParameter('settings.numInitialSamplesVirtual', 20);
learner.setDefaultParameter('settings.initSigmaParameters', 1);
learner.setDefaultParameter('settings.epsilonAction', 1.0);
learner.setDefaultParameter('settings.temperatureScalingPower', 7.5);
learner.setDefaultParameter('settings.InitialBallVel', -1);

evaluate = Experiments.Evaluation.getCartesianProductOf([learner]);

experiment = Experiments.Experiment.createByNameNew(experimentName, category, ...
    {configuredTask, configuredLearner}, evaluationCriterion, 5, ...
    {'127.0.0.1',2});

experiment.addEvaluation(evaluate);
experiment.startLocal();
%experiment.startRemote();
