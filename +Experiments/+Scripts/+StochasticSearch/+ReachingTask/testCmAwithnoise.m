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

configuredLearner = Experiments.Learner.TrajectoryBasedLearningSetup('CMAwithoutNoiseNewTaskSetupHighDim');

evaluationCriterion = Experiments.EvaluationCriterion();


standard = Experiments.Evaluation(...
    {'settings.viaPointNoise'},{0.0},numIterations,numTrials);

standard.setDefaultParameter('settings.maxCorrParameters', 1.0);
standard.setDefaultParameter('settings.initSigmaParameters', 0.005);
standard.setDefaultParameter('settings.numBasis', 5);
standard.setDefaultParameter('numJoints', 20);
standard.setDefaultParameter('settings.lambda', 25);









 learner = Experiments.Evaluation(...
     {'learner'},{...
     @Learner.EpisodicRL.CMALearner.CreateFromTrial; ...
     },numIterations,numTrials);

evaluate = Experiments.Evaluation.getCartesianProductOf([standard, learner]);


experiment = Experiments.Experiment.createByName(experimentName, category, ...
    configuredTask, configuredLearner, evaluationCriterion, 5, ...
    {'127.0.0.1',2});

experiment.addEvaluation(evaluate);



%experiment.startRemote();

%experiment.startBatch(10);

experiment.startLocal();
