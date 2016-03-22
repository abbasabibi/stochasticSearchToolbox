close all;

Common.clearClasses();
%clear all;
clc;

%MySQL.mym('closeall');

category = 'test';
%category = 'test';
experimentName = 'test';

numTrials = 1;
numIterations = 50;
numSamples = 10;
maxSamples = 300;
%numTimeSteps = 60;
epsilon = {1.0;};
gamma = 0.99;

configuredTask = Environments.SL.Tasks.SLBeerPongConfigurator();

%%
configuredTrajectoryGenerator = Experiments.TrajectoryGenerators.TrajectoryBasedLearningSetup();
%%
configuredFeatures = Experiments.Features.FeatureLinearGaussianTime();
configuredActionFeatures = Experiments.Features.FeatureQuadraticGaussianTimeAction();

%configuredFeatureLearnerStatesActions = Experiments.FeatureLearner.LSTDFeatureLearner('stateActionKernel');

configuredPolicy = Experiments.ActionPolicies.LinearActionPolicyConfigurator();
configuredQFunction = Experiments.PolicyEvaluation.LinearQFunctionConfigurator();
configuredNextStateStateActionFeatures = Experiments.PolicyEvaluation.NextStateLinearFeatureDiscreteActionQ();
configuredPolicyEvaluation = Experiments.PolicyEvaluation.StepBasedLearningSetupPolicyEvaluation('RewardBased');
%condiguredDensityPreprocessor = Experiments.Preprocessor.SampleDensityPreprocessor({'stateActionKernelLearnerDataName', 'policyEvaluationDataName'});
configuredActorCritic = Experiments.PolicyEvaluation.ActorCriticLearner('REPS_SA');

evaluationCriterion = Experiments.EvaluationCriterion();
evaluationCriterion.registerEvaluator(Evaluator.ReturnEvaluatorEvaluationSamples());
evaluationCriterion.registerEvaluator(Evaluator.ReturnExplorationSigma());

evaluate = Experiments.Evaluation(...
    {'settings.epsilonAction'},epsilon,numIterations,numTrials);

%evaluate.setDefaultParameter('isPeriodic', false);

%evaluate.setDefaultParameter('settings.numTimeSteps', numTimeSteps);
evaluate.setDefaultParameter('settings.dt', 0.05);
evaluate.setDefaultParameter('settings.numSamplesEpisodes', numSamples);
evaluate.setDefaultParameter('settings.numInitialSamplesEpisodes', numSamples * 2);
evaluate.setDefaultParameter('settings.maxSamples', maxSamples);
evaluate.setDefaultParameter('settings.discountFactor', gamma);
evaluate.setDefaultParameter('settings.epsilonAction', 0.5);
evaluate.setDefaultParameter('settings.softMaxRegressionTerminationFactor', 0.000001); 
evaluate.setDefaultParameter('maxNumberKernelSamples', 300);

evaluate.setDefaultParameter('settings.initSigmaActions',0.5);
            
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

evaluate.setDefaultParameter('settings.LSTDuseBias', true);

evaluate.setDefaultParameter('settings.InitialStateDistributionType', 'Uniform');

evaluate.setDefaultParameter('settings.minRelWeightReferenceSet', 10^-8);

evaluate.setDefaultParameter('settings.numBasis', 5);

evaluate.setDefaultParameter('settings.useGoalPos', true);
evaluate.setDefaultParameter('settings.useWeights', true);
evaluate.setDefaultParameter('settings.basisEndTime', 1.0);
evaluate.setDefaultParameter('settings.useInitialCupPositionX', false);
evaluate.setDefaultParameter('settings.useInitialCupPositionY', false);
%evaluate.setDefaultParameter('policyEvaluationPreProcessor', @PolicyEvaluation.PolicyEvaluationAdditionalSamplesPreProcessor.CreateFromTrial);
%evaluate.setDefaultParameter('useImportanceSampling', false);


experiment = Experiments.Experiment.createByNameNew(experimentName, category, ...
     {configuredTask, configuredTrajectoryGenerator, configuredFeatures, configuredActionFeatures, configuredQFunction, configuredPolicy, configuredNextStateStateActionFeatures, configuredPolicyEvaluation, configuredActorCritic}, evaluationCriterion, 5, ...
    {'127.0.0.1',1});

experiment.addEvaluation(evaluate);
experiment.startBatch(50, 10);

