close all;

Common.clearClasses();
%clear all;
clc;

%MySQL.mym('closeall');

category = 'unifiedRun';
%category = 'test';
experimentName = 'swLTPref';

numTrials = 10;
numIterations = 40;
numSamples = 10;
numInitialSamples = 10;
maxSamples = 400;
numTimeSteps = 60;

settings = {0.3,10,10,1,3;};

gamma = 0.99;

configuredTask = Experiments.Tasks.SwingUpTaskPref(false);
%%
configuredFeatures = Experiments.Features.FeatureLinearGaussianTime();
configuredActionFeatures = Experiments.Features.FeatureRBFKernelActionsProdNew();

configuredFeatureLearnerStatesActions = Experiments.FeatureLearner.LSTDFeatureLearner('stateActionKernel');

configuredPolicy = Experiments.ActionPolicies.LinearActionPolicyConfigurator();
configuredQFunction = Experiments.PolicyEvaluation.LinearQFunctionConfigurator();
configuredNextStateStateActionFeatures = Experiments.PolicyEvaluation.NextStateLinearFeatureDiscreteActionQ();
configuredPolicyEvaluation = Experiments.Preferences.StepAndPreferenceBasedLearningSetupPolicyEvaluation('PB',@Preferences.UtilityCalculator.BayesianUtility,true);
configuredDensityPreprocessor = Experiments.Preprocessor.SampleDensityPreprocessor({});
configuredActorCritic = Experiments.Preferences.PrefActorCriticLearner('REPS_SA');

evaluationCriterion = Experiments.EvaluationCriterion();
evaluationCriterion.registerEvaluator(Evaluator.ReturnEvaluatorEvaluationSamples());
%evaluationCriterion.registerEvaluator(Evaluator.ReturnExplorationSigma());
evaluationCriterion.registerEvaluator(Preferences.PreferenceGenerator.PreferenceCountEvaluator());

evaluate = Experiments.Evaluation(...
    {'settings.epsilonAction','settings.numSamplesEpisodes','settings.numInitialSamplesEpisodes','settings.trajPrefsPerIteration','settings.initPrefs'},settings,numIterations,numTrials);

evaluate.setDefaultParameter('isPeriodic', false);

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
evaluate.setDefaultParameter('policyEvaluationPreProcessor', @PolicyEvaluation.PolicyEvaluationPreProcessor.CreateFromTrial);
evaluate.setDefaultParameter('policyEvaluationLearner', @PolicyEvaluation.LeastSquaresTDLearningCorrectRegularizer.CreateFromTrialLearnQFunction);
evaluate.setDefaultParameter('importanceSampler', @DataPreprocessors.ImportanceSamplingLastKPolicies);

%evaluate.setDefaultParameter('policyEvaluationLearner', @PolicyEvaluation.LeastSquaresSARSALearning.CreateFromTrialLearnQFunction);
evaluate.setDefaultParameter('settings.REPSDualOptimizationToleranceX', 10^-4);
evaluate.setDefaultParameter('settings.REPSDualOptimizationToleranceF', 10^-6);
evaluate.setDefaultParameter('settings.softMaxRegressionToleranceF', 10^-6);
evaluate.setDefaultParameter('settings.softMaxRegressionToleranceX', 10^-8);
evaluate.setDefaultParameter('settings.numOptimizationsDualFunction', 30);
evaluate.setDefaultParameter('settings.InitialContextDistributionType', 'Uniform');
evaluate.setDefaultParameter('settings.DebugMode', true);
evaluate.setDefaultParameter('settings.PolicyEvaluationAdditionalSampleMultiplier', 1.0);
evaluate.setDefaultParameter('settings.maxNumOptiIterationsLSTDKernelOptimizer', 0);

evaluate.setDefaultParameter('settings.LSTDuseBias', true);

evaluate.setDefaultParameter('settings.InitialStateDistributionMinRange', [pi - 0.2, 0]);
evaluate.setDefaultParameter('settings.InitialStateDistributionMaxRange', [pi + 0.2, 0]);
evaluate.setDefaultParameter('settings.InitialStateDistributionType', 'Uniform');

evaluate.setDefaultParameter('settings.kernelMedianBandwidthFactorStates', 0.1);
evaluate.setDefaultParameter('settings.numLocalDataPoints', 100);

evaluate.setDefaultParameter('settings.minRelWeightReferenceSet', 10^-8);

evaluate.setDefaultParameter('settings.numBasis', 20);
%evaluate.setDefaultParameter('policyEvaluationPreProcessor', @PolicyEvaluation.PolicyEvaluationAdditionalSamplesPreProcessor.CreateFromTrial);
%evaluate.setDefaultParameter('useImportanceSampling', false);


experiment = Experiments.Experiment.createByNameNew(experimentName, category, ...
     {configuredTask, configuredFeatures, configuredActionFeatures, configuredQFunction,  configuredPolicy, configuredNextStateStateActionFeatures, configuredPolicyEvaluation, configuredFeatureLearnerStatesActions, configuredDensityPreprocessor, configuredActorCritic}, evaluationCriterion, 5, ...
    {'127.0.0.1',1});

experiment.addEvaluation(evaluate);
experiment.startBatch(40, 10);

