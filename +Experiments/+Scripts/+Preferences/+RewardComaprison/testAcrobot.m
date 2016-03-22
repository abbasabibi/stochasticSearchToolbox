close all;

Common.clearClasses();
%clear all;
clc;

%MySQL.mym('closeall');

category = 'ACtune';
%category = 'SoftMaxv3';
experimentName = 'test';

%numTrials = 30;
numTrials = 24;
numIterations = 40;


maxSamples = 160;

numTimeSteps = 500;
gamma = 0.99;

configuredTask = Experiments.Tasks.AcrobotTask();
configuredFeatures = Experiments.Features.FeatureGrid([10,10,10,10]);

configuredPolicyEvaluation = Experiments.PolicyEvaluation.StepBasedLearningSetupPolicyEvaluation('RewardBased');
configuredPolicyLearner = Experiments.PolicyEvaluation.ActorCriticLearner('REPS_SA');

configuredQFunction = Experiments.PolicyEvaluation.LinearDiscreteActionQFunctionConfigurator();
configuredPolicy = Experiments.ActionPolicies.DiscreteInputPolicyConfigurator();
configuredNextStateActionFeature = Experiments.PolicyEvaluation.NextStateLinearFeatureDiscreteActionQ();

evaluationCriterion = Experiments.EvaluationCriterion();
evaluationCriterion.registerEvaluator(Evaluator.ReturnEvaluatorEvaluationSamples());
evaluationCriterion.registerEvaluator(Evaluator.AverageLengthEvaluatorEvaluationSamples(500));

evaluateEpsilon = Experiments.Evaluation(...
    {'settings.epsilonAction'},{0.1;0.2;0.3;0.5},numIterations,numTrials); 
evaluateEpsilonSlope = Experiments.Evaluation(...
    {'settings.epsilonSlope'},{0.01;0.05;0.1;100},numIterations,numTrials); 
evaluateLSTD1 = Experiments.Evaluation(...
    {'settings.lstdProjectionRegularizationFactor'},{10^-5; 10^-6; 10^-7; 10^-8},numIterations,numTrials);
evaluateLSTD2 = Experiments.Evaluation(...
    {'settings.lstdRegularizationFactor'},{10^-5; 10^-6; 10^-7; 10^-8},numIterations,numTrials);
evaluateMaxSamples = Experiments.Evaluation(...
    {'settings.maxSamples'},{10; 40; 80; 120; 160},numIterations,numTrials);
evaluateLearningRate = Experiments.Evaluation(...
    {'settings.lstdLearningRate'},{1.0; 0.5; 0.1},numIterations,numTrials);


experiment = Experiments.Experiment.createById('Experiment5', category, ...
    {configuredTask, configuredFeatures, configuredQFunction, configuredPolicy, configuredNextStateActionFeature, configuredPolicyEvaluation, configuredPolicyLearner}, evaluationCriterion);

experiment.addEvaluation(evaluateEpsilon,'Eval1');
experiment.addEvaluation(evaluateEpsilonSlope, 'Eval1');
%experiment.addEvaluation(evaluateLSTD1,'Eval1');
%experiment.addEvaluation(evaluateLSTD2,'Eval1');
experiment.addEvaluation(evaluateMaxSamples,'Eval1');
experiment.addEvaluation(evaluateLearningRate,'Eval1');

experiment.setDefaultParameter('settings.numTimeSteps', numTimeSteps);
experiment.setDefaultParameter('settings.maxSamples', maxSamples);
experiment.setDefaultParameter('settings.discountFactor', gamma);
experiment.setDefaultParameter('settings.softMaxRegressionTerminationFactor', 0.0001); 
experiment.setDefaultParameter('settings.epsilonAction', 0.3); 


experiment.setDefaultParameter('settings.numSamplesEpisodes', 10); 
experiment.setDefaultParameter('settings.numInitialSamplesEpisodes', 10); 

experiment.setDefaultParameter('settings.LSTDuseBias', true);
experiment.setDefaultParameter('settings.lstdBiasPrior', 0.1);

experiment.setDefaultParameter('settings.lstdRegularizationFactor',10^-8);
experiment.setDefaultParameter('settings.lstdProjectionRegularizationFactor',10^-8);
%experiment.setDefaultParameter('settings.lstdRegularizationFactor',0);
%experiment.setDefaultParameter('settings.lstdProjectionRegularizationFactor',0);

experiment.setDefaultParameter('settings.maxNumOptiIterationsEpisodicREPSOptimization', 2000);
experiment.setDefaultParameter('settings.lstdLearningRate', 1.0);

%experiment.setDefaultParameter('settings.EpisodicREPSOptimizationOptiAlgorithm', 'NLOPT_G_MLSL_LDS');

%experiment.setDefaultParameter('settings.maxNumOptiIterationsEpisodicREPSInit', 10000);
%experiment.setDefaultParameter('settings.EpisodicREPSInitOptiAlgorithm', 'CMA-ES');

experiment.setDefaultParameter('policyEvaluationLearner', @PolicyEvaluation.SparseLeastSquaresTDLearningCorrectRegularizer.CreateFromTrialLearnQFunction);

experiment.setDefaultParameter('nextStateActionFeatures', @PolicyEvaluation.NextStateActionFeatures.CreateFromTrial);  
%experiment.setDefaultParameter('nextStateActionFeatures', @PolicyEvaluation.NextStateActionFeaturesCurrentPolicy.CreateFromTrial);  
experiment.setDefaultParameter('policyEvaluationPreProcessor', @PolicyEvaluation.PolicyEvaluationDiscreteUniformActionSamplesPreProcessor.CreateFromTrial);
experiment.setDefaultParameter('importanceSampler', @DataPreprocessors.ImportanceSamplingLastKPolicies);
experiment.setDefaultParameter('actorUpdater', @Learner.EpisodicRL.DiscreteStateEpisodicREPS.CreateFromTrial);

%%
%experiment.startBatch(24,8);
%experiment.startLocal();

%%
[data, plotData] = experiment.evaluation(1).plotResults();

%%
[data, plotData] = experiment.evaluation(2).plotResults();

%%
experiment.evaluation(3).plotResults();

%%
experiment.evaluation(4).plotResults();

%%
[data, plotData] = experiment.evaluation(5).plotResults();
