close all;

Common.clearClasses();
%clear all;
clc;

%MySQL.mym('closeall');

category = 'swingup';
%category = 'test';
experimentName = 'lstd_REG';

numTrials = 16;
numIterations = 40;
numSamples = 10;
numInitialSamples = 10;
maxSamples = 400;
numTimeSteps = 60;
epsilon = {0.25; 0.35; 0.5};
gamma = 0.99;

configuredTask = Experiments.Tasks.SwingUpTaskPrefNoTD(false);

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
evaluationCriterion.registerEvaluator(Evaluator.PolicyVarianceEvaluator());
evaluationCriterion.registerEvaluator(Evaluator.GPPolicyVarianceEvaluator());

%evaluationCriterion.registerEvaluator(Evaluator.ReturnExplorationSigma());

evaluateLSTD1 = Experiments.Evaluation(...
    {'settings.lstdProjectionRegularizationFactor'},{10^-6; 10^-5; 10^-7; 10^-8; 10^-4},numIterations,numTrials);
evaluateLSTD2 = Experiments.Evaluation(...
    {'settings.lstdRegularizationFactor'},{10^-6; 10^-5; 10^-7; 10^-8},numIterations,numTrials);
evaluateKernelSize = Experiments.Evaluation(...
    {'settings.maxSizeReferenceSet'},{500; 700; 1000},numIterations,numTrials);
evaluateGPOptimization = Experiments.Evaluation(...
    {'settings.HyperParametersOptimizerGPOptimizationActions'},{'FMINUNC'; 'CMAES'},numIterations,numTrials);
evaluateMedianBandwidth = Experiments.Evaluation(...
    {'settings.kernelMedianBandwidthFactor'},{0.4; 0.5; 0.6; 0.7},numIterations,numTrials);



% We can create an experiment by ID now. Always the same experiment will
% be created if we do not change the ID
experiment = Experiments.Experiment.createById('Experiment8', category, ...
     {configuredTask, configuredFeatures, configuredActionFeatures, configuredQFunction, configuredPolicy, configuredNextStateStateActionFeatures, configuredPolicyEvaluation, configuredFeatureLearnerStatesActions, configuredDensityPreprocessor, configuredActorCritic}, evaluationCriterion);

% we need to add the evaluation. If we evaluate the same parameters, it
% will overwrite the stored evaluation with the same ID (eval1)
%experiment.addEvaluation(evaluateLSTD1, 'Eval1');
%experiment.addEvaluation(evaluateLSTD2, 'Eval1');
%experiment.addEvaluation(evaluateKernelSize, 'Eval1');
%experiment.addEvaluation(evaluateMedianBandwidth , 'Eval1');
experiment.addEvaluation(evaluateGPOptimization , 'Eval2');


% now we can set the default parameters
experiment.setDefaultParameter('settings.numTimeSteps', numTimeSteps);
experiment.setDefaultParameter('settings.dt', 0.05);
experiment.setDefaultParameter('settings.numSamplesEpisodes', numSamples);
experiment.setDefaultParameter('settings.numInitialSamplesEpisodes', numInitialSamples);
experiment.setDefaultParameter('settings.maxSamples', maxSamples);
experiment.setDefaultParameter('settings.discountFactor', gamma);
experiment.setDefaultParameter('settings.epsilonAction', 0.35);

experiment.setDefaultParameter('settings.lstdProjectionRegularizationFactor', 10^-8);
experiment.setDefaultParameter('settings.lstdRegularizationFactor', 10^-5);

experiment.setDefaultParameter('nextStateActionFeatures', @PolicyEvaluation.NextStateActionFeaturesCurrentPolicy.CreateFromTrial);
experiment.setDefaultParameter('policyEvaluationPreProcessor', @PolicyEvaluation.PolicyEvaluationAdditionalSamplesPreProcessorNoLimits.CreateFromTrial);
experiment.setDefaultParameter('policyEvaluationLearner', @PolicyEvaluation.LeastSquaresTDLearningCorrectRegularizer.CreateFromTrialLearnQFunction);
experiment.setDefaultParameter('importanceSampler', @DataPreprocessors.ImportanceSamplingLastKPolicies);
experiment.setDefaultParameter('GPInitializer', @Kernels.GPs.GaussianProcess.CreateSquaredExponentialPeriodicGP);
experiment.setDefaultParameter('GPLearnerInitializer', @Kernels.Learner.GPHyperParameterLearnerTestSetLikelihood.CreateWithStandardReferenceSet);

%evaluate.setDefaultParameter('policyEvaluationLearner', @PolicyEvaluation.LeastSquaresSARSALearning.CreateFromTrialLearnQFunction);
experiment.setDefaultParameter('settings.REPSDualOptimizationToleranceX', 10^-4);
experiment.setDefaultParameter('settings.REPSDualOptimizationToleranceF', 10^-6);
experiment.setDefaultParameter('settings.numOptimizationsDualFunction', 20);
experiment.setDefaultParameter('settings.InitialContextDistributionType', 'Uniform');
experiment.setDefaultParameter('settings.DebugMode', true);
experiment.setDefaultParameter('settings.PolicyEvaluationAdditionalSampleMultiplier', 1.0);
experiment.setDefaultParameter('settings.kernelMedianBandwidthFactor', 0.5);
experiment.setDefaultParameter('settings.GPVarianceNoiseFactorActions', 0.0000001);
experiment.setDefaultParameter('settings.UseGPBugActions', 0.0);
experiment.setDefaultParameter('settings.initSigmaActions', 0.9);

experiment.setDefaultParameter('settings.maxNumOptiIterationsGPOptimizationActions', 50.0);
experiment.setDefaultParameter('settings.CMAOptimizerInitialRangeGPOptimizationActions', 0.005);

experiment.setDefaultParameter('settings.CMANumRestartsGPOptimizationActions', 1.0);
experiment.setDefaultParameter('settings.maxSizeReferenceSet', 700);
experiment.setDefaultParameter('settings.GPLearnerActions', 'GPSparse');
experiment.setDefaultParameter('settings.LSTDuseBias', true);

experiment.setDefaultParameter('settings.maxNumOptiIterationsLSTDKernelOptimizer', 0);
experiment.setDefaultParameter('settings.InitialStateDistributionMinRange', [pi - 0.2, 0]);
experiment.setDefaultParameter('settings.InitialStateDistributionMaxRange', [pi + 0.2, 0]);
experiment.setDefaultParameter('settings.InitialStateDistributionType', 'Uniform');

experiment.setDefaultParameter('settings.kernelMedianBandwidthFactorStates', 0.1);
experiment.setDefaultParameter('settings.numLocalDataPoints', 100);

experiment.setDefaultParameter('settings.minRelWeightReferenceSet', 10^-8);
experiment.setDefaultParameter('settings.GPOptimizationActionsOptiAbsfTol', -1);

%%

%starts the cluster scripts for each evaluation
experiment.startLocal(48, 8);

%experiment.startLocal();

% we can also plot the results here directly (maybe disable startBatch)
% Works also during exeuction oft´ the trial
%%
[data, plotData] = experiment.evaluation(1).plotResults();

%%
[plotData] = experiment.evaluation(2).plotResults();

%%
[plotData] = experiment.evaluation(3).plotResults();

%%
[plotData] = experiment.evaluation(4).plotResults();

%%
[plotData] = experiment.evaluation(1).plotResults();






























