close all;

Common.clearClasses();
%clear all;
clc;

%MySQL.mym('closeall');

category = 'test';
experimentName = 'numSamples';
numTrials = 10;
numIterations = 500;

configuredTask = Experiments.Tasks.PlanarReaching();

%%


configuredLearner = Experiments.Learner.TrajectoryBasedLearningSetup('NESWithNoiseNewTaskSetupHighDim');

evaluationCriterion = Experiments.EvaluationCriterion();


default= Experiments.Evaluation(...
     {'learner'},{...
     @Learner.EpisodicRL.NESLearner2.CreateFromTrial; ...
     },numIterations,numTrials);
default.setDefaultParameter('settings.learnRateNESMeans', 0.5);
default.setDefaultParameter('settings.learnRateNESSigmas', 0.02);
default.setDefaultParameter('settings.initSigmaParameters', 0.005);
default.setDefaultParameter('settings.viaPointNoise', 0.0);
default.setDefaultParameter('settings.numBasis', 5);
default.setDefaultParameter('numJoints', 20);
default.setDefaultParameter('settings.numSamplesEpisodes',25);
default.setDefaultParameter('settings.numInitialSamplesEpisodes',25);
default.setDefaultParameter('settings.maxSamples', 25);
default.setDefaultParameter('settings.L', 25);

evaluate2 = Experiments.Evaluation(...
     {'settings.viaPointNoise'},{0.0},numIterations,numTrials);
evaluate2.setDefaultParametersFromEvaluation(default);


experiment = Experiments.Experiment.createByName(experimentName, category, ...
    configuredTask, configuredLearner, evaluationCriterion, 5, ...
    {'127.0.0.1',2});

experiment.addEvaluation(evaluate2);

experiment.startBatch(5);

%experiment.startLocal();
%experiment.startRemote();
