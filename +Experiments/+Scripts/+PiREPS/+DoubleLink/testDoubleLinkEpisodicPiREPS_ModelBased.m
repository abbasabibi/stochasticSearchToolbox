close all;

Common.clearClasses();
%clear all;
clc;

category = 'test';
experimentName = 'numSamples';
numTrials = 10;
numIterations = 400;


configuredTask = Experiments.Tasks.DoubleLinkSwingUpFiniteHorizon();
configuredTask.addParameterSetter(@Experiments.ParameterSettings.PathIntegralRewardSettings);

%%
configuredFeatures = Experiments.Features.FeatureSquaredContextConfigurator();
configuredFeaturesStates = Experiments.Features.FeatureSquaredConfigurator();
configuredPolicy = Experiments.ActionPolicies.TimeDependentPolicyConfigurator();

configuredLearner = Experiments.Learner.StepBasedComposedLearnedModelLearningSetup('EpisodicPiREPS');

evaluationCriterion = Experiments.EvaluationCriterion();

evaluate = Experiments.Evaluation({'settings.numSamplesEpisodes', 'settings.maxSamples'}, {...
            50 400; 100 400; 200 400; ...
            }, numIterations,numTrials);
%         
% evaluate = Experiments.Evaluation(...
%     {'settings.epsilonAction'},{...
%     0.3;...
%     },numIterations,numTrials);

evaluate.setDefaultParameter('settings.epsilonAction', 0.3);
evaluate.setDefaultParameter('settings.usePeriodicStateSpace', 0.0);
evaluate.setDefaultParameter('settings.maxCorrActions', 1.0);
evaluate.setDefaultParameter('settings.Noise_std', 0.05);
evaluate.setDefaultParameter('settings.initSigmaActions', 1.0);
%evaluate.setDefaultParameter('settings.numSamplesEpisodes', 10);
%evaluate.setDefaultParameter('settings.maxSamples', 200);
evaluate.setDefaultParameter('settings.numInitialSamplesEpisodes', 50);
evaluate.setDefaultParameter('settings.entropyBeta', 1);
evaluate.setDefaultParameter('learner', @Learner.EpisodicRL.EpisodicPIREPSLambda.CreateFromTrialForActionPolicy);

% lambda = Experiments.Evaluation(...
%     {'settings.PathIntegralCostActionMultiplier'},{...
%     1; 
%     },numIterations,numTrials);

experiment = Experiments.Experiment.createByNameNew(experimentName, category, ...
    {configuredTask, configuredFeatures, configuredFeaturesStates, configuredPolicy, configuredLearner}, evaluationCriterion, 5, ...
    {'127.0.0.1',2});



experiment.addEvaluation(evaluate);
%experiment.startLocal();
%experiment.startRemote();
experiment.startBatch(16, 8);
