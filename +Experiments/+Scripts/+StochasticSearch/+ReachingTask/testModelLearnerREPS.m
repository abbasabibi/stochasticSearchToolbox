close all;

Common.clearClasses();
%clear all;
clc;

<<<<<<< HEAD
%MySQL.mym('closeall');

category = 'test';
experimentName = 'numSamples';
numTrials = 1;
numIterations = 1000;
=======
MySQL.mym('closeall');

category = 'test';
experimentName = 'numSamples';
numTrials = 10;
numIterations = 300;
>>>>>>> SL

configuredTask = Experiments.Tasks.PlanarReaching();

%%
configuredLearner = Experiments.Learner.TrajectoryBasedRewardModelLearningSetup ('ModelBaseREPSForReachingTaskWithoutNoiseKL');

evaluationCriterion = Experiments.EvaluationCriterion();
%evaluator = Evaluator.ReturnEvaluatorEvaluationSamples();
%evaluationCriterion.registerEvaluator(evaluator);

standard = Experiments.Evaluation(...
    {'settings.numSamplesEpisodes', 'settings.numInitialSamplesEpisodes', ...
    'settings.maxSamples', 'settings.maxCorrParameters', ...
    'settings.rewardNoise', 'settings.numBasis', ...
    'settings.initSigmaParameters', 'settings.numJoints', ...
    'settings.numSamplesEpisodesVirtual','settings.numPara', ...
    'settings.bayesParametersSigma','settings.viaPointNoise','settings.numProjMat','settings.bayesNoiseSigma','settings.entropyBeta'},{...
<<<<<<< HEAD
    14,200,100, 1.0,  0.5, 5, 0.025,5,1000,7,1,0.0,1000,10^-2,4; ...
    },numIterations,numTrials);

standard2 = Experiments.Evaluation(...
    {'settings.epsilonAction'},{1},numIterations,numTrials);
=======
    14,200,100, 1.0,  0.5, 5, 0.025,5,1000,7,1,0.0,1000,10^-2,2; ...
    },numIterations,numTrials);

standard2 = Experiments.Evaluation(...
    {'settings.epsilonAction'},{0.2;0.5;0.7;1;1.2;1.5;1.7;2},numIterations,numTrials);
>>>>>>> SL
%golden Parameters
% standard = Experiments.Evaluation(...
%     {'settings.numSamplesEpisodes', 'settings.numInitialSamplesEpisodes', ...
%     'settings.maxSamples', 'settings.maxCorrParameters', ...
%     'settings.rewardNoise', 'settings.numBasis', ...
%     'settings.initSigmaParameters', 'settings.numJoints','settings.entropyBeta', ...
%     'settings.numSamplesEpisodesVirtual','settings.epsilonAction','settings.numPara', ...
%     'settings.bayesParametersSigma','settings.viaPointNoise','settings.numProjMat'},{...
%     14, 100, 100, 1.0,  0.5, 5, 0.025,5,5,1000,1,2,10^-2,0.1,1000; ...
%     },numIterations,numTrials);
 learner = Experiments.Evaluation(...
     {'learner'},{...
     @Learner.EpisodicRL.EntropyREPS.CreateFromTrial; ...
     },numIterations,numTrials);

<<<<<<< HEAD
evaluate = Experiments.Evaluation.getCartesianProductOf([standard,standard2, learner]);
=======
evaluate = Experiments.Evaluation.getCartesianProductOf([standard, learner]);
>>>>>>> SL


experiment = Experiments.Experiment.createByName(experimentName, category, ...
    configuredTask, configuredLearner, evaluationCriterion, 5, ...
    {'127.0.0.1',2});

experiment.addEvaluation(evaluate);
experiment.startLocal();
%experiment.startRemote();
