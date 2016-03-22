close all;

Common.clearClasses();
%clear all;
clc;


category = 'test';
experimentName = 'numSamples';
numTrials =1;
numIterations = 5000;

%configuredTask = Experiments.Tasks.QuadraticBanditTask();
%configuredTask = Experiments.Tasks.StandardOptimisationFunctions();
%configuredTask = Experiments.Tasks.QuadraticBanditTask();
configuredTask = Experiments.Tasks.PlanarHoleReaching();
%configuredTask = Experiments.Tasks.StandardOptimisationFunctions();


configuredTrajectoryGenerator = Experiments.Learner.TrajectoryBasedLearningSetup();


%%
configuredLearner = Experiments.Learner.BanditLearnedRewardModelLearningSetup('ShrinkageRepsVsShrinkagePower');

evaluationCriterion = Experiments.EvaluationCriterion();
% evaluator = Evaluator.ReturnEvaluatorEvaluationSamples();
% evaluationCriterion.registerEvaluator(evaluator);
evaluatorWeights = Evaluator.ReturnEvaluatorSearchDistributionMean();
evaluationCriterion.registerEvaluator(evaluatorWeights);

evaluatorVariances = Evaluator.ReturnEvaluatorSearchDistributionVariance();
evaluationCriterion.registerEvaluator(evaluatorVariances);


%evaluatorEigValues = Evaluator.ReturnEvaluatorSearchDistributionEigValue();
%evaluationCriterion.registerEvaluator(evaluatorEigValues);

evaluatorConditionNumber = Evaluator.ReturnConditionNumber();
evaluationCriterion.registerEvaluator(evaluatorConditionNumber);

evaluator2 = Evaluator.ReturnEvaluatorAllSamples();
evaluationCriterion.registerEvaluator(evaluator2);

evaluatorKL = Evaluator.ReturnKL();
evaluationCriterion.registerEvaluator(evaluatorKL);

default = Experiments.Evaluation(...
    {'learner'},{...
    @Learner.EpisodicRL.EpisodicREPS.CreateFromTrial; ...
    },numIterations,numTrials);
%set the reward function here
%default.setDefaultParameter('standardRewardFunction', @Environments.BanditEnvironments.RosenbrockReward);
default.setDefaultParameter('standardRewardFunction', @Environments.BanditEnvironments.SphereReward);

default.setDefaultParameter('settings.useGoalPos',true);
default.setDefaultParameter('settings.numSamplesEpisodes',50);
default.setDefaultParameter('settings.numInitialSamplesEpisodes', 100);
default.setDefaultParameter('settings.maxSamples', 100);
default.setDefaultParameter('settings.maxCorrParameters', 1.0);
default.setDefaultParameter('settings.initSigmaParameters', 0.02);
default.setDefaultParameter('settings.numSamplesEpisodesVirtual', 0);
default.setDefaultParameter('settings.epsilonAction',0.5 );
default.setDefaultParameter('useVirtualSamples', false);
default.setDefaultParameter('settings.rewardNoiseMult',0);
default.setDefaultParameter('settings.numSamplesVirtual', 0);
default.setDefaultParameter('settings.numInitialSamplesVirtual', 0);
default.setDefaultParameter('settings.useViaPointContext', false);
default.setDefaultParameter('settings.useholeRadiusContext',false);
default.setDefaultParameter('settings.viaPointNoise', 0.0);
default.setDefaultParameter('numBasis', 5); 
default.setDefaultParameter('numJoints', 5);
default.setDefaultParameter('settings.numBasis', 5); 
default.setDefaultParameter('settings.numJoints', 5);
%default.setDefaultParameter('settings.weightCovPara', 0.0);
default.setDefaultParameter('parameterPolicyLearner', @Learner.SupervisedLearner.ShrunkLinearGaussianMLLearner);
%default.setDefaultParameter('useVirtualSamples', false);

%number of samples for NES
default.setDefaultParameter('settings.L', 15);
%nember of samples for CMA-ESx
default.setDefaultParameter('settings.lambda', 15);
evaluate1 = Experiments.Evaluation(...
    {'learner'},{@Learner.EpisodicRL.EpisodicREPS.CreateFromTrial,@Learner.EpisodicRL.EpisodicPower.CreateFromTrial},numIterations,numTrials);
evaluate1.setDefaultParametersFromEvaluation(default);

% experiment = Experiments.Experiment.createByName(experimentName, category, ...
%     configuredTask, configuredLearner,configuredTrajectoryGenerator, evaluationCriterion, 5, ...
%     {'127.0.0.1',2});
%experiment = Experiments.Experiment.createByNameNew(experimentName, category, ...
%    {configuredTask, configuredLearner }, evaluationCriterion, 5, ...
%    {'127.0.0.1',2});

 experiment = Experiments.Experiment.createByNameNew(experimentName, category, ...
     {configuredTask, configuredTrajectoryGenerator, configuredLearner}, evaluationCriterion, 5, ...
     {'127.0.0.1',2});
experiment.addEvaluation(evaluate1);
experiment.startLocal();
%experiment.startRemote();
%experiment.startBatch(10);