%close all;

%Common.clearClasses();
%clear all;
%clc;

%MySQL.mym('closeall');
error('check whether the script works in the new toolbox!');
category = 'test';
experimentName = 'test';
numTrials = 10;
numIterations = 20;

configuredTask = Experiments.Tasks.SwingUpTaskPeriodic(true);

%%
configuredLearner = Experiments.Learner.StepBasedRKHSREPS('RKHSREPSPeriodic');

% feature configurator
configuredFeatures = Experiments.Features.FeatureRBFGridStatesPeriodic;
configuredActionFeatures = Experiments.Features.FeatureRBFGridActions;

% action policy configurator
configuredPolicy = Experiments.ActionPolicies.PeriodicGaussianProcessPolicyConfigurator;


evaluationCriterion = Experiments.EvaluationCriterion();



evaluationCriterion.registerEvaluator(Evaluator.ReturnEvaluatorEvaluationSamplesAverage());
%evaluationCriterion.registerEvaluator(Evaluator.SaveDataAndTrial());

evaluate_tilecoder = Experiments.Evaluation(...
    {'useStateFeaturesForPolicy', ...
    'settings.initRegularizationModel','settings.tolSF',
    'settings.epsilonAction','settings.numSamplesEvaluation', 'modelLearner',...
    'settings.nGridSamplesstates', 'settings.nGridSamplesnextStates','settings.nGridSamplesstatesactions'},{...
    false,...
    [-1e-2 1 1 1 5 1 30], ... %0 indicates features should be optimized
     0.0001,...
     0.5,...
     100,...
     @(trial) Learner.ModelLearner.FeatureModelLearner(trial.dataManager, ...
                ':', trial.stateFeatures,...
                trial.nextStateFeatures,trial.stateActionFeatures), ...
     [10,10],...% n grid samples
     [10,10],...% n grid samples next state
     [10,10,10],... %n grid samples states-actions
     %(dataManager, linearfunctionApproximator, varargin)
    },numIterations,numTrials);

evaluate_picture4.setDefaultParameter('settings.maxSizeReferenceSet' , 3000);
evaluate_picture4.setDefaultParameter('maxNumberKernelSamples', 3000);
evaluate_picture4.setDefaultParameter('settings.GPVarianceNoiseFactorActions' ,1/sqrt(2) );
evaluate_picture4.setDefaultParameter('settings.GPVarianceFunctionFactor' ,1/sqrt(2) );
evaluate_picture4.setDefaultParameter('settings.GPInitializer', @Kernels.GPs.GaussianProcess.CreateSquaredExponentialPeriodicGP);
evaluate_picture4.setDefaultParameter('settings.GPLearnerInitializer', @Kernels.Learner.MedianBandwidthSelectorAndGPVariance.CreateWithStandardReferenceSet);

 
experiment = Experiments.Experiment.createByNameNew(experimentName, category, ...
    {configuredTask, configuredFeatures, configuredActionFeatures, ...
    configuredPolicy, configuredLearner}, evaluationCriterion, 5);

experiment.addEvaluation(evaluate_tilecoder);


experiment.startLocal();
%experiment.startBatch();