close all;

Common.clearClasses();
%clear all;
clc;

%MySQL.mym('closeall');

category = 'swTest';
%category = 'test';
experimentName = 'swGP';

numTrials = 10;
numIterations = 40;
numSamples = 10;
numInitialSamples = 10;
maxSamples = 400;
numTimeSteps = 60;
epsilon = {0.25; 0.35;};
gamma = 0.99;

configuredTask = Experiments.Tasks.SwingUpTaskPrefNoTD(false);
%%
configuredFeatures = Experiments.Features.FeatureRBFKernelStatesPeriodicNew();
configuredActionFeatures = Experiments.Features.FeatureRBFKernelActionsProdNew();

configuredFeatureLearnerStatesActions = Experiments.FeatureLearner.LSTDFeatureLearner('stateActionKernel');

configuredPolicy = Experiments.ActionPolicies.GaussianProcessPolicyConfiguratorNew();
configuredQFunction = Experiments.PolicyEvaluation.LinearQFunctionConfigurator();
configuredNextStateStateActionFeatures = Experiments.PolicyEvaluation.NextStateLinearFeatureDiscreteActionQ();
configuredPolicyEvaluation = Experiments.PolicyEvaluation.StepBasedLearningSetupPolicyEvaluation('RewardBased');
configuredDensityPreprocessor = Experiments.Preprocessor.SampleDensityPreprocessor({'stateActionKernelLearnerDataName', 'policyEvaluationDataName'});
configuredActorCritic = Experiments.PolicyEvaluation.ActorCriticLearner('REPS_SA');

evaluationCriterion = Experiments.EvaluationCriterion();
evaluationCriterion.registerEvaluator(Evaluator.ReturnEvaluatorEvaluationSamples());
%evaluationCriterion.registerEvaluator(Evaluator.ReturnExplorationSigma());

evaluate = Experiments.Evaluation(...
    {'settings.epsilonAction'},epsilon,numIterations,numTrials);

%evaluate.setDefaultParameter('isPeriodic', false);
evaluate.setDefaultParameter('settings.numTimeSteps', numTimeSteps);
evaluate.setDefaultParameter('settings.dt', 0.05);
evaluate.setDefaultParameter('settings.numSamplesEpisodes', numSamples);
evaluate.setDefaultParameter('settings.numInitialSamplesEpisodes', numInitialSamples);
evaluate.setDefaultParameter('settings.maxSamples', maxSamples);
evaluate.setDefaultParameter('settings.discountFactor', gamma);
evaluate.setDefaultParameter('settings.epsilonAction', 0.5);
evaluate.setDefaultParameter('settings.softMaxRegressionTerminationFactor', 0.000001); 

evaluate.setDefaultParameter('maxNumberKernelSamples', 300);
evaluate.setDefaultParameter('settings.maxSizeReferenceSet', 300);

evaluate.setDefaultParameter('nextStateActionFeatures', @PolicyEvaluation.NextStateActionFeaturesCurrentPolicy.CreateFromTrial);
evaluate.setDefaultParameter('policyEvaluationPreProcessor', @PolicyEvaluation.PolicyEvaluationAdditionalSamplesPreProcessorNoLimits.CreateFromTrial);
%evaluate.setDefaultParameter('policyEvaluationPreProcessor', @PolicyEvaluation.PolicyEvaluationPreProcessor.CreateFromTrial);
evaluate.setDefaultParameter('policyEvaluationLearner', @PolicyEvaluation.LeastSquaresTDLearningCorrectRegularizer.CreateFromTrialLearnQFunction);
evaluate.setDefaultParameter('importanceSampler', @DataPreprocessors.ImportanceSamplingLastKPolicies);
evaluate.setDefaultParameter('GPInitializer', @Kernels.GPs.GaussianProcess.CreateSquaredExponentialPeriodicGP);
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
evaluate.setDefaultParameter('settings.kernelMedianBandwidthFactor', 0.5);
evaluate.setDefaultParameter('settings.GPVarianceNoiseFactorActions', 0.0000001);
evaluate.setDefaultParameter('settings.UseGPBugActions', 0.0);
evaluate.setDefaultParameter('settings.initSigmaActions', 0.9);

evaluate.setDefaultParameter('settings.maxNumOptiIterationsGPOptimizationActions', 50.0);
evaluate.setDefaultParameter('settings.CMAOptimizerInitialRangeGPOptimizationActions', 0.005);

evaluate.setDefaultParameter('settings.CMANumRestartsGPOptimizationActions', 1.0);
evaluate.setDefaultParameter('settings.maxSizeReferenceSet', 300);
evaluate.setDefaultParameter('settings.GPLearnerActions', 'GPSparse');
evaluate.setDefaultParameter('settings.LSTDuseBias', true);

evaluate.setDefaultParameter('settings.maxNumOptiIterationsLSTDKernelOptimizer', 0);
evaluate.setDefaultParameter('settings.InitialStateDistributionMinRange', [pi - 0.2, 0]);
evaluate.setDefaultParameter('settings.InitialStateDistributionMaxRange', [pi + 0.2, 0]);
evaluate.setDefaultParameter('settings.InitialStateDistributionType', 'Uniform');

evaluate.setDefaultParameter('settings.kernelMedianBandwidthFactorStates', 0.1);
evaluate.setDefaultParameter('settings.numLocalDataPoints', 100);

evaluate.setDefaultParameter('settings.minRelWeightReferenceSet', 10^-8);

experiment = Experiments.Experiment.createByNameNew(experimentName, category, ...
     {configuredTask, configuredFeatures, configuredActionFeatures, configuredQFunction, configuredPolicy, configuredNextStateStateActionFeatures, configuredPolicyEvaluation, configuredFeatureLearnerStatesActions, configuredDensityPreprocessor, configuredActorCritic}, evaluationCriterion, 5, ...
    {'127.0.0.1',1});

experiment.addEvaluation(evaluate);
experiment.startBatch(7*3, 3);

