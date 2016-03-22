close all;

Common.clearClasses();
%clear all;
clc;

%MySQL.mym('closeall');

category = 'test';
experimentName = 'numSamples';
numTrials = 5;
numIterations =1000;

%configuredTask = Experiments.Tasks.QuadraticBanditTask();
%configuredTask = Experiments.Tasks.StandardOptimisationFunctions();
%configuredTask = Experiments.Tasks.PlanarHoleReaching();
%configuredTask = Experiments.Tasks.PlanarReaching();
configuredTask = Experiments.Tasks.StandardOptimisationFunctions();


%configuredTrajectoryGenerator = Experiments.Learner.TrajectoryBasedLearningSetup();


%%
configuredLearner = Experiments.Learner.BanditLearnedRewardModelLearningSetup('MOREholeReaching');

evaluationCriterion = Experiments.EvaluationCriterion();
% evaluator = Evaluator.ReturnEvaluatorEvaluationSamples();
% evaluationCriterion.registerEvaluator(evaluator);


default = Experiments.Evaluation(...
    {'learner'},{...
    @Learner.EpisodicRL.EntropyREPSClosedFormWithContext.CreateFromTrial; ...
    },numIterations,numTrials);
%set the reward function here
default.setDefaultParameter('standardRewardFunction', @Environments.BanditEnvironments.RosenbrockReward);
%default.setDefaultParameter('standardRewardFunction', @Environments.BanditEnvironments.SphereReward);


%%%%%%%%%%%%%   ETA %%%%%%%%%%%%%%%%%%%%%%%%%
%default.setDefaultParameter('settings.eta',1);
default.setDefaultParameter('settings.eta',1000);


default.setDefaultParameter('settings.useGoalPos',true);
default.setDefaultParameter('settings.numSamplesEpisodes',40);
default.setDefaultParameter('settings.numInitialSamplesEpisodes', 100);
default.setDefaultParameter('settings.maxSamples', 200);
default.setDefaultParameter('settings.maxCorrParameters', 1.0);
default.setDefaultParameter('settings.initSigmaParameters', 0.005);
default.setDefaultParameter('settings.numSamplesEpisodesVirtual', 0);
default.setDefaultParameter('settings.epsilonAction',0.5);
default.setDefaultParameter('settings.numPara',3);
default.setDefaultParameter('settings.bayesParametersSigma', 1);
default.setDefaultParameter('settings.viaPointNoise', 0.0);
default.setDefaultParameter('settings.numProjMat', 1000);
default.setDefaultParameter('settings.bayesNoiseSigma',10000000);
default.setDefaultParameter('useVirtualSamples', false);
%default.setDefaultParameter('settings.entropyBeta', 0);
default.setDefaultParameter('settings.entropyBetaDiscount',  0.5);
default.setDefaultParameter('settings.rewardNoiseMult',0);
default.setDefaultParameter('dimParameters',15);
default.setDefaultParameter('settings.numSamplesVirtual', 0);
default.setDefaultParameter('settings.numInitialSamplesVirtual', 0);
default.setDefaultParameter('settings.projectContext',false);
default.setDefaultParameter('settings.useViaPointContext', false);
default.setDefaultParameter('settings.viaPointNoise', 0.0);
default.setDefaultParameter('numBasis', 5); 
default.setDefaultParameter('numJoints', 5);
default.setDefaultParameter('settings.numBasis', 5); 
default.setDefaultParameter('settings.numJoints', 5);
%default.setDefaultParameter('useVirtualSamples', false);
default.setDefaultParameter('parameterPolicyLearner', @Learner.SupervisedLearner.ShrunkLinearGaussianMLLearner);

%number of samples for NES
default.setDefaultParameter('settings.L', 40);
%nember of samples for CMA-ESx
default.setDefaultParameter('settings.lambda', 40);
evaluate1 = Experiments.Evaluation(...
    {'settings.bayesParametersSigma'},{10000000},numIterations,numTrials);
evaluate1.setDefaultParametersFromEvaluation(default);


% experiment = Experiments.Experiment.createByName(experimentName, category, ...
%     configuredTask,configuredTrajectoryGenerator, configuredLearner, evaluationCriterion, 5, ...
%     {'127.0.0.1',2});
experiment = Experiments.Experiment.createByNameNew(experimentName, category, ...
    {configuredTask,configuredLearner }, evaluationCriterion, 5, ...
    {'127.0.0.1',2});

% experiment = Experiments.Experiment.createByNameNew(experimentName, category, ...
%     {configuredTask, configuredTrajectoryGenerator, configuredLearner}, evaluationCriterion, 5, ...
%     {'127.0.0.1',2});
experiment.addEvaluation(evaluate1);
experiment.startLocal();
%experiment.startRemote();
%experiment.startBatch(10);