close all;

Common.clearClasses();
%clear all;
clc;

%MySQL.mym('closeall');

category = 'tuneRuns';
%category = 'testFixed';
experimentName = 'acGP';

numTrials = 2;
numIterations = 5;
numInitialSamplesEpisodes = 10;
numSamples = 10;

maxSamples = 40;

numTimeSteps = 500;

gamma = 0.99;

epsilon = {0.3,0.4,0.5};

configuredTask = Experiments.Tasks.AcrobotTask(false);
%%
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


%settings object can be used to influence the default trial
settings = Common.Settings();
settings.setProperty('GPLearnerInitializer', @Kernels.Learner.GPHyperParameterLearnerTestSetLikelihood.CreateWithStandardReferenceSet)


experiment = Experiments.ExperimentFromConfigurators(category, ...
     {configuredTask, configuredFeatures, configuredActionFeatures, configuredQFunction, configuredPolicy, configuredNextStateStateActionFeatures, configuredPolicyEvaluation, configuredFeatureLearnerStatesActions, configuredDensityPreprocessor, configuredActorCritic}, evaluationCriterion, numIterations);


experiment.defaultSettings.numTimeSteps =  numTimeSteps;
experiment.defaultSettings.maxSamples = maxSamples;

experiment.defaultSettings.policyEvaluationPreProcessor = @PolicyEvaluation.PolicyEvaluationAdditionalSamplesPreProcessorNoLimits.CreateFromTrial;
experiment.defaultSettings.PolicyEvaluationAdditionalSampleMultiplier = 1;

experiment.defaultSettings.numTimeSteps = numTimeSteps;
experiment.defaultSettings.numSamplesEpisodes = numSamples;
experiment.defaultSettings.numInitialSamplesEpisodes = numInitialSamplesEpisodes;
experiment.defaultSettings.maxSamples = maxSamples;
experiment.defaultSettings.discountFactor = gamma;
experiment.defaultSettings.epsilonAction = 0.2;

experiment.defaultSettings.nextStateActionFeatures = @PolicyEvaluation.NextStateActionFeaturesCurrentPolicy.CreateFromTrial;
experiment.defaultSettings.policyEvaluationPreProcessor = @PolicyEvaluation.PolicyEvaluationAdditionalSamplesPreProcessorNoLimits.CreateFromTrial;
experiment.defaultSettings.policyEvaluationLearner = @PolicyEvaluation.LeastSquaresTDLearningCorrectRegularizer.CreateFromTrialLearnQFunction;
experiment.defaultSettings.importanceSampler = @DataPreprocessors.ImportanceSamplingLastKPolicies;
experiment.defaultSettings.GPInitializer = @Kernels.GPs.GaussianProcess.CreateSquaredExponentialPeriodicGP;
experiment.defaultSettings.GPLearnerInitializer = @Kernels.Learner.GPHyperParameterLearnerTestSetLikelihood.CreateWithStandardReferenceSet;

experiment.defaultSettings.REPSDualOptimizationToleranceX = 10^-4;
experiment.defaultSettings.REPSDualOptimizationToleranceF = 10^-6;
experiment.defaultSettings.numOptimizationsDualFunction = 20;
experiment.defaultSettings.DebugMode = true;
experiment.defaultSettings.kernelMedianBandwidthFactor = 1.0;
experiment.defaultSettings.GPVarianceNoiseFactorActions = 0.0000001;
experiment.defaultSettings.UseGPBugActions = 0.0;
experiment.defaultSettings.initSigmaActions = 3.0;

experiment.defaultSettings.GPOptimizationActionsNumIterations = 100.0;
experiment.defaultSettings.maxSizeReferenceSet = 300;
experiment.defaultSettings.GPLearnerActions = 'GPSparse';
experiment.defaultSettings.LSTDuseBias = true;

experiment.defaultSettings.LSTDKernelOptimizerNumIterations = 0;

experiment.defaultSettings.kernelMedianBandwidthFactorStates = 0.1;
experiment.defaultSettings.numLocalDataPoints = 100;
experiment.defaultSettings.lstdBiasPrior = 0.0;

experiment.defaultSettings.minRelWeightReferenceSet = 10^-8;

%experiment.startBatch(5 * 5, 5);
experiment = Experiments.Experiment.addToDataBase(experiment);

% We can add single evaluations
evaluation1 = experiment.addEvaluation({'epsilonAction'}, {0.2}, numTrials);
evaluation2 = experiment.addEvaluation({'epsilonAction'}, {0.3}, numTrials);

% or an evaluation collection (same parameter settings are simply reused)
evaluationCol1 = experiment.addEvaluationCollection({'epsilonAction'}, {0.2; 0.3; 0.5}, numTrials);

experiment.defaultSettings.GPOptimizationActionsOptiAlgorithm = 'CMA-ES';
evaluationCol2 = experiment.addEvaluationCollection({'epsilonAction'}, {0.2; 0.3; 0.5}, numTrials);

% Start experiment
experiment.startLocal()

%We can also just start evaluations or collections
%evaluationCol1.startLocal();

%%
evaluationCol1.plotResultsTrials()

