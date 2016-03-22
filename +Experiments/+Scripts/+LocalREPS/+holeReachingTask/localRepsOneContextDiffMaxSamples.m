close all;

Common.clearClasses();
%clear all;
clc;

%MySQL.mym('closeall');

category = 'test';
experimentName = 'numSamples';
numTrials = 5;
numIterations = 10000;

configuredTask = Experiments.Tasks.PlanarHoleReaching();
%%
configuredLearner = Experiments.Learner.TrajectoryBasedRewardModelLearningSetup('localRepsOneContextDiffMaxSamples');

%configuredLearner.addDataPreprocessor('beginning', @DataPreprocessors.ImportanceSamplingLastKPolicies.CreateFromTrial);

evaluationCriterion = Experiments.EvaluationCriterion();
%evaluator = Evaluator.ReturnEvaluatorSearchDistributionMean();
%evaluator = Evaluator.ReturnEvaluatorEvaluationSamples();
%evaluationCriterion.registerEvaluator(evaluator);

%evaluatorWeights = Evaluator.ReturnEvaluatorSearchDistributionMean();
%evaluationCriterion.registerEvaluator(evaluatorWeights);

evaluator2 = Evaluator.ReturnEvaluatorAllSamples();
evaluationCriterion.registerEvaluator(evaluator2);
evaluator3 = Evaluator.LocalREPSEffectiveSamplesEvaluator();
evaluationCriterion.registerEvaluator(evaluator3);

default = Experiments.Evaluation(...
    {'parameterPolicy'},{...
    @Learner.EpisodicRL.LocalREPS.CreateFromTrial; ...
    },numIterations,numTrials);

default.setDefaultParameter('isLocalReps',true);
default.setDefaultParameter('settings.useGoalPos',true);
default.setDefaultParameter('settings.minViaPoint',-1);
default.setDefaultParameter('settings.maxViaPoint',1);

default.setDefaultParameter('settings.numSamplesEpisodes',30);
default.setDefaultParameter('settings.numInitialSamplesEpisodes', 10000);
default.setDefaultParameter('settings.maxSamples', 3000);
default.setDefaultParameter('settings.maxCorrParameters', 1.0);
default.setDefaultParameter('settings.initSigmaParameters', 0.05);
default.setDefaultParameter('settings.epsilonAction', 0.5);
default.setDefaultParameter('settings.bandwidthFactor', 0.05);
default.setDefaultParameter('useFeaturesForPolicy',false);
default.setDefaultParameter('settings.useViaPointContext', true);
default.setDefaultParameter('settings.useholeRadiusContext',false);
%default.setDefaultParameter('settings.InitialContextDistributionType', 'Gaussian');
%default.setDefaultParameter('settings.InitialContextDistributionWidth', 0.2);
default.setDefaultParameter('settings.viaPointNoise', 0.0);
default.setDefaultParameter('numBasis', 5); 
default.setDefaultParameter('numJoints', 3);
default.setDefaultParameter('settings.numBasis', 5); 
default.setDefaultParameter('settings.numJoints', 3);
default.setDefaultParameter('useVirtualSamples', false);


evaluate1 = Experiments.Evaluation(...
    {'settings.maxSamples'},{7000;8000;9000;10000},numIterations,numTrials);
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

experiment.startBatch(20);

%experiment.startLocal();
%experiment.startRemote();
