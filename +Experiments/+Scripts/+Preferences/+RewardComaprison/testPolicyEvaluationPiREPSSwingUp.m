close all;

Common.clearClasses();
%clear all;
clc;

%MySQL.mym('closeall');

category = 'unifiedRun';
%category = 'test';
experimentName = 'swLT';

numTrials = 1;
numIterations = 200;
numSamples = 400;
numInitialSamples = 400;
maxSamples = 400;
numTimeSteps = 60;
epsilon = {0.3;};
gamma = 0.96;

configuredTask = Experiments.Tasks.SwingUpTaskPref(false);
configuredTask.addParameterSetter(@Experiments.ParameterSettings.PathIntegralRewardSettings);

%%
configuredFeatures = Experiments.Features.FeatureSquaredContextConfigurator();
configuredPolicy = Experiments.ActionPolicies.TimeDependentPolicyConfigurator();

configuredLearner = Experiments.Learner.StepBasedLearningSetup('EpisodicPiREPS');

evaluationCriterion = Experiments.EvaluationCriterion();
evaluationCriterion.registerEvaluator(Evaluator.ReturnEvaluatorEvaluationSamples());

%evaluationCriterion.registerEvaluator(Evaluator.ReturnExplorationSigma());

evaluate = Experiments.Evaluation(...
    {'settings.epsilonAction'},epsilon,numIterations,numTrials);

evaluate.setDefaultParameter('settings.EpisodicREPSOptimizationOptiAlgorithm', 'FMinCon');
evaluate.setDefaultParameter('settings.numTimeSteps', numTimeSteps);
evaluate.setDefaultParameter('settings.dt', 0.066);
evaluate.setDefaultParameter('settings.numSamplesEpisodes', numSamples);
evaluate.setDefaultParameter('settings.numInitialSamplesEpisodes', numInitialSamples);
evaluate.setDefaultParameter('settings.maxSamples', maxSamples);
evaluate.setDefaultParameter('settings.epsilonAction', 0.5);
evaluate.setDefaultParameter('settings.PathIntegralCostActionMultiplier', 0.01);
evaluate.setDefaultParameter('settings.usePeriodicReward', false);
evaluate.setDefaultParameter('settings.discountFactor', 0.96);
evaluate.setDefaultParameter('InitialConfigurationRange', [0 0] + pi);

evaluate.setDefaultParameter('settings.initSigmaActions',0.5);
            
evaluate.setDefaultParameter('settings.REPSDualOptimizationToleranceX', 10^-4);
evaluate.setDefaultParameter('settings.REPSDualOptimizationToleranceF', 10^-6);
evaluate.setDefaultParameter('settings.numOptimizationsDualFunction', 30);
evaluate.setDefaultParameter('settings.InitialContextDistributionType', 'Uniform');
evaluate.setDefaultParameter('settings.DebugMode', true);

evaluate.setDefaultParameter('settings.maxCorrActions', 1.0);
evaluate.setDefaultParameter('settings.usePeriodicStateSpace', 0.0);
evaluate.setDefaultParameter('settings.Noise_std', 0.05);
evaluate.setDefaultParameter('settings.initSigmaActions', 1.0);
evaluate.setDefaultParameter('settings.entropyBeta', 1);
evaluate.setDefaultParameter('learner', @Learner.EpisodicRL.EpisodicPIREPSLambda.CreateFromTrialForActionPolicy);



%evaluate.setDefaultParameter('policyEvaluationPreProcessor', @PolicyEvaluation.PolicyEvaluationAdditionalSamplesPreProcessor.CreateFromTrial);
%evaluate.setDefaultParameter('useImportanceSampling', false);


experiment = Experiments.Experiment.createByNameNew(experimentName, category, ...
     {configuredTask, configuredFeatures, configuredPolicy, configuredLearner}, evaluationCriterion, 5, ...
    {'127.0.0.1',1});

experiment.addEvaluation(evaluate);
experiment.startBatch(50, 10);

