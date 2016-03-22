close all;

Common.clearClasses();
%clear all;
clc;

MySQL.mym('closeall');

category = 'test';
experimentName = 'numSamples';
numTrials = 1;
numIterations = 300;

configuredTask = Experiments.Tasks.PlanarReaching();

%%
configuredLearner = Experiments.Learner.TrajectoryBasedLearningSetup('REPSWithNoise');

evaluationCriterion = Experiments.EvaluationCriterion();

standard = Experiments.Evaluation(...
    {'settings.numSamplesEpisodes'},{50;100},numIterations,numTrials);

standard.setDefaultParameter('settings.numSamplesEpisodes', 100);
standard.setDefaultParameter('settings.numInitialSamplesEpisodes', 100);
standard.setDefaultParameter('settings.maxSamplesEpisodes', 100);
standard.setDefaultParameter('settings.maxCorrParameters', 1.0);
standard.setDefaultParameter('settings.initSigmaParameters', 0.05);
standard.setDefaultParameter('settings.numBasis', 5);
standard.setDefaultParameter('numJoints', 5);
standard.setDefaultParameter('settings.epsilonAction', 1.0);
standard.setDefaultParameter('settings.viaPointNoise', 0.1);


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
