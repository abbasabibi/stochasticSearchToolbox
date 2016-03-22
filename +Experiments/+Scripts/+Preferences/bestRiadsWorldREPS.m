close all;

Common.clearClasses();
%clear all;
clc;

%MySQL.mym('closeall');

category = 'testPRAC';
%category = 'test';
experimentName = 'BVIRL';

%numTrials = 50;
numTrials = 10;
numIterations = 15;

maxSamples = 10000;

numTimeSteps = 300;
gamma = 0.98;

settings = {0.325,5,50,3,5;};

configuredTask = Experiments.Tasks.GridWorldTask(@Environments.Gridworld.RiadsWorld);
%%
configuredPolicyEvaluation = Experiments.Preferences.StepAndPreferenceBasedLearningSetupPolicyEvaluation('PB',@Preferences.UtilityCalculator.BVIRLAlike,true);
configuredPolicyLearner = Experiments.PolicyEvaluation.ActorCriticLearner('REPS_SA');
configuredFeatures = Experiments.Features.FeatureTabular();
configuredQFunction = Experiments.PolicyEvaluation.LinearDiscreteActionQFunctionConfigurator();
configuredPolicy = Experiments.ActionPolicies.DiscreteInputPolicyConfigurator();
configuredNextStateActionFeature = Experiments.PolicyEvaluation.NextStateLinearFeatureDiscreteActionQ();

evaluationCriterion = Experiments.EvaluationCriterion();
evaluationCriterion.registerEvaluator(Preferences.UtilityCalculator.UtilityFunctionEvaluator());
evaluationCriterion.registerEvaluator(Preferences.PreferenceGenerator.PreferenceCountEvaluator());
evaluationCriterion.registerEvaluator(Evaluator.ReturnEvaluatorEvaluationSamples());

evaluateEpsilon = Experiments.Evaluation(...
    {'settings.epsilonAction','settings.numSamplesEpisodes','settings.numInitialSamplesEpisodes','settings.trajPrefsPerIteration','settings.initPrefs'},settings,numIterations,numTrials);
evaluateEpsilon.setDefaultParameter('settings.numTimeSteps', numTimeSteps);
evaluateEpsilon.setDefaultParameter('settings.maxSamples', maxSamples);
evaluateEpsilon.setDefaultParameter('settings.discountFactor', gamma);
evaluateEpsilon.setDefaultParameter('settings.softMaxRegressionTerminationFactor', 0.0001); 
evaluateEpsilon.setDefaultParameter('settings.iterationsForStateDistribution', 50); 

evaluate = Experiments.Evaluation.getCartesianProductOf([evaluateEpsilon]);

evaluate.setDefaultParameter('settings.LSTDuseBias', true);

evaluate.setDefaultParameter('policyEvaluationPreProcessor', @PolicyEvaluation.PolicyEvaluationDiscreteUniformActionSamplesPreProcessor.CreateFromTrial);

experiment = Experiments.Experiment.createByNameNew(experimentName, category, ...
    {configuredTask, configuredFeatures, configuredQFunction, configuredPolicy, configuredNextStateActionFeature, configuredPolicyEvaluation, configuredPolicyLearner}, evaluationCriterion, 5, ...
    {'127.0.0.1',1});

experiment.addEvaluation(evaluate);
experiment.startBatch(64,8);
%experiment.startLocal();
