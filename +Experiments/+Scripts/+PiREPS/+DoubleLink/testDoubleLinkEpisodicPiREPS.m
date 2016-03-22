close all;

Common.clearClasses();
%clear all;
clc;

%MySQL.mym('closeall');

category = 'test';
experimentName = 'episodicPiREPS';
numTrials = 2;
numIterations = 10;

configuredTask = Experiments.Tasks.DoubleLinkSwingUpFiniteHorizon();
configuredTask.addParameterSetter(@Experiments.ParameterSettings.PathIntegralRewardSettings);

%%
configuredFeatures = Experiments.Features.FeatureSquaredContextConfigurator();
configuredPolicy = Experiments.ActionPolicies.TimeDependentPolicyConfigurator();

configuredLearner = Experiments.Learner.StepBasedLearningSetup('EpisodicPiREPS');

evaluationCriterion = Experiments.EvaluationCriterion();

evaluate = Experiments.Evaluation(...
    {'settings.epsilonAction'},{...
    0.3;0.5;...
    },numIterations,numTrials);

evaluate.setDefaultParameter('settings.maxCorrActions', 1.0);
evaluate.setDefaultParameter('settings.usePeriodicStateSpace', 0.0);
evaluate.setDefaultParameter('settings.Noise_std', 0.05);
evaluate.setDefaultParameter('settings.initSigmaActions', 1.0);
evaluate.setDefaultParameter('settings.numSamplesEpisodes', 200);
evaluate.setDefaultParameter('settings.maxSamples', 200);
evaluate.setDefaultParameter('settings.numInitialSamplesEpisodes', -1);
evaluate.setDefaultParameter('settings.entropyBeta', 1);
evaluate.setDefaultParameter('learner', @Learner.EpisodicRL.EpisodicPIREPSLambda.CreateFromTrialForActionPolicy);

% lambda = Experiments.Evaluation(...
%     {'settings.PathIntegralCostActionMultiplier'},{...
%     1; 
%     },numIterations,numTrials);

experiment = Experiments.Experiment.createByEvaluation(evaluate, category, ...
    {configuredTask, configuredFeatures, configuredPolicy, configuredLearner}, evaluationCriterion);

%experiment.addEvaluation(evaluate);
%experiment.startLocal();
%experiment.startRemote();
experiment.startBatch(16, 8);

