close all;

Common.clearClasses();
%clear all;
clc;

%MySQL.mym('closeall');

category = 'test';
%category = 'testFixed';
experimentName = 'testCancer';

numTrials = 1;
numIterations = 20;
numInitialSamplesEpisodes = 1000;
numSamples = 100;

maxSamples = 20000;

numTimeSteps = 6;

gamma = 0.98;

epsilon = {0.3;0.6};

%configuredTask = Experiments.Tasks.GridWorldTask(@Environments.Gridworld.LargeWorld);
configuredTask = Experiments.Tasks.CancerSimTask();
%%
%configuredFeatures = Experiments.Features.FeatureTabular();
configuredFeatures = Experiments.Features.FeatureRBFKernelStatesPeriodicNew();
configuredActionFeatures = Experiments.Features.FeatureRBFKernelActionsProdNew();

configuredFeatureLearnerStatesActions = Experiments.FeatureLearner.LSTDFeatureLearner('stateActionKernel');

configuredPolicy = Experiments.ActionPolicies.GaussianProcessPolicyConfiguratorNew();
configuredQFunction = Experiments.PolicyEvaluation.LinearQFunctionConfigurator();
configuredNextStateStateActionFeatures = Experiments.PolicyEvaluation.NextStateLinearFeatureDiscreteActionQ();
configuredPolicyEvaluation = Experiments.PolicyEvaluation.StepBasedLearningSetupPolicyEvaluation('RewardBased');
condiguredDensityPreprocessor = Experiments.Preprocessor.SampleDensityPreprocessor({'stateActionKernelLearnerDataName', 'policyEvaluationDataName'});
configuredActorCritic = Experiments.PolicyEvaluation.ActorCriticLearner('REPS_SA');

evaluationCriterion = Experiments.EvaluationCriterion();
evaluationCriterion.registerEvaluator(Environments.Cancer.CancerSolutionEvaluator());

evaluate = Experiments.Evaluation(...
    {'settings.epsilonAction'},epsilon,numIterations,numTrials);
evaluate.setDefaultParameter('settings.numTimeSteps', numTimeSteps);
evaluate.setDefaultParameter('settings.maxSamples', maxSamples);

evaluate.setDefaultParameter('policyEvaluationPreProcessor', @PolicyEvaluation.PolicyEvaluationAdditionalSamplesPreProcessorNoLimits.CreateFromTrial);
evaluate.setDefaultParameter('settings.PolicyEvaluationAdditionalSampleMultiplier', 1);

evaluate.setDefaultParameter('settings.numTimeSteps', numTimeSteps);
evaluate.setDefaultParameter('settings.dt', 0.05);
evaluate.setDefaultParameter('settings.numSamplesEpisodes', numSamples);
evaluate.setDefaultParameter('settings.numInitialSamplesEpisodes', numInitialSamplesEpisodes);
evaluate.setDefaultParameter('settings.maxSamples', maxSamples);
evaluate.setDefaultParameter('settings.discountFactor', gamma);
evaluate.setDefaultParameter('settings.epsilonAction', 0.5);
evaluate.setDefaultParameter('settings.PolicyEvaluationPunishementLimits', 0.001);

evaluate.setDefaultParameter('nextStateActionFeatures', @PolicyEvaluation.NextStateActionFeaturesCurrentPolicy.CreateFromTrial);
evaluate.setDefaultParameter('policyEvaluationLearner', @PolicyEvaluation.LeastSquaresTDLearningCorrectRegularizer.CreateFromTrialLearnQFunction);
evaluate.setDefaultParameter('importanceSampler', @DataPreprocessors.ImportanceSamplingLastKPolicies);
evaluate.setDefaultParameter('GPInitializer', @Kernels.GPs.GaussianProcess.CreateSquaredExponentialGP);
evaluate.setDefaultParameter('GPLearnerInitializer', @Kernels.Learner.GPHyperParameterLearnerTestSetLikelihood.CreateWithStandardReferenceSet);

%evaluate.setDefaultParameter('policyEvaluationLearner', @PolicyEvaluation.LeastSquaresSARSALearning.CreateFromTrialLearnQFunction);
evaluate.setDefaultParameter('settings.REPSDualOptimizationToleranceX', 10^-4);
evaluate.setDefaultParameter('settings.REPSDualOptimizationToleranceF', 10^-6);
evaluate.setDefaultParameter('settings.softMaxRegressionToleranceF', 10^-6);
evaluate.setDefaultParameter('settings.softMaxRegressionToleranceX', 10^-8);
evaluate.setDefaultParameter('settings.numOptimizationsDualFunction', 20);
evaluate.setDefaultParameter('settings.InitialContextDistributionType', 'Uniform');
evaluate.setDefaultParameter('settings.DebugMode', true);
evaluate.setDefaultParameter('settings.PolicyEvaluationAdditionalSampleMultiplier', 1.0);
evaluate.setDefaultParameter('settings.kernelMedianBandwidthFactor', 1.0);
evaluate.setDefaultParameter('settings.GPVarianceNoiseFactorActions', 0.0000001);
evaluate.setDefaultParameter('settings.UseGPBugActions', 0.0);
evaluate.setDefaultParameter('settings.initSigmaActions', 0.75);

evaluate.setDefaultParameter('settings.maxNumOptiIterationsGPOptimizationActions', 50.0);
evaluate.setDefaultParameter('settings.CMAOptimizerInitialRangeGPOptimizationActions', 0.005);

evaluate.setDefaultParameter('settings.CMANumRestartsGPOptimizationActions', 1.0);
evaluate.setDefaultParameter('settings.maxSizeReferenceSet', 600);
evaluate.setDefaultParameter('settings.GPLearnerActions', 'GPSparse');
evaluate.setDefaultParameter('settings.LSTDuseBias', true);

evaluate.setDefaultParameter('settings.maxNumOptiIterationsLSTDKernelOptimizer', 0);
evaluate.setDefaultParameter('settings.InitialStateDistributionType', 'Uniform');

evaluate.setDefaultParameter('settings.kernelMedianBandwidthFactorStates', 0.1);
evaluate.setDefaultParameter('settings.numLocalDataPoints', 100);

evaluate.setDefaultParameter('settings.minRelWeightReferenceSet', 10^-8);



%evaluateEpsilon.setDefaultParameter('policyEvaluationLearner', @PolicyEvaluation.LeastSquaresTDLearningCorrectRegularizer.CreateFromTrialLearnQFunction);


experiment = Experiments.Experiment.createByNameNew(experimentName, category, ...
    {configuredTask, configuredFeatures, configuredActionFeatures, configuredQFunction, configuredPolicy, configuredNextStateStateActionFeatures, configuredPolicyEvaluation, configuredFeatureLearnerStatesActions, condiguredDensityPreprocessor, configuredActorCritic}, evaluationCriterion, 5, ...
    {'127.0.0.1',1});

experiment.addEvaluation(evaluate);
experiment.startBatch(3 * 8, 8);
%experiment.startLocal();
