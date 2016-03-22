close all;

Common.clearClasses();
%clear all;
clc;

%MySQL.mym('closeall');

category = 'best2015';
experimentName = 'SoftMax';

numTrials = 50;
%numTrials = 1;
numIterations = 25;
numPrefSamples = 3;
numInitialPrefSamples = 5;

maxSamples = 10000;

numTimeSteps = 300;
gamma = 0.98;

softMaxValues = {10,5,0.5,0.125;50,5,0.5,0.075;200,10,1.0,0.125;400,10,1.0,0.125;};
%softMaxValues = {10,0.5};

configuredTask = Experiments.Tasks.GridWorldTask(@Environments.Gridworld.RiadsWorld);
%%
configuredPolicyEvaluation = Experiments.Preferences.StepAndPreferenceBasedLearningSetupPolicyEvaluation('PreferenceBased',@Preferences.UtilityCalculator.BVIRLAlike,true);
%configuredPolicyEvaluation = Experiments.PolicyEvaluation.StepBasedLearningSetupPolicyEvaluation('RewardBased');
configuredPolicyLearner = Experiments.ActionPolicies.DirectActionPolicyConfigurator('SoftMax');
configuredFeatures = Experiments.Features.FeatureTabular();
configuredQFunction = Experiments.PolicyEvaluation.LinearDiscreteActionQFunctionConfigurator();
configuredPolicy = Experiments.ActionPolicies.DecayingSoftMaxPolicyConfigurator();
%configuredPolicy = Experiments.ActionPolicies.DirectEnGreedyPolicyConfigurator();
configuredNextStateActionFeature = Experiments.PolicyEvaluation.NextStateLinearFeatureDiscreteActionQ();

evaluationCriterion = Experiments.EvaluationCriterion();
evaluationCriterion.registerEvaluator(Preferences.UtilityCalculator.UtilityFunctionEvaluator());
evaluationCriterion.registerEvaluator(Preferences.PreferenceGenerator.PreferenceCountEvaluator());
evaluationCriterion.registerEvaluator(Evaluator.ReturnEvaluatorEvaluationSamples());

evaluateSoftMax = Experiments.Evaluation(...
    {'settings.numInitialSamplesEpisodes','settings.numSamplesEpisodes','settings.softMaxTemperature','settings.softMaxDecay'},softMaxValues,numIterations,numTrials);    
evaluateSoftMax.setDefaultParameter('settings.numTimeSteps', numTimeSteps);
evaluateSoftMax.setDefaultParameter('settings.maxSamples', maxSamples);
evaluateSoftMax.setDefaultParameter('settings.discountFactor', gamma);
evaluateSoftMax.setDefaultParameter('settings.softMaxRegressionTerminationFactor', 0.0001); 

evaluatePrefCount = Experiments.Evaluation(...
    {'settings.trajPrefsPerIteration'},numPrefSamples,numIterations,numTrials);    

evaluateInitPrefs = Experiments.Evaluation(...
    {'settings.initPrefs'},numInitialPrefSamples,numIterations,numTrials); 

evaluate = Experiments.Evaluation.getCartesianProductOf([evaluateSoftMax,evaluatePrefCount,evaluateInitPrefs]);

evaluate.setDefaultParameter('policyEvaluationPreProcessor', @PolicyEvaluation.PolicyEvaluationDiscreteUniformActionSamplesPreProcessor.CreateFromTrial);

experiment = Experiments.Experiment.createByNameNew(experimentName, category, ...
    {configuredTask, configuredFeatures, configuredQFunction, configuredPolicy, configuredNextStateActionFeature, configuredPolicyEvaluation, configuredPolicyLearner}, evaluationCriterion, 5, ...
    {'127.0.0.1',1});

experiment.addEvaluation(evaluate);
experiment.startBatch(30,3);
%experiment.startLocal();
