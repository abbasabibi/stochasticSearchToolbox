close all;

Common.clearClasses();
%clear all;
clc;

%MySQL.mym('closeall');

category = 'test';
experimentName = 'epsilon';
numTrials = 10;
numIterations = 100;

configuredTask = Experiments.Tasks.DoubleLinkSwingUpFiniteHorizon();
configuredTask.addParameterSetter(@Experiments.ParameterSettings.PathIntegralRewardSettings);

%%
configuredFeatures = Experiments.Features.FeatureSquaredContextConfigurator();
configuredPolicy = Experiments.ActionPolicies.TimeDependentPolicyConfigurator();

configuredLearner = Experiments.Learner.StepBasedLearningSetup('EpisodicPiREPS');

evaluationCriterion = Experiments.EvaluationCriterion();

evaluate = Experiments.Evaluation(...
    {'settings.epsilonAction'},{...
    0.3; 0.9; 1.5; ...
    },numIterations,numTrials);

evaluate.setDefaultParameter('settings.usePeriodicStateSpace', 0.0);
evaluate.setDefaultParameter('settings.maxCorrActions', 1.0);
evaluate.setDefaultParameter('settings.Noise_std', 0.05);
evaluate.setDefaultParameter('settings.initSigmaActions', 1.0);
evaluate.setDefaultParameter('settings.numInitialSamplesEpisodes', -1);
evaluate.setDefaultParameter('settings.entropyBeta', 1);
evaluate.setDefaultParameter('settings.numSamplesEpisodes', 800);
evaluate.setDefaultParameter('settings.maxSamples', 800);
evaluate.setDefaultParameter('learner', @Learner.EpisodicRL.EpisodicPIREPSLambda.CreateFromTrialForActionPolicy);


experiment = Experiments.Experiment.createByNameNew(experimentName, category, ...
    {configuredTask, configuredFeatures, configuredPolicy, configuredLearner}, evaluationCriterion, 5, ...
    {'127.0.0.1',2});

experiment.addEvaluation(evaluate);
%experiment.startLocal();
%experiment.startRemote();
experiment.startBatch(10);