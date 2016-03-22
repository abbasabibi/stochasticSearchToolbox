close all;

Common.clearClasses();
%clear all;
clc;

%MySQL.mym('closeall');

category = 'test';
experimentName = 'testViapointPiREPS';
numTrials = 3;
numIterations = 100;

configuredTask = Experiments.Tasks.ViaPoint();
configuredTask.addParameterSetter(@Experiments.ParameterSettings.PathIntegralRewardSettings);

%%
configuredFeatures = Experiments.Features.FeatureSquaredConfigurator();
configuredPolicy = Experiments.ActionPolicies.TimeDependentPolicyConfigurator();

configuredLearner = Experiments.Learner.StepBasedComposedTimeDependentLearningSetup('PiREPS');


evaluationCriterion = Experiments.EvaluationCriterion();

evaluationCriterion.addCriterion('endLoop', 'data', 'states', Experiments.StoringType.STORE_PER_ITERATION, @(data)data.getDataEntry3D('states'));
evaluationCriterion.addCriterion('endLoop', 'data', 'actions', Experiments.StoringType.STORE_PER_ITERATION, @(data)data.getDataEntry3D('actions'));
evaluationCriterion.addCriterion('endLoop', 'data', 'rewards', Experiments.StoringType.STORE_PER_ITERATION, @(data)data.getDataEntry3D('rewards'));
evaluationCriterion.addCriterion('endLoop', 'data', 'finalRewards', Experiments.StoringType.STORE_PER_ITERATION, @(data)data.getDataEntry3D('finalRewards'));        

evaluate = Experiments.Evaluation(...
    {'settings.maxCorrActions',  'settings.Noise_std', 'settings.initSigmaActions'},{...
    1.0, 0.01, 0.05; ...
    },numIterations,numTrials);

numSamples = Experiments.Evaluation({'settings.numSamplesEpisode', 'settings.maxSamples'}, {...
            100, 100; 200 200; 400 400; 800 800; ...
            }, numIterations,numTrials);

lambda = Experiments.Evaluation(...
    {'settings.PathIntegralCostActionMultiplier'},{...
    0.0001 .01 1; ...
    },numIterations,numTrials);

%     0.0001

beta = Experiments.Evaluation(...
    {'settings.entropyBeta'},{...
    1.0; 
    },numIterations,numTrials);

% learner = Experiments.Evaluation(...
%     {'learner'},{...
%     @Learner.StepBasedRL.StepBasedRLPower; ...
%     },numIterations,numTrials);
learner = Experiments.Evaluation(...
    {'learner'},{...
    @Learner.StepBasedRL.StepBasedPIREPSLambda.CreateFromTrial; ...
    },numIterations,numTrials);
% learner = Experiments.Evaluation(...
%     {'learner'},{...
%     @Learner.StepBasedRL.StepBasedRLREPS; ...
%     },numIterations,numTrials);

%evaluate = Experiments.Evaluation.getCartesianProductOf([evaluate, learner, lambda, beta, numSamples]);

evaluate = learner;

evaluate.setDefaultParameter('settings.maxCorrActions',  1.0);
evaluate.setDefaultParameter('settings.Noise_std', 0.01);
evaluate.setDefaultParameter('settings.initSigmaActions', 0.1);


experiment = Experiments.Experiment.createByNameNew(experimentName, category, ...
    {configuredTask, configuredFeatures, configuredPolicy, configuredLearner}, evaluationCriterion, 5, ...
    {'127.0.0.1',2});

experiment.addEvaluation(evaluate);
experiment.startLocal();
%experiment.startRemote();

%experiment.startBatch(200);