close all;

Common.clearClasses();
%clear all;
clc;

category = 'test';
experimentName = 'EpisodicPiREPS_samples';
numTrials = 1;
numIterations = 100;

configuredTask = Experiments.Tasks.ViaPoint();
configuredTask.addParameterSetter(@Experiments.ParameterSettings.PathIntegralRewardSettings);

%%
configuredFeatures = Experiments.Features.FeatureSquaredContextConfigurator();
configuredPolicy = Experiments.ActionPolicies.TimeDependentPolicyConfigurator();

configuredLearner = Experiments.Learner.StepBasedLearningSetup('EpisodicPiREPS');

evaluationCriterion = Experiments.EvaluationCriterion();
evaluationCriterion.setSaveNumDataPoints(20);
evaluationCriterion.setSaveIterationModulo(50);

evaluationCriterion.addCriterion('endLoop', 'data', 'states', Experiments.StoringType.STORE_PER_ITERATION, @(data)data.getDataEntry3D('states'));
evaluationCriterion.addCriterion('endLoop', 'data', 'actions', Experiments.StoringType.STORE_PER_ITERATION, @(data)data.getDataEntry3D('actions'));
evaluationCriterion.addCriterion('endLoop', 'data', 'rewards', Experiments.StoringType.STORE_PER_ITERATION, @(data)data.getDataEntry3D('rewards'));
evaluationCriterion.addCriterion('endLoop', 'data', 'finalRewards', Experiments.StoringType.STORE_PER_ITERATION, @(data)data.getDataEntry3D('finalRewards'));        

evaluate = Experiments.Evaluation(...
    {'settings.epsilonAction'},{...
    0.3;...
    },numIterations,numTrials);

numSamples = Experiments.Evaluation({'settings.numSamplesEpisode', 'settings.maxSamples'}, {...
            20, 20%;  100 100; 800 800; ...
            }, numIterations,numTrials);

evaluate.setDefaultParameter('settings.maxCorrActions', 1.0);
evaluate.setDefaultParameter('settings.usePeriodicStateSpace', 0.0);
evaluate.setDefaultParameter('settings.Noise_std', 0.05);
evaluate.setDefaultParameter('settings.initSigmaActions', 1.0);
% evaluate.setDefaultParameter('settings.numSamplesEpisodes', 200);
% evaluate.setDefaultParameter('settings.maxSamples', 200);
evaluate.setDefaultParameter('settings.numInitialSamplesEpisodes', -1);
evaluate.setDefaultParameter('settings.entropyBeta', 1);
evaluate.setDefaultParameter('learner', @Learner.EpisodicRL.EpisodicPIREPSLambda.CreateFromTrialForActionPolicy);

% lambda = Experiments.Evaluation(...
%     {'settings.PathIntegralCostActionMultiplier'},{...
%     1; 
%     },numIterations,numTrials);

evaluate = Experiments.Evaluation.getCartesianProductOf([evaluate, numSamples]);

experiment = Experiments.Experiment.createByNameNew(experimentName, category, ...
    {configuredTask, configuredFeatures, configuredPolicy, configuredLearner}, evaluationCriterion, 5, ...
    {'193.145.51.37',2});

experiment.addEvaluation(evaluate);
%experiment.startLocal();
%experiment.startRemote();
experiment.startBatch(16, 8);
