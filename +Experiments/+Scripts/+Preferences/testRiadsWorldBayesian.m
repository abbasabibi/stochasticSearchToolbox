close all;

Common.clearClasses();
%clear all;
clc;

%MySQL.mym('closeall');

category = 'results2015';
%category = 'test';
experimentName = 'gdTabPref';

numTrials = 25;
%numTrials = 10;
numIterations = 25;

maxSamples = 400;

numTimeSteps = 300;
gamma = 0.98;

configuredTask = Experiments.Tasks.GridWorldTask(@Environments.Gridworld.RiadsWorld);
configuredFeatures = Experiments.Features.FeatureTabular();
%%
configuredPolicyEvaluation = Experiments.Preferences.StepAndPreferenceBasedLearningSetupPolicyEvaluation('PB',@Preferences.UtilityCalculator.BayesianUtilityML,true);
configuredPolicyLearner = Experiments.PolicyEvaluation.ActorCriticLearner('REPS_SA');

configuredQFunction = Experiments.PolicyEvaluation.LinearDiscreteActionQFunctionConfigurator();
configuredPolicy = Experiments.ActionPolicies.DiscreteInputPolicyConfigurator();
configuredNextStateActionFeature = Experiments.PolicyEvaluation.NextStateLinearFeatureDiscreteActionQ();

evaluationCriterion = Experiments.EvaluationCriterion();
evaluationCriterion.registerEvaluator(Preferences.UtilityCalculator.UtilityFunctionEvaluator());
evaluationCriterion.registerEvaluator(Preferences.RankingGenerator.RankingEvaluator());
evaluationCriterion.registerEvaluator(Preferences.PreferenceGenerator.PreferenceEvaluator());
evaluationCriterion.registerEvaluator(Preferences.PreferenceGenerator.PreferenceCountEvaluator());
evaluationCriterion.registerEvaluator(Evaluator.ReturnEvaluatorEvaluationSamples());

experiment = Experiments.Experiment.createById('ExperimentMLRerun', category, ...
     {configuredTask, configuredFeatures, configuredQFunction, configuredPolicy, configuredNextStateActionFeature, configuredPolicyEvaluation, configuredPolicyLearner}, evaluationCriterion);

evaluateEpsilon = Experiments.Evaluation(...
    {'settings.epsilonAction'},{0.2;0.3},numIterations,numTrials);
evaluateShape = Experiments.Evaluation(...
    {'settings.sigmoidShapeFactor'},{10,5,3},numIterations,numTrials);
%evaluateLSTD1 = Experiments.Evaluation(...
%    {'settings.lstdProjectionRegularizationFactor'},{10^-6;10^-7;10^-8;},numIterations,numTrials);
%evaluateLSTD2 = Experiments.Evaluation(...
%    {'settings.lstdRegularizationFactor'},{10^-6;10^-7;10^-8;},numIterations,numTrials);

experiment.addEvaluation(evaluateEpsilon, 'Eval3');
%experiment.addEvaluation(evaluateShape, 'Eval2');
%experiment.addEvaluation(evaluateLSTD1, 'Eval1');
%experiment.addEvaluation(evaluateLSTD2, 'Eval1');

experiment.setDefaultParameter('settings.epsilonAction', 0.15);
experiment.setDefaultParameter('settings.sigmoidShapeFactor', 5);
experiment.setDefaultParameter('settings.lstdProjectionRegularizationFactor', 10^-8);
experiment.setDefaultParameter('settings.lstdRegularizationFactor', 10^-8); 

experiment.setDefaultParameter('settings.numTimeSteps', numTimeSteps);
experiment.setDefaultParameter('settings.maxSamples', maxSamples);
experiment.setDefaultParameter('settings.discountFactor', gamma);
experiment.setDefaultParameter('settings.softMaxRegressionTerminationFactor', 0.0001); 
experiment.setDefaultParameter('settings.iterationsForStateDistribution', 50); 

experiment.setDefaultParameter('settings.numSamplesEpisodes', 10);
experiment.setDefaultParameter('settings.numInitialSamplesEpisodes', 10); 
experiment.setDefaultParameter('settings.trajPrefsPerIteration', 1); 
experiment.setDefaultParameter('settings.initPrefs', 3); 
experiment.setDefaultParameter('settings.maxNumOptiIterationsEpisodicREPSOptimization', 1000);

experiment.setDefaultParameter('settings.LSTDuseBias', true);

experiment.setDefaultParameter('settings.bayesSamplerSamples', 200000);
experiment.setDefaultParameter('settings.bayesSamplerBurnIn', 100000);

experiment.setDefaultParameter('nextStateActionFeatures', @PolicyEvaluation.NextStateActionFeaturesCurrentPolicy.CreateFromTrial);  
%experiment.setDefaultParameter('nextStateActionFeatures', @PolicyEvaluation.DiscreteActionNextStateFeatures.CreateFromTrial);  
experiment.setDefaultParameter('policyEvaluationPreProcessor', @PolicyEvaluation.PolicyEvaluationDiscreteUniformActionSamplesPreProcessor.CreateFromTrial);
experiment.setDefaultParameter('importanceSampler', @DataPreprocessors.ImportanceSamplingLastKPolicies);
%experiment.setDefaultParameter('policyEvaluationPreProcessor', @PolicyEvaluation.PolicyEvaluationAdditionalSamplesPreProcessorNoLimits.CreateFromTrial);
%experiment.setDefaultParameter('policyEvaluationPreProcessor', @PolicyEvaluation.PolicyEvaluationPreProcessor.CreateFromTrial);

experiment.startBatch(5*10,10);
%experiment.startLocal();
