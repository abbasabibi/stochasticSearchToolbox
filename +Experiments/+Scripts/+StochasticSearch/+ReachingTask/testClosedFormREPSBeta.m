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
configuredLearner = Experiments.Learner.TrajectoryBasedRewardModelLearningSetup('ClosedFormREPSWithnoiseandfadingentropybeta');

configuredLearner.addDataPreprocessor('beginning', @DataPreprocessors.ImportanceSamplingLastKPolicies.CreateFromTrial);

evaluationCriterion = Experiments.EvaluationCriterion();
%evaluator = Evaluator.ReturnEvaluatorSearchDistributionMean();
%evaluator = Evaluator.ReturnEvaluatorEvaluationSamples();
%evaluationCriterion.registerEvaluator(evaluator);

default = Experiments.Evaluation(...
     {'learner'},{...
     @Learner.EpisodicRL.EntropyREPSClosedFormWithContext.CreateFromTrial; ...
     },numIterations,numTrials);
 
default.setDefaultParameter('settings.numSamplesEpisodes',14);
default.setDefaultParameter('settings.numInitialSamplesEpisodes', 100);
default.setDefaultParameter('settings.maxSamples', 150);
default.setDefaultParameter('settings.maxCorrParameters', 1.0);
default.setDefaultParameter('settings.numBasis', 5);
default.setDefaultParameter('settings.initSigmaParameters', 0.005);
default.setDefaultParameter('settings.numJoints', 5);
default.setDefaultParameter('settings.numSamplesEpisodesVirtual', 1000);
default.setDefaultParameter('settings.epsilonAction', 0.5);
default.setDefaultParameter('settings.numPara', 7);
default.setDefaultParameter('settings.bayesParametersSigma', 0.1);
default.setDefaultParameter('settings.viaPointNoise', 0.05);
default.setDefaultParameter('settings.numProjMat', 1000);
default.setDefaultParameter('settings.bayesNoiseSigma',1);
default.setDefaultParameter('useVirtualSamples', false);
default.setDefaultParameter('settings.entropyBeta', 120);
default.setDefaultParameter('settings.entropyBetaDiscount', 0.984);



evaluate1 = Experiments.Evaluation(...

    {'settings.entropyBeta'},{100,200,400,600,800,1000},numIterations,numTrials);

evaluate1.setDefaultParametersFromEvaluation(default);



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
 


experiment = Experiments.Experiment.createByName(experimentName, category, ...
    configuredTask, configuredLearner, evaluationCriterion, 5, ...
    {'127.0.0.1',2});

experiment.addEvaluation(evaluate1);


experiment.startBatch(25);

%experiment.startLocal();
%experiment.startRemote();
