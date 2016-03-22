close all;

Common.clearClasses();
%clear all;
clc;

%MySQL.mym('closeall');

category = 'tuneRuns';
%category = 'testFixed';
experimentName = 'acGP';

numTrials = 12;
numIterations = 25;
numInitialSamplesEpisodes = 10;
numSamples = 10;

maxSamples = 120;

numTimeSteps = 500;

gamma = 0.99;

epsilon = {0.2, 0.4, 0.8};

configuredTask = Experiments.Tasks.AcrobotTask(false);
%configuredFeatures = Experiments.Features.FeatureTabular();

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
evaluationCriterion.registerEvaluator(Evaluator.AverageLengthEvaluatorEvaluationSamples(500));

evaluateEpsilon = Experiments.Evaluation(...
    {'settings.epsilonAction'},epsilon,numIterations,numTrials);

evaluateBandwith = Experiments.Evaluation(...
    {'settings.kernelMedianBandwidthFactor'},{1.0; 2.0; 4.0},numIterations,numTrials);

evaluateKernelSize = Experiments.Evaluation(...
    {'settings.maxSizeReferenceSet'},{ 600; 1200; 1600},numIterations,numTrials);

evaluateMaxSamples = Experiments.Evaluation(...
    {'settings.maxSamples'},{ 40; 80; 12; 16},numIterations,numTrials);


%evaluateEpsilon.setDefaultParameter('policyEvaluationLearner', @PolicyEvaluation.LeastSquaresTDLearningCorrectRegularizer.CreateFromTrialLearnQFunction);


experiment = Experiments.Experiment.createById('Experiment4', category, ...
     {configuredTask, configuredFeatures, configuredActionFeatures, configuredQFunction, configuredPolicy, configuredNextStateStateActionFeatures, configuredPolicyEvaluation, configuredFeatureLearnerStatesActions, configuredDensityPreprocessor, configuredActorCritic}, evaluationCriterion);

%experiment.addEvaluation(evaluateEpsilon);
%experiment.addEvaluation(evaluateBandwith);
%experiment.addEvaluation(evaluateKernelSize);
experiment.addEvaluation(evaluateMaxSamples);


experiment.setDefaultParameter('settings.numTimeSteps', numTimeSteps);
experiment.setDefaultParameter('settings.maxSamples', maxSamples);

experiment.setDefaultParameter('policyEvaluationPreProcessor', @PolicyEvaluation.PolicyEvaluationAdditionalSamplesPreProcessorNoLimits.CreateFromTrial);
experiment.setDefaultParameter('settings.PolicyEvaluationAdditionalSampleMultiplier', 1);

experiment.setDefaultParameter('settings.numTimeSteps', numTimeSteps);
experiment.setDefaultParameter('settings.dt', 0.05);
experiment.setDefaultParameter('settings.numSamplesEpisodes', numSamples);
experiment.setDefaultParameter('settings.numInitialSamplesEpisodes', numInitialSamplesEpisodes);
experiment.setDefaultParameter('settings.maxSamples', maxSamples);
experiment.setDefaultParameter('settings.discountFactor', gamma);
experiment.setDefaultParameter('settings.epsilonAction', 0.2);
experiment.setDefaultParameter('settings.PolicyEvaluationPunishementLimits', 0.00);

experiment.setDefaultParameter('nextStateActionFeatures', @PolicyEvaluation.NextStateActionFeaturesCurrentPolicy.CreateFromTrial);
experiment.setDefaultParameter('policyEvaluationPreProcessor', @PolicyEvaluation.PolicyEvaluationAdditionalSamplesPreProcessorNoLimits.CreateFromTrial);
experiment.setDefaultParameter('policyEvaluationLearner', @PolicyEvaluation.LeastSquaresTDLearningCorrectRegularizer.CreateFromTrialLearnQFunction);
experiment.setDefaultParameter('importanceSampler', @DataPreprocessors.ImportanceSamplingLastKPolicies);
experiment.setDefaultParameter('GPInitializer', @Kernels.GPs.GaussianProcess.CreateSquaredExponentialPeriodicGP);
experiment.setDefaultParameter('GPLearnerInitializer', @Kernels.Learner.GPHyperParameterLearnerTestSetLikelihood.CreateWithStandardReferenceSet);

%evaluate.setDefaultParameter('policyEvaluationLearner', @PolicyEvaluation.LeastSquaresSARSALearning.CreateFromTrialLearnQFunction);
experiment.setDefaultParameter('settings.REPSDualOptimizationToleranceX', 10^-4);
experiment.setDefaultParameter('settings.REPSDualOptimizationToleranceF', 10^-6);
experiment.setDefaultParameter('settings.softMaxRegressionToleranceF', 10^-6);
experiment.setDefaultParameter('settings.softMaxRegressionToleranceX', 10^-8);
experiment.setDefaultParameter('settings.numOptimizationsDualFunction', 20);
experiment.setDefaultParameter('settings.InitialContextDistributionType', 'Uniform');
experiment.setDefaultParameter('settings.DebugMode', true);
experiment.setDefaultParameter('settings.PolicyEvaluationAdditionalSampleMultiplier', 1.0);
experiment.setDefaultParameter('settings.kernelMedianBandwidthFactor', 2.0);
experiment.setDefaultParameter('settings.GPVarianceNoiseFactorActions', 0.0000001);
experiment.setDefaultParameter('settings.UseGPBugActions', 0.0);
experiment.setDefaultParameter('settings.initSigmaActions', 3.0);

experiment.setDefaultParameter('settings.maxNumOptiIterationsGPOptimizationActions', 50.0);

experiment.setDefaultParameter('settings.CMAOptimizerInitialRangeGPOptimizationActions', 0.005);

experiment.setDefaultParameter('settings.CMANumRestartsGPOptimizationActions', 1.0);
experiment.setDefaultParameter('settings.OptiAbsfTol', 1.0);
experiment.setDefaultParameter('settings.maxSizeReferenceSet', 600);
experiment.setDefaultParameter('settings.GPLearnerActions', 'GPSparse');
experiment.setDefaultParameter('settings.LSTDuseBias', true);

experiment.setDefaultParameter('settings.maxNumOptiIterationsLSTDKernelOptimizer', 0);
experiment.setDefaultParameter('settings.InitialStateDistributionType', 'Uniform');

experiment.setDefaultParameter('settings.kernelMedianBandwidthFactorStates', 0.1);
experiment.setDefaultParameter('settings.numLocalDataPoints', 100);
experiment.setDefaultParameter('settings.lstdBiasPrior', 0.0);

experiment.setDefaultParameter('settings.minRelWeightReferenceSet', 10^-8);

%%
experiment.startBatch(24, 6);

%%
% we can also plot the results here directly (maybe disable startBatch)
% Works also during exeuction oft´ the trial
%%
[data, plotData] = experiment.evaluation(1).plotResults();

%%
[plotData] = experiment.evaluation(2).plotResults();

%%
[plotData] = experiment.evaluation(3).plotResults();
