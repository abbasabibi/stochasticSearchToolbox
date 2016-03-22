close all;

Common.clearClasses();
%clear all;
clc;

%MySQL.mym('closeall');

category = 'test';
experimentName = 'temperatureScalingPower';
numTrials = 1;
numIterations = 100;

configuredTask = Experiments.Tasks.DoubleLinkSwingUpFiniteHorizon();
configuredTask.addParameterSetter(@Experiments.ParameterSettings.PathIntegralRewardSettings);

%%
configuredFeatures = Experiments.Features.FeatureSquaredContextConfigurator();
configuredPolicy = Experiments.ActionPolicies.TimeDependentPolicyConfigurator();

configuredLearner = Experiments.Learner.StepBasedLearningSetup('EpisodicPower');
%configuredLearner = Experiments.Learner.StepBasedComposedTimeDependentLearningSetup('EpisodicPower');

evaluationCriterion = Experiments.EvaluationCriterion();

evaluate = Experiments.Evaluation({'settings.numSamplesEpisodes', 'settings.maxSamples'}, {...
            800 800; }, numIterations,numTrials);

evaluate.setDefaultParameter('settings.maxCorrActions', 1.0);
evaluate.setDefaultParameter('settings.Noise_std', 0.05);
evaluate.setDefaultParameter('settings.initSigmaActions', 1.0);
evaluate.setDefaultParameter('settings.numInitialSamplesEpisodes', -1);
evaluate.setDefaultParameter('settings.entropyBeta', 1);
evaluate.setDefaultParameter('policyInputVariables',{});
evaluate.setDefaultParameter('initialRangeMultiplier',0.01);
%evaluate.setDefaultParameter('learner', @Learner.EpisodicRL.EpisodicPIREPSLambda.CreateFromTrialForActionPolicy);
evaluate.setDefaultParameter('learner', @Learner.EpisodicRL.EpisodicPower.CreateFromTrialKnowsNoise);

% lambda = Experiments.Evaluation(...
%     {'settings.PathIntegralCostActionMultiplier'},{...
%     1; 
%     },numIterations,numTrials);
% 
% lambdaPower = Experiments.Evaluation(...
%     {'settings.temperatureScalingPower'},{...
%     7; %10; 13; 17;...
%     },numIterations,numTrials);

experiment = Experiments.Experiment.createByNameNew(experimentName, category, ...
    {configuredTask, configuredFeatures, configuredPolicy, configuredLearner}, evaluationCriterion, 5, ...
    {'127.0.0.1',2});
% 
% experiment = Experiments.Experiment.createByName(experimentName, category, ...
%     configuredTask, configuredLearner, evaluationCriterion, 5, ...
%     {'127.0.0.1',2});

experiment.addEvaluation(evaluate);
experiment.startLocal();
%experiment.startRemote();
