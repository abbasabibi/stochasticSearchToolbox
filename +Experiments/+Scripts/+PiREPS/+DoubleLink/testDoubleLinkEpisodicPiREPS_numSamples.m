close all;

Common.clearClasses();
%clear all;
clc;

%MySQL.mym('closeall');

category = 'test';
experimentName = 'numSamples';
numTrials = 15;
numIterations = 100;

configuredTask = Experiments.Tasks.DoubleLinkSwingUpFiniteHorizon();
configuredTask.addParameterSetter(@Experiments.ParameterSettings.PathIntegralRewardSettings);

%%
configuredFeatures = Experiments.Features.FeatureSquaredContextConfigurator();
configuredPolicy = Experiments.ActionPolicies.TimeDependentPolicyConfigurator();

configuredLearner = Experiments.Learner.StepBasedLearningSetup('EpisodicPiREPS');

evaluationCriterion = Experiments.EvaluationCriterion();

evaluate = Experiments.Evaluation({'settings.numSamplesEpisodes', 'settings.maxSamples'}, {...
            2000 2000; 800 800; 400 400;...
            }, numIterations,numTrials);

evaluate.setDefaultParameter('settings.maxCorrActions', 1.0);
evaluate.setDefaultParameter('settings.Noise_std', 0.05);
evaluate.setDefaultParameter('settings.initSigmaActions', 1.0);
evaluate.setDefaultParameter('settings.numInitialSamplesEpisodes', -1);
evaluate.setDefaultParameter('settings.entropyBeta', 1);
evaluate.setDefaultParameter('settings.usePeriodicStateSpace', 0.0);
evaluate.setDefaultParameter('learner', @Learner.EpisodicRL.EpisodicPIREPSLambda.CreateFromTrialForActionPolicy);

experiment = Experiments.Experiment.createByNameNew(experimentName, category, ...
    {configuredTask, configuredFeatures, configuredPolicy, configuredLearner}, evaluationCriterion, 5, ...
    {'127.0.0.1',2}, 'data');

experiment.addEvaluation(evaluate);
%experiment.startRemote();
experiment.startBatch(16, 8);
%experiment.startLocal();