clear variables;
close all;

Common.clearClasses();
%clear all;
clc;

%MySQL.mym('closeall');

category = 'test';
experimentName = 'additionalSamples';
numTrials = 21;
numIterations = 50;

configuredTask = Experiments.Tasks.DoubleLinkSwingUpFiniteHorizon();
configuredTask.addParameterSetter(@Experiments.ParameterSettings.PathIntegralRewardSettings);

%%
configuredLearner = Experiments.Learner.StepBasedQApproxLearningSetup('TimeDependentREPS');

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
            50 50; 100 100; 200 200; %400 400; 800 800;%1600 1600; 3200 3200
            }, numIterations,numTrials);

nbSampledAPerS = Experiments.Evaluation({'settings.nbSampledActionPerState'}, {...
            1; 5; 10;
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

approximator = Experiments.Evaluation(...
    {'policyEvalPreprocessor'},{...
    %    @(trial) DataPreprocessors.PolicyEvalMonteCarloPreprocessor(trial, true);
    %    @(trial) DataPreprocessors.PolicyEvalRecursiveQPreprocessor(trial);
    % @(trial) DataPreprocessors.PolicyEvalNEstimationPreprocessor(trial);
    %@(trial) DataPreprocessors.PolicyEvalVvaluePreprocessor(trial, true, true);
    @(trial) DataPreprocessors.PolicyEvalVvalueASPreprocessor(trial, true);
    @(trial) DataPreprocessors.PolicyEvalVvalueASPreprocessor(trial, false);
    @(trial) DataPreprocessors.PolicyEvalNIAPreprocessor(trial, true);
    @(trial) DataPreprocessors.PolicyEvalNIAPreprocessor(trial, false);
    %@(trial) DataPreprocessors.PolicyEvalNAndImportancePreprocessor(trial);
    %     @(trial) DataPreprocessors.PolicyEvalVvaluePreprocessor(trial, false);
    },numIterations,numTrials);

evaluate = Experiments.Evaluation.getCartesianProductOf([numSamples nbSampledAPerS approximator learner]);

evaluate.setDefaultParameter('settings.usePeriodicStateSpace', false);
evaluate.setDefaultParameter('settings.maxCorrActions', 1.0);
evaluate.setDefaultParameter('settings.Noise_std', .05);
evaluate.setDefaultParameter('settings.initSigmaActions', 1.0);
evaluate.setDefaultParameter('settings.PathIntegralCostActionMultiplier', 1.0);

% use importance sampling
evaluate.setDefaultParameter('timeIndepenpentStateActionProbabilities', @DataPreprocessors.TimeIndependentStateActionProbabilities);

experiment = Experiments.Experiment.createByName(experimentName, category, ...
    configuredTask, configuredLearner, evaluationCriterion, 5, ...
    {'127.0.0.1',2}, '/work/scratch/ra61casa/data');

experiment.addEvaluation(evaluate);
experiment.startBatch(32, 16);
%experiment.startLocal();
