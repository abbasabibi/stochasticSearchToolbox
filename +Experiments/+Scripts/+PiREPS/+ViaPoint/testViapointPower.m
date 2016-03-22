close all;

Common.clearClasses();
%clear all;
clc;

MySQL.mym('closeall');

category = 'test';
experimentName = 'numSamples';
numTrials = 1;
numIterations = 50;

configuredTask = Experiments.Tasks.ViaPoint();
configuredTask.addParameterSetter(@ParameterSettings.PathIntegralRewardSettings);
%%
configuredLearner = Experiments.Learner.StepBasedComposedTimeDependentLearningSetup('Power');

evaluationCriterion = Experiments.EvaluationCriterion();


evaluationCriterion.addCriterion('endLoop', 'data', 'states', Experiments.StoringType.STORE_PER_ITERATION, @(data)data.getDataEntry3D('states'));
evaluationCriterion.addCriterion('endLoop', 'data', 'actions', Experiments.StoringType.STORE_PER_ITERATION, @(data)data.getDataEntry3D('actions'));
evaluationCriterion.addCriterion('endLoop', 'data', 'rewards', Experiments.StoringType.STORE_PER_ITERATION, @(data)data.getDataEntry3D('rewards'));
evaluationCriterion.addCriterion('endLoop', 'data', 'finalRewards', Experiments.StoringType.STORE_PER_ITERATION, @(data)data.getDataEntry3D('finalRewards'));        


evaluate = Experiments.Evaluation(...
    {'settings.numSamplesEpisode', 'settings.maxSamples', 'settings.maxCorrActions', 'settings.entropyBeta', 'settings.Noise_std', 'settings.initSigmaActions'},{...
     500, 500, 1.0, 1.0, 0.25, 0.025;...
    },numIterations,numTrials);

lambda = Experiments.Evaluation(...
    {'settings.PathIntegralCostActionMultiplier'},{...
    0.001; ...
    },numIterations,numTrials);


% learner = Experiments.Evaluation(...
%     {'learner'},{...
%     @Learner.StepBasedRL.StepBasedRLPower; ...
%     },numIterations,numTrials);
learner = Experiments.Evaluation(...
    {'learner'},{...
    @Learner.StepBasedRL.StepBasedPower.CreateFromTrial; ...
    },numIterations,numTrials);
% learner = Experiments.Evaluation(...
%     {'learner'},{...
%     @Learner.StepBasedRL.StepBasedRLREPS; ...
%     },numIterations,numTrials);

evaluate = Experiments.Evaluation.getCartesianProductOf([evaluate, learner, lambda]);


experiment = Experiments.Experiment.createByName(experimentName, category, ...
    configuredTask, configuredLearner, evaluationCriterion, 5, ...
    {'127.0.0.1',1});

experiment.addEvaluation(evaluate);
experiment.startLocal();
%experiment.startRemote();
