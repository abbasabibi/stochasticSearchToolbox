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
configuredFeatures = Experiments.Features.FeatureRBFKernelStatesPicture;
configuredActionFeatures = Experiments.Features.FeatureRBFKernelActionsProd;

% action policy configurator
configuredPolicy = Experiments.ActionPolicies.PicturesGaussianProcessPolicyConfigurator;


evaluationCriterion = Experiments.EvaluationCriterion();



evaluationCriterion.registerEvaluator(Evaluator.ReturnEvaluatorEvaluationSamplesAverage());
%evaluationCriterion.registerEvaluator(Evaluator.SaveDataAndTrial());









%less blur on pictures
evaluate_picture4 = Experiments.Evaluation(...
    {...'actionPolicy','policyLearner', 
    'useStateFeaturesForPolicy',...
    'settings.RKHSparamsstate','settings.RKHSparamsactions',...
    'settings.tolSF','settings.epsilonAction',...
    'settings.numSamplesEvaluation','maxNumberKernelSamples'},{...
    ...@(trial, ft) Distributions.NonParametric.GaussianProcessPolicy(trial.dataManager,trial.policyFeatures,'statesPicture'),...
    ...@(dm, pol, ft) Learner.SupervisedLearner.GaussianProcessPolicyLearner3(...
    ... dm,pol,'sampleWeights', 'statesPicture', 'actions',ft),...
     false,...
    [-1e-2 1 -0.5 1 -0.5 1   1], ... %0 indicates features should be optimized
    [-1e-2 1  1 1 1 1 -50], ... %0 indicates features should be optimized
     0.0001,...
     0.5,...
     100,...
    },numIterations,numTrials);

%what is the difference between these two?
evaluate_picture4.setDefaultParameter('settings.maxSizeReferenceSet' , 3000);
evaluate_picture4.setDefaultParameter('maxNumberKernelSamples', 3000);
evaluate_picture4.setDefaultParameter('settings.GPVarianceNoiseFactorActions' ,1/sqrt(2) );
evaluate_picture4.setDefaultParameter('settings.GPVarianceFunctionFactor' ,1/sqrt(2) );
evaluate_picture4.setDefaultParameter('settings.GPInitializer', @Kernels.GPs.GaussianProcess.CreateSquaredExponentialPeriodicGP);
evaluate_picture4.setDefaultParameter('settings.GPLearnerInitializer', @Kernels.Learner.GPHyperParameterLearnerLOOCVLikelihood.CreateWithStandardReferenceSet);

evaluate_modellearners = Experiments.Evaluation(...
    {'modelLearner'},...
    {...
        @(trial) Learner.ModelLearner.RKHSModelLearner_unc(trial.dataManager, ...
                ':', trial.stateFeatures,...
                trial.nextStateFeatures,trial.stateActionFeatures);...
    },numIterations,numTrials);







evaluatepicture = Experiments.Evaluation.getCartesianProductOf([evaluate_picture4, evaluate_modellearners]);




 
experiment = Experiments.Experiment.createByNameNew(experimentName, category, ...
    {configuredTask, configuredFeatures, configuredActionFeatures, ...
    configuredPolicy, configuredLearner}, evaluationCriterion, 5);

experiment.addEvaluation(evaluatepicture);


experiment.startLocal();
%experiment.startBatch();

