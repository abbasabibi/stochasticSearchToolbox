close all;

Common.clearClasses();
%clear all;
clc;

category = 'BeerBong';
experimentName = mfilename;

numTrials = 5;

numIterations = 500;

configuredTask = Environments.SL.Tasks.SLBeerPongConfigurator();

%%
configuredTrajectoryGenerator = Experiments.TrajectoryGenerators.TrajectoryBasedLearningSetup();
%configuredLearner = Experiments.Learner.BanditLearningSetup('REPS');



%%

configuredLearner = Experiments.Learner.BanditLearnedRewardModelLearningSetup('PowerVariants');
configuredImitationLearner = Experiments.Learner.TrajectoryBasedImitationLearningSetup('+Environments/+SL/+barrett/BeerPong_InitTrajectory.mat');
%configuredImportanceWeighting = Experiments.Preprocessor.ImportanceSamplingLastKPreprocessor();

%  evaluationCriterion = Experiments.EvaluationCriterion();
%  evaluator = Evaluator.RmatrixEvaluation();
%  evaluationCriterion.registerEvaluator(evaluator);
evaluationCriterion = Experiments.EvaluationCriterion();
evaluationCriterion.saveNumDataPoints = 1;

evaluator = Evaluator.ReturnConditionNumber();
evaluationCriterion.registerEvaluator(evaluator);
evaluator = Evaluator.Returnmedian();
evaluationCriterion.registerEvaluator(evaluator);
evaluator = Evaluator.Returnmax();
evaluationCriterion.registerEvaluator(evaluator);


learner = Experiments.Evaluation(...
     {'learner'},{...
     @Learner.EpisodicRL.EpisodicPower.CreateFromTrial; ...
     },numIterations,numTrials);
 

%learner.setDefaultParameter('rewardFunctionLearner', @Learner.ModelLearner.ContextualLowDimBayesianLearnerWithImportanceWeighting); 
learner.setDefaultParameter('settings.numSamplesEpisodes', 20);
learner.setDefaultParameter('settings.numInitialSamplesEpisodes', 200); 
learner.setDefaultParameter('settings.maxSamples', 500); 
learner.setDefaultParameter('settings.numInitialSamplesVirtual',0);
learner.setDefaultParameter('settings.initSigmaParameters', 0.001);
learner.setDefaultParameter('settings.numBasis', 5);
learner.setDefaultParameter('settings.useGoalPos', true);
%learner.setDefaultParameter('settings.useGoalVel', true);
learner.setDefaultParameter('settings.useWeights', true);
learner.setDefaultParameter('settings.basisEndTime', 1.0);
learner.setDefaultParameter('settings.useInitialCupPositionX', false);
learner.setDefaultParameter('settings.useInitialCupPositionY', false);
learner.setDefaultParameter('settings.numPara',5);
learner.setDefaultParameter('settings.bayesParametersSigma', 100000);
learner.setDefaultParameter('settings.viaPointNoise', 0.0);
learner.setDefaultParameter('settings.numProjMat', 1000);
learner.setDefaultParameter('settings.bayesNoiseSigma',100000);
learner.setDefaultParameter('useVirtualSamples', false);
%default.setDefaultParameter('settings.entropyBeta', 0);
learner.setDefaultParameter('settings.eta',1);


learner.setDefaultParameter('settings.entropyBetaDiscount',  0.997);

learner.setDefaultParameter('settings.rewardNoiseMult',0);
learner.setDefaultParameter('dimParameters',15);
learner.setDefaultParameter('settings.numSamplesVirtual', 0);
learner.setDefaultParameter('settings.numInitialSamplesVirtual', 0);
learner.setDefaultParameter('settings.projectContext',false);
learner.setDefaultParameter('settings.useViaPointContext', false);
learner.setDefaultParameter('settings.viaPointNoise', 0.0);

learner.setDefaultParameter('settings.InitialContextDistributionType', 'Uniform');
%learner.setDefaultParameter('settings.minGoalPos', -500);
%learner.setDefaultParameter('settings.maxGoalPos', 500);
%learner.setDefaultParameter('settings.useWeights', true);

learner.setDefaultParameter('settings.epsilonAction', 1.5);
 
learner.setDefaultParameter('settings.BeerPongBounceNoise', 0.0);
learner.setDefaultParameter('settings.actionCosts', 0.0);
%number of samples for NES
learner.setDefaultParameter('settings.L', 22);
%nember of samples for CMA-ESx
learner.setDefaultParameter('settings.lambda', 22);

%evaluate = Experiments.Evaluation.getCartesianProductOf([learner]);


%learner.setDefaultParameter('parameterPolicyLearner', @Learner.SupervisedLearner.RankMuLinearGaussianMLLearner);


%evaluate = Experiments.Evaluation.getCartesianProductOf([learner]);
evaluate = Experiments.Evaluation(...
    {'parameterPolicyLearner'},{@Learner.SupervisedLearner.ShrunkEffSampleLinearGaussianML,@Learner.SupervisedLearner.StandardShrunkLinearGaussianMLLearner,...
    @Learner.SupervisedLearner.DiagonalLinearGaussianMLLearner,@Learner.SupervisedLearner.LinearGaussianMLLearner},numIterations,numTrials);
evaluate.setDefaultParametersFromEvaluation(learner);

experiment = Experiments.Experiment.createByNameNew(experimentName, category, ...
    {configuredTask, configuredTrajectoryGenerator, configuredLearner,configuredImitationLearner}, evaluationCriterion, 5, ...
    {'127.0.0.1',2});

experiment.addEvaluation(evaluate);
experiment.startLocal();
%experiment.startRemote();
