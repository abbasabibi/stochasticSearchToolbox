close all;

Common.clearClasses();
%clear all;
clc;

%MySQL.mym('closeall');

category = 'test';
experimentName = 'numSamples';
numTrials = 10;
numIterations = 400;

configuredTask = Experiments.Tasks.QuadLinkSwingUpFiniteHorizon();
configuredTask.addParameterSetter(@Experiments.ParameterSettings.PathIntegralRewardSettings);

%%
configuredFeatures = Experiments.Features.FeatureSquaredContextConfigurator();
configuredPolicy = Experiments.ActionPolicies.TimeDependentPolicyConfigurator();

configuredLearner = Experiments.Learner.StepBasedLearningSetup('EpisodicPiREPS');

evaluationCriterion = Experiments.EvaluationCriterion();

evaluate = Experiments.Evaluation({'settings.numSamplesEpisodes', 'settings.maxSamples'}, {...
            1500 1500; 800 800; 500 500;...
            }, numIterations,numTrials);

evaluate.setDefaultParameter('settings.maxCorrActions', 1.0);
evaluate.setDefaultParameter('settings.usePeriodicStateSpace', 0.0);
evaluate.setDefaultParameter('settings.Noise_std', 0.5);
evaluate.setDefaultParameter('settings.initSigmaActions', 0.5);
evaluate.setDefaultParameter('settings.epsilonAction', 0.6);
evaluate.setDefaultParameter('settings.numInitialSamplesEpisodes', -1);
evaluate.setDefaultParameter('settings.entropyBeta', 1);
evaluate.setDefaultParameter('learner', @Learner.EpisodicRL.EpisodicPIREPSLambda.CreateFromTrialForActionPolicy);

% lambda = Experiments.Evaluation(...
%     {'settings.PathIntegralCostActionMultiplier'},{...
%     1; 
%     },numIterations,numTrials);

experiment = Experiments.Experiment.createByNameNew(experimentName, category, ...
    {configuredTask, configuredFeatures, configuredPolicy, configuredLearner}, evaluationCriterion, 5, ...
    {'127.0.0.1',2});

experiment.addEvaluation(evaluate);
%experiment.startLocal();
experiment.startBatch(16, 8);