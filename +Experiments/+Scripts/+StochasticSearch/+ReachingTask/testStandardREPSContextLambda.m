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
configuredLearner = Experiments.Learner.TrajectoryBasedRewardModelLearningSetup('StandardREPSContextMaxSamples');

%configuredLearner.addDataPreprocessor('beginning', @DataPreprocessors.ImportanceSamplingLastKPolicies.CreateFromTrial);

evaluationCriterion = Experiments.EvaluationCriterion();
evaluator = Evaluator.ReturnEvaluatorSearchDistributionMean();
%evaluator = Evaluator.ReturnEvaluatorEvaluationSamples();
evaluationCriterion.registerEvaluator(evaluator);

default = Experiments.Evaluation(...
     {'learner'},{...
     @Learner.EpisodicRL.EpisodicREPS.CreateFromTrial; ...
     },numIterations,numTrials);
default.setDefaultParameter('settings.numSamplesEpisodes',20);
default.setDefaultParameter('settings.numInitialSamplesEpisodes', 100);
default.setDefaultParameter('settings.maxSamples', 200);
default.setDefaultParameter('settings.maxCorrParameters', 1.0);
default.setDefaultParameter('settings.numBasis', 5);
default.setDefaultParameter('settings.initSigmaParameters', 0.005);
default.setDefaultParameter('settings.numJoints', 5);
default.setDefaultParameter('settings.numSamplesEpisodesVirtual', 1000);
default.setDefaultParameter('settings.epsilonAction', 1);
default.setDefaultParameter('settings.numPara', 7);
default.setDefaultParameter('settings.bayesParametersSigma', 0.1);
default.setDefaultParameter('settings.viaPointNoise', 0.0);
default.setDefaultParameter('settings.numProjMat', 1000);
default.setDefaultParameter('settings.bayesNoiseSigma',1);
default.setDefaultParameter('useVirtualSamples', false);
default.setDefaultParameter('settings.entropyBeta', 0.1);
default.setDefaultParameter('settings.useViaPointContext', true);
default.setDefaultParameter('settings.priorCovWeightParameters', 0.1);


evaluate2 = Experiments.Evaluation(...
    {'settings.priorCovWeightParameters'},{150;200;250;300},numIterations,numTrials);
evaluate2.setDefaultParametersFromEvaluation(default);



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

experiment.addEvaluation(evaluate2);



experiment.startBatch(20);

%experiment.startLocal();
%experiment.startRemote();
