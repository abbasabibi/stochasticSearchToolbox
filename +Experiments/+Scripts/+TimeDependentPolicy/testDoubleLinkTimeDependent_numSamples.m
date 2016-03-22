clear variables;
close all;

Common.clearClasses();
%clear all;
clc;

%MySQL.mym('closeall');

category = 'test';
experimentName = 'rewardsToCome_numSamples';
numTrials = 1;
numIterations = 50;

configuredTask = Experiments.Tasks.DoubleLinkSwingUpFiniteHorizon();
configuredTask.addParameterSetter(@Experiments.ParameterSettings.PathIntegralRewardSettings);

%%
configuredLearner = Experiments.Learner.StepBasedQApproxLearningSetup('TimeDependentREPS');

evaluationCriterion = Experiments.EvaluationCriterion();

%evaluationCriterion.saveNumDataPoints(0);

numSamples = Experiments.Evaluation({'settings.numSamplesEpisodes', 'settings.maxSamples'}, {...
            100 100;% 1600 1600; 3200 3200
            }, numIterations,numTrials);

% learner = Experiments.Evaluation(...
%     {'learner'},{...
%     @Learner.StepBasedRL.StepBasedRLPower; ...
%     },numIterations,numTrials);
learner = Experiments.Evaluation(...
    {'learner'},{...
    @(trial) Learner.StepBasedRL.StepBasedREPS.CreateFromTrial(trial, 'qValue'); ...
%    @(trial) Learner.StepBasedRL.StepBasedREPS.CreateFromTrial(trial, 'rewardsToCome'); ...
    },numIterations,numTrials);
% learner = Experiments.Evaluation(...
%     {'learner'},{...
%     @Learner.StepBasedRL.StepBasedRLREPS; ...
%     },numIterations,numTrials);

%learner.setDefaultParameter('policyLearner', []);
%learner.setDefaultParameter('actionPolicy', TimeDependentActionPolicy);
%learner.setDefaultParameter('sampler', @Sampler.StepSampler);

evaluate = Experiments.Evaluation.getCartesianProductOf([numSamples learner]);
evaluate.setDefaultParameter('settings.usePeriodicStateSpace', false);
evaluate.setDefaultParameter('settings.maxCorrActions', 1.0);
evaluate.setDefaultParameter('settings.Noise_std', .05);
evaluate.setDefaultParameter('settings.initSigmaActions', 1.0);
evaluate.setDefaultParameter('settings.PathIntegralCostActionMultiplier', 1.0);

experiment = Experiments.Experiment.createByName(experimentName, category, ...
    configuredTask, configuredLearner, evaluationCriterion, 5, ...
    {'127.0.0.1',2});%, '/work/scratch/ra61casa/data');

experiment.addEvaluation(evaluate);
%experiment.startBatch(32, 16);
experiment.startLocal();
