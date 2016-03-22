close all;

Common.clearClasses();
%clear all;
clc;

%MySQL.mym('closeall');

%category = 'eval1';
category = 'test';
experimentName = 'Test';

%numTrials = 10;
numTrials = 1;

numIterations = 20;
numSamples = 1000;
maxSamples = 10000;
numPrefSamples = 1000;

numTimeSteps = 6;
%epsilon = [0.05, 0.1];
epsilon = 0.4;

tau = 10;
tauDecay = 0.5;

gamma = 0.98;


kernelF = 100;

[p,q] = meshgrid(tau,tauDecay);
pairs = [p(:) q(:)];
values = num2cell(pairs);

%configuredTask = Experiments.Tasks.ClassicMountainCarTask();
%configuredTask = Experiments.Tasks.GridWorldTask(@Environments.Gridworld.RiadsWorld);
%configuredTask = Experiments.Tasks.SwingUpTask(true);
%configuredTask = Experiments.Tasks.DiscreteActionSwingUpTask(true);
configuredTask = Experiments.Tasks.CancerSimTask();

%%
configuredPolicyEvaluation = Experiments.Preferences.CancerStepAndPreferenceBasedLearningSetupPolicyEvaluation('PreferenceBased',false);
%configuredPolicyLearner = Experiments.Learner.StepBasedPolicyLearner('REPS_SA');
configuredFeatures = Experiments.Features.FeatureRBFKernelStates();
configuredQFunction = Experiments.PolicyEvaluation.LinearDiscreteActionQFunctionConfigurator();
%configuredPolicy = Experiments.ActionPolicies.SoftMaxPolicyConfigurator();
configuredPolicy = Experiments.ActionPolicies.DirectDecayingSoftMaxPolicyConfigurator();


evaluationCriterion = Experiments.EvaluationCriterion();
evaluationCriterion.registerEvaluator(Preferences.UtilityCalculator.UtilityFunctionEvaluator());
%evaluationCriterion.registerEvaluator(Evaluator.DeterministicOptimalReturnEvaluatorEvaluationSamples());

evaluate = Experiments.Evaluation(...
    {'settings.softMaxTemperature','settings.softMaxDecay'},values,numIterations,numTrials);

evaluate.setDefaultParameter('settings.numTimeSteps', numTimeSteps);
evaluate.setDefaultParameter('settings.numSamplesEpisodes', numSamples);
evaluate.setDefaultParameter('settings.maxSamples', maxSamples);
evaluate.setDefaultParameter('settings.discountFactor', gamma);
evaluate.setDefaultParameter('settings.softMaxRegressionTerminationFactor', 0.0001); 
evaluate.setDefaultParameter('settings.trajPrefsPerIteration',numPrefSamples);
evaluate.setDefaultParameter('MaxNumberKernelSamples',kernelF);

experiment = Experiments.Experiment.createByNameNew(experimentName, category, ...
    {configuredTask, configuredFeatures, configuredPolicy, configuredQFunction, configuredPolicyEvaluation}, evaluationCriterion, 5, ...
    {'127.0.0.1',1});

experiment.addEvaluation(evaluate);
%experiment.startBatch(15);
experiment.startLocal();
