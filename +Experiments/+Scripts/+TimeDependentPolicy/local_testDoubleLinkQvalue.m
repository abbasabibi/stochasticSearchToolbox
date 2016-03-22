clear variables;
close all;

Common.clearClasses();
%clear all;
clc;

%MySQL.mym('closeall');

category = 'test';
experimentName = 'qValue_local';
numTrials = 1;
numIterations = 50;

configuredTask = Experiments.Tasks.DoubleLinkSwingUpFiniteHorizon();
configuredTask.addParameterSetter(@Experiments.ParameterSettings.PathIntegralRewardSettings);

%%
%configuredLearner = Experiments.Learner.StepBasedQApproxLearningSetup('TimeDependentREPS');
configuredLearner = Experiments.Learner.StepBasedDynamicProgrammingQREPS_Setup('TimeDependentREPS');

evaluationCriterion = Experiments.EvaluationCriterion();

%evaluationCriterion.saveIterationModulo(100);

% xpNumSamplesEpisodes = Experiments.Evaluation({'settings.numSamplesEpisodes'}, {...
%             20; 50; 100
%             }, numIterations,numTrials);
%
% xpMaxSamples = Experiments.Evaluation({'settings.maxSamples'}, {...
%     100; 200; 300; 600; 1200
%     }, numIterations,numTrials);

numSamples = Experiments.Evaluation({'settings.numSamplesEpisodes', 'settings.maxSamples'}, {...
    200 200; %200 200;% 1600 1600; 3200 3200
    }, numIterations,numTrials);

nbSampledAPerS = Experiments.Evaluation({'settings.nbSampledActionPerState'}, {...
    5;
    }, numIterations,numTrials);

approximator = Experiments.Evaluation(...
    {'policyEvalPreprocessor'},{...
    %    @(trial) DataPreprocessors.PolicyEvalMonteCarloPreprocessor(trial, true);
    %    @(trial) DataPreprocessors.PolicyEvalRecursiveQPreprocessor(trial);
    % @(trial) DataPreprocessors.PolicyEvalNEstimationPreprocessor(trial);
    %@(trial) DataPreprocessors.PolicyEvalVvaluePreprocessor(trial, true, true);
%     @(trial) DataPreprocessors.PolicyEvalVvalueASPreprocessor(trial, true, 'preprocessedData');
     @(trial) DataPreprocessors.PolicyEvalVvalueASPreprocessor(trial, false, 'preprocessedData');
%     @(trial) DataPreprocessors.PolicyEvalNIAPreprocessor(trial, true);
%    @(trial) DataPreprocessors.PolicyEvalNIAPreprocessor(trial, false, 'preprocessedData');
    %@(trial) DataPreprocessors.PolicyEvalNAndImportancePreprocessor(trial);
    %     @(trial) DataPreprocessors.PolicyEvalVvaluePreprocessor(trial, false);
    },numIterations,numTrials);

% learner = Experiments.Evaluation(...
%     {'learner'},{...
%    % @(trial) Learner.StepBasedRL.StepBasedREPS.CreateFromTrial(trial, 'qValue', 'preprocessedData');
%     @(trial) Learner.StepBasedRL.StepBasedDynamicProgrammingQREPS(trial, 'qValue');
%     },numIterations,numTrials);

%learner.setDefaultParameter('policyLearner', []);
%learner.setDefaultParameter('actionPolicy', TimeDependentActionPolicy);
%learner.setDefaultParameter('sampler', @Sampler.StepSampler);

evaluate = Experiments.Evaluation.getCartesianProductOf([numSamples nbSampledAPerS approximator]);

evaluate.setDefaultParameter('settings.usePeriodicStateSpace', false);
evaluate.setDefaultParameter('settings.maxCorrActions', 1.0);
evaluate.setDefaultParameter('settings.Noise_std', .05);
evaluate.setDefaultParameter('settings.initSigmaActions', 1.0);
evaluate.setDefaultParameter('settings.PathIntegralCostActionMultiplier', 1.0);
evaluate.setDefaultParameter('settings.epsilonAction', 0.5);

experiment = Experiments.Experiment.createByName(experimentName, category, ...
    configuredTask, configuredLearner, evaluationCriterion, 5, ...
    {'127.0.0.1',2});

experiment.addEvaluation(evaluate);
%experiment.startBatch(32, 16);
experiment.startLocal();
