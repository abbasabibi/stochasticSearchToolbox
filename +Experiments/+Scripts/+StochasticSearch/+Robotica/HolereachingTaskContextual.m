close all;

%Common.clearClasses();
%clear all;
clc;

%MySQL.mym('closeall');

category = 'test';
experimentName = 'numSamples';
numTrials = 10;
numIterations =1000;

%configuredTask = Experiments.Tasks.QuadraticBanditTask();
%configuredTask = Experiments.Tasks.StandardOptimisationFunctions();
configuredTask = Experiments.Tasks.PlanarHoleReaching();
%configuredTask = Experiments.Tasks.PlanarReaching();
%configuredTask = Experiments.Tasks.StandardOptimisationFunctions();


%configuredTrajectoryGenerator = Experiments.Learner.TrajectoryBasedLearningSetup();
configuredTrajectoryGenerator = Experiments.TrajectoryGenerators.TrajectoryBasedLearningSetup();


%%
configuredLearner = Experiments.Learner.BanditLearningSetup('IROSHighDimHoleReachingTaskRankMuPoWER');
%configuredImportanceWeighting = Experiments.Preprocessor.ImportanceSamplingLastKPreprocessor();

%             if (trial.useImportanceWeightings)
%                 
%                 trial.setprop('importanceSampler', Experiments.Preprocessor.ImportanceSamplingLastKPreprocessor());
%                 trial.preprocessors = [{trial.importanceSampler}, trial.preprocessors];
%             
%             end

evaluationCriterion = Experiments.EvaluationCriterion();
evaluationCriterion.saveNumDataPoints = 1;

evaluator = Evaluator.ReturnConditionNumber();
evaluationCriterion.registerEvaluator(evaluator);
evaluator = Evaluator.Returnmedian();
evaluationCriterion.registerEvaluator(evaluator);
evaluator = Evaluator.Returnmax;
evaluationCriterion.registerEvaluator(evaluator);

 %evConditionNumberaluationCriterion.registerEvaluator(evaluator);


default = Experiments.Evaluation(...
{'learner'},{...
    @Learner.EpisodicRL.EpisodicPower.CreateFromTrial; ...
    },numIterations,numTrials);



%default = Experiments.Evaluation(...
%{'learner'},{...
%    @Learner.EpisodicRL.EntropyREPSClosedFormWithContext.CreateFromTrial; ...
%    },numIterations,numTrials);

%set the reward function here
%default.setDefaultParameter('rewardFunctionLearner', @Learner.ModelLearner.simpleQuadraticBayesianlearnerWithPrior);
default.setDefaultParameter('standardRewardFunction', @Environments.BanditEnvironments.RosenbrockReward);
%default.setDefaultParameter('standardRewardFunction', @Environments.BanditEnvironments.SphereReward);
default.setDefaultParameter('settings.useGoalPos',true);
default.setDefaultParameter('settings.numSamplesEpisodes',40);
default.setDefaultParameter('settings.numInitialSamplesEpisodes', 500);
default.setDefaultParameter('settings.maxSamples',500);
default.setDefaultParameter('settings.maxCorrParameters', 1.0);
default.setDefaultParameter('settings.initSigmaParameters', 0.05);
default.setDefaultParameter('settings.numSamplesEpisodesVirtual', 0);
default.setDefaultParameter('settings.epsilonAction',1);




default.setDefaultParameter('useVirtualSamples', false);
%default.setDefaultParameter('settings.entropyBeta', 0);





default.setDefaultParameter('settings.rewardNoiseMult',0);

default.setDefaultParameter('settings.numSamplesVirtual', 0);
default.setDefaultParameter('settings.numInitialSamplesVirtual', 0);

default.setDefaultParameter('settings.useViaPointContext', false);

default.setDefaultParameter('useFeaturesForPolicy',false);
%%default.setDefaultParameter('contextFeatures',@FeatureGenerators.RBF.RadialFeatures);
default.setDefaultParameter('settings.rbfBandwidth',[0.21 0.21]);
default.setDefaultParameter('settings.rbfNumDimCenters', 5);

default.setDefaultParameter('settings.viaPointNoise', 0.0);
default.setDefaultParameter('numBasis', 5); 
default.setDefaultParameter('numJoints', 15);
default.setDefaultParameter('settings.numBasis', 5); 
default.setDefaultParameter('settings.numJoints',15);

default.setDefaultParameter('settings.InitialContextDistributionWidth', 0.2); 
default.setDefaultParameter('settings.InitialContextDistributionType', 'Gaussian');

%default.setDefaultParameter('useVirtualSamples', false);
default.setDefaultParameter('parameterPolicyLearner', @Learner.SupervisedLearner.RankMuLinearGaussianMLLearner);

%number of samples for NES
default.setDefaultParameter('settings.L', 40);
%nember of samples for CMA-ESx
default.setDefaultParameter('settings.lambda', 40);

evaluate1 = Experiments.Evaluation(...
    {'settings.entropyPerEffSample'},{0.005; 0.01; 0.02; 0.04},numIterations,numTrials);
evaluate1.setDefaultParametersFromEvaluation(default);


% experiment = Experiments.Experiment.createByName(experimentName, category, ...
%     configuredTask,configuredTrajectoryGenerator, configuredLearner, evaluationCriterion, 5, ...
%     {'127.0.0.1',2});
%   experiment = Experiments.Experiment.createByNameNew(experimentName, category, ...
%       {configuredTask,configuredLearner,configuredImportanceWeighting}, evaluationCriterion, 5, ...
%       {'127.0.0.1',2});

 experiment = Experiments.Experiment.createByNameNew(experimentName, category, ...
     {configuredTask, configuredTrajectoryGenerator, configuredLearner}, evaluationCriterion, 5, ...
     {'127.0.0.1',2});
experiment.addEvaluation(evaluate1);
experiment.startBatch(40, 10);

%experiment.startRemote();
%experiment.startBatch(5);