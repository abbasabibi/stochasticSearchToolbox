close all;

Common.clearClasses();
%clear all;
clc;

%MySQL.mym('closeall');

category = 'resultRuns2015';
%category = 'test';
experimentName = 'bcGPPref';

numTrials = 25;
numIterations = 25;

maxSamples = 400;

numTimeSteps = 50;

gamma = 0.98;

%configuredTask = Experiments.Tasks.GridWorldTask(@Environments.Gridworld.LargeWorld);
configuredTask = Experiments.Tasks.BicycleBalanceTask();
%%
%configuredFeatures = Experiments.Features.FeatureTabular();
configuredFeatures = Experiments.Features.FeatureRBFKernelStatesPeriodicNew();
configuredActionFeatures = Experiments.Features.FeatureRBFKernelActionsProdNew();

configuredFeatureLearnerStatesActions = Experiments.FeatureLearner.LSTDFeatureLearner('stateActionKernel');

configuredPolicy = Experiments.ActionPolicies.GaussianProcessPolicyConfiguratorNew();
configuredQFunction = Experiments.PolicyEvaluation.LinearQFunctionConfigurator();
configuredNextStateStateActionFeatures = Experiments.PolicyEvaluation.NextStateLinearFeatureDiscreteActionQ();
configuredPolicyEvaluation = Experiments.Preferences.StepAndPreferenceBasedLearningSetupPolicyEvaluation('PB',@Preferences.UtilityCalculator.BayesianUtility,true);
condiguredDensityPreprocessor = Experiments.Preprocessor.SampleDensityPreprocessor({'stateActionKernelLearnerDataName', 'policyEvaluationDataName'});
configuredActorCritic = Experiments.PolicyEvaluation.ActorCriticLearner('REPS_SA');

evaluationCriterion = Experiments.EvaluationCriterion();
evaluationCriterion.registerEvaluator(Evaluator.ReturnEvaluatorEvaluationSamples());
%evaluationCriterion.registerEvaluator(Evaluator.ReturnExplorationSigma());
evaluationCriterion.registerEvaluator(Evaluator.AverageLengthEvaluatorEvaluationSamples(3000));
evaluationCriterion.registerEvaluator(Preferences.PreferenceGenerator.PreferenceCountEvaluator());

experiment = Experiments.Experiment.createById('MeanRerun', category, ...
    {configuredTask, configuredFeatures, configuredActionFeatures, configuredQFunction, configuredPolicy, configuredNextStateStateActionFeatures, configuredPolicyEvaluation, configuredFeatureLearnerStatesActions, condiguredDensityPreprocessor, configuredActorCritic}, evaluationCriterion);

evaluateEpsilon = Experiments.Evaluation(...
    {'settings.epsilonAction'},{0.1;0.15;0.2;},numIterations,numTrials);

evaluateShape = Experiments.Evaluation(...
    {'settings.sigmoidShapeFactor'},{3},numIterations,numTrials);

%evaluate = Experiments.Evaluation.getCartesianProductOf([evaluateEpsilon,evaluateShape]);

experiment.addEvaluation(evaluateEpsilon, 'Eval1');
%experiment.addEvaluation(evaluateShape, 'Eval2');

experiment.setDefaultParameter('settings.epsilonAction', 0.3);
experiment.setDefaultParameter('settings.sigmoidShapeFactor', 3);
experiment.setDefaultParameter('settings.lstdProjectionRegularizationFactor', 10^-8);
experiment.setDefaultParameter('settings.lstdRegularizationFactor', 10^-8); 

experiment.setDefaultParameter('settings.numSamplesEpisodes', 10); 
experiment.setDefaultParameter('settings.numInitialSamplesEpisodes', 10); 
experiment.setDefaultParameter('settings.trajPrefsPerIteration', 1); 
experiment.setDefaultParameter('settings.initPrefs', 3); 

experiment.setDefaultParameter('settings.numTimeSteps', numTimeSteps);
experiment.setDefaultParameter('settings.maxSamples', maxSamples);

experiment.setDefaultParameter('policyEvaluationPreProcessor', @PolicyEvaluation.PolicyEvaluationAdditionalSamplesPreProcessorNoLimits.CreateFromTrial);
experiment.setDefaultParameter('settings.PolicyEvaluationAdditionalSampleMultiplier', 1);

experiment.setDefaultParameter('settings.numTimeSteps', numTimeSteps);
experiment.setDefaultParameter('settings.dt', 0.05);
experiment.setDefaultParameter('settings.maxSamples', maxSamples);
experiment.setDefaultParameter('settings.discountFactor', gamma);
experiment.setDefaultParameter('settings.epsilonAction', 0.5);
experiment.setDefaultParameter('settings.PolicyEvaluationPunishementLimits', 0.001);

experiment.setDefaultParameter('nextStateActionFeatures', @PolicyEvaluation.NextStateActionFeaturesCurrentPolicy.CreateFromTrial);
experiment.setDefaultParameter('policyEvaluationLearner', @PolicyEvaluation.LeastSquaresTDLearningCorrectRegularizer.CreateFromTrialLearnQFunction);
experiment.setDefaultParameter('importanceSampler', @DataPreprocessors.ImportanceSamplingLastKPolicies);
experiment.setDefaultParameter('GPInitializer', @Kernels.GPs.GaussianProcess.CreateSquaredExponentialGP);
experiment.setDefaultParameter('GPLearnerInitializer', @Kernels.Learner.GPHyperParameterLearnerTestSetLikelihood.CreateWithStandardReferenceSet);

experiment.setDefaultParameter('settings.REPSDualOptimizationToleranceX', 10^-4);
experiment.setDefaultParameter('settings.REPSDualOptimizationToleranceF', 10^-6);
experiment.setDefaultParameter('settings.softMaxRegressionToleranceF', 10^-6);
experiment.setDefaultParameter('settings.softMaxRegressionToleranceX', 10^-8);
experiment.setDefaultParameter('settings.numOptimizationsDualFunction', 20);
experiment.setDefaultParameter('settings.InitialContextDistributionType', 'Uniform');
experiment.setDefaultParameter('settings.DebugMode', true);
experiment.setDefaultParameter('settings.kernelMedianBandwidthFactor', 1.0);
experiment.setDefaultParameter('settings.GPVarianceNoiseFactorActions', 0.0000001);
experiment.setDefaultParameter('settings.UseGPBugActions', 0.0);
experiment.setDefaultParameter('settings.initSigmaActions', 0.75);

experiment.setDefaultParameter('settings.maxNumOptiIterationsGPOptimizationActions', 30.0);
experiment.setDefaultParameter('settings.CMAOptimizerInitialRangeGPOptimizationActions', 0.005);

experiment.setDefaultParameter('settings.CMANumRestartsGPOptimizationActions', 1.0);
experiment.setDefaultParameter('settings.maxSizeReferenceSet', 400);
experiment.setDefaultParameter('settings.GPLearnerActions', 'GPSparse');
experiment.setDefaultParameter('settings.LSTDuseBias', true);

experiment.setDefaultParameter('settings.maxNumOptiIterationsLSTDKernelOptimizer', 0);
experiment.setDefaultParameter('settings.InitialStateDistributionType', 'Uniform');

experiment.setDefaultParameter('settings.kernelMedianBandwidthFactorStates', 0.1);
experiment.setDefaultParameter('settings.numLocalDataPoints', 100);

experiment.setDefaultParameter('settings.minRelWeightReferenceSet', 10^-8);

experiment.setDefaultParameter('settings.REPSDualOptiAlgorithm','NLOPT_LD_LBFGS');

experiment.startBatch(4 * 5, 5);
%experiment.startLocal();
