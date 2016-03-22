close all;

Common.clearClasses();
%clear all;
clc;

%MySQL.mym('closeall');

category = 'test';
experimentName = 'numSamples';
numTrials = 1;
numIterations = 7000;

%configuredTask = Experiments.Tasks.PlanarReaching();
configuredTask = Experiments.Tasks.StandardOptimisationFunctions();


%configuredTrajectoryGenerator = Experiments.Learner.TrajectoryBasedLearningSetup();
%configuredLearner = Experiments.Learner.BanditLearningSetup('entropyRepsSphereFunctionTest');
%%
configuredLearner = Experiments.Learner.BanditLearnedRewardModelLearningSetup('localRepsOneContextDiffBandwidth');

%configuredLearner.addDataPreprocessor('beginning', @DataPreprocessors.ImportanceSamplingLastKPolicies.CreateFromTrial);

evaluationCriterion = Experiments.EvaluationCriterion();
%evaluator = Evaluator.ReturnEvaluatorSearchDistributionMean();
%evaluator = Evaluator.ReturnEvaluatorEvaluationSamples();
%evaluationCriterion.registerEvaluator(evaluator);

evaluatorWeights = Evaluator.ReturnEvaluatorSearchDistributionMean();
evaluationCriterion.registerEvaluator(evaluatorWeights);

evaluatorVariances = Evaluator.ReturnEvaluatorSearchDistributionVariance();
evaluationCriterion.registerEvaluator(evaluatorVariances);


evaluatorEigValues = Evaluator.ReturnEvaluatorSearchDistributionEigValue();
evaluationCriterion.registerEvaluator(evaluatorEigValues);

evaluatorConditionNumber = Evaluator.ReturnConditionNumber();
evaluationCriterion.registerEvaluator(evaluatorConditionNumber);

evaluator2 = Evaluator.ReturnEvaluatorAllSamples();
evaluationCriterion.registerEvaluator(evaluator2);


default = Experiments.Evaluation(...
     {'learner'},{...
     @Learner.EpisodicRL.CMAES2.CreateFromTrial; ...
     },numIterations,numTrials);

%set the reward function here
default.setDefaultParameter('standardRewardFunction', @Environments.BanditEnvironments.RosenbrockReward);
%default.setDefaultParameter('standardRewardFunction', @Environments.BanditEnvironments.SphereReward);

 
default.setDefaultParameter('initialSampler',@Distributions.Discrete.UniformDistribution);
default.setDefaultParameter('settings.numOptimizationsDualFunction',100000);
default.setDefaultParameter('settings.numSamplesEpisodes',15);
default.setDefaultParameter('settings.numInitialSamplesEpisodes',15);
default.setDefaultParameter('settings.maxSamples',15);
default.setDefaultParameter('settings.maxCorrParameters', 1.0);
default.setDefaultParameter('settings.initSigmaParameters', 0.05);
default.setDefaultParameter('settings.epsilonAction',1);
default.setDefaultParameter('useFeaturesForPolicy',false);
default.setDefaultParameter('dimParameters',15);
%default.setDefaultParameter('parameterPolicyLearner', @Learner.SupervisedLearner.ShrunkLinearGaussianMLLearner);
%default.setDefaultParameter('settings.InitialContextDistributionType', 'Gaussian');
default.setDefaultParameter('settings.InitialContextDistributionType', 'Uniform');
%default.setDefaultParameter('settings.InitialContextDistributionWidth', 0.2);
default.setDefaultParameter('settings.numSamplesVirtual', 0);
default.setDefaultParameter('settings.numInitialSamplesVirtual', 0);

default.setDefaultParameter('settings.numDuplication', 1);
default.setDefaultParameter('settings.entropyBeta', 0.0);

default.setDefaultParameter('settings.shrinkvar', 0);
default.setDefaultParameter('settings.getvarianceTarget', false);

%number of samples for NES
default.setDefaultParameter('settings.L', 15);
%nember of samples for CMA-ESx
default.setDefaultParameter('settings.lambda', 15);

evaluate1 = Experiments.Evaluation(...
    {'settings.bandwidthFactor'},{0.15},numIterations,numTrials);
evaluate1.setDefaultParametersFromEvaluation(default);


experiment = Experiments.Experiment.createByNameNew(experimentName, category, ...
    {configuredTask,configuredLearner}, evaluationCriterion, 5, ...
    {'127.0.0.1',2});

experiment.addEvaluation(evaluate1);

%experiment.startBatch(10);

experiment.startLocal();
%experiment.startRemote();
