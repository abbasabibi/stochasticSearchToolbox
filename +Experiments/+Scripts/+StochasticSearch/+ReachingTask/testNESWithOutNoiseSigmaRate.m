close all;

Common.clearClasses();
%clear all;
clc;

%MySQL.mym('closeall');

category = 'test';
experimentName = 'numSamples';
numTrials = 10;
numIterations = 1000;

configuredTask = Experiments.Tasks.PlanarReaching();

%%


configuredLearner = Experiments.Learner.TrajectoryBasedLearningSetup('NESSigmaLearnRateWithOutNoise');

evaluationCriterion = Experiments.EvaluationCriterion();


default= Experiments.Evaluation(...
     {'learner'},{...
     @Learner.EpisodicRL.NESLearner2.CreateFromTrial; ...
     },numIterations,numTrials);
default.setDefaultParameter('settings.learnRateNESMeans', 1);
default.setDefaultParameter('settings.learnRateNESSigmas', 0.02);
default.setDefaultParameter('settings.initSigmaParameters', 0.005);
default.setDefaultParameter('settings.viaPointNoise', 0.0);
default.setDefaultParameter('settings.numBasis', 5);
default.setDefaultParameter('settings.numJoints', 5);
default.setDefaultParameter('settings.numSamplesEpisodes',13);
default.setDefaultParameter('settings.numInitialSamplesEpisodes', 13);
default.setDefaultParameter('settings.maxSamples', 13);
 evaluate2 = Experiments.Evaluation(...
     {'settings.learnRateNESSigmas'},{0.005,0.01,0.02,0.03,0.04,0.05},numIterations,numTrials);
 evaluate2.setDefaultParametersFromEvaluation(default);


experiment = Experiments.Experiment.createByName(experimentName, category, ...
    configuredTask, configuredLearner, evaluationCriterion, 5, ...
    {'127.0.0.1',2});

experiment.addEvaluation(evaluate2);

experiment.startBatch(25);