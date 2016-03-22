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
configuredLearner = Experiments.Learner.AAStepBasedRKHSREPS('RKHSREPSPeriodic');

% feature configurator
configuredFeatures = Experiments.Features.FeatureRBFKernelStatesPeriodic;
configuredActionFeatures = Experiments.Features.SquaredActionPeriodicStateKernel;

% action policy configurator
%configuredPolicy = Experiments.ActionPolicies.PeriodicGaussianProcessPolicyConfigurator;
configuredPolicy = Experiments.ActionPolicies.AAGaussianProcessPolicyConfigurator;

evaluationCriterion = Experiments.EvaluationCriterion();



evaluationCriterion.registerEvaluator(Evaluator.ReturnEvaluatorEvaluationSamplesAverage());
%evaluationCriterion.registerEvaluator(Evaluator.SaveDataAndTrial());



evaluate3_policyfrommodel = Experiments.Evaluation(...
    {'useStateFeaturesForPolicy',...
    'settings.RKHSparams_V','settings.RKHSparams_ns','settings.RKHSparams_r','settings.tolSF',...
    'settings.policyParameters','settings.epsilonAction',...
    'settings.numSamplesEvaluation',
    'settings.numSamples','settings.numInitialSamplesEpisodes','settings.maxSamples'},{...
    false,...
    [-1e-2 1 -0.6 1 -5], ... %negative no indicates features should be optimized
    [-1e-2 1 -0.6 1 -5 1 0], ... %negative no indicates features should be optimized
    [-10 -25 -0.6 1 -5 -25 0], ... %negative no indicates features should be optimized
     0.0001,...
     [-200, -200,  -0.7114 1 -4.3664],...
     0.5,...
     100,...
     10,...% num samples per iteration
     30,...% initial samples
     30,...%max samples
    %(dataManager, linearfunctionApproximator, varargin)
    },numIterations,numTrials);

evaluate3_policyfrommodel.setDefaultParameter('settings.GPInitializer', @Kernels.GPs.GaussianProcess.CreateSquaredExponentialPeriodicGP);
evaluate3_policyfrommodel.setDefaultParameter('settings.GPLearnerInitializer', @Kernels.Learner.GPHyperParameterLearnerLOOCVLikelihood.CreateWithStandardReferenceSet);
evaluate3_policyfrommodel.setDefaultParameter('settings.tolSF',0.0001);
evaluate3_policyfrommodel.setDefaultParameter('settings.epsilonAction' , 0.5);
evaluate3_policyfrommodel.setDefaultParameter('settings.numSamplesEvaluation' , 100);
evaluate3_policyfrommodel.setDefaultParameter('settings.GPVarianceNoiseFactorActions' ,1/sqrt(2) );
evaluate3_policyfrommodel.setDefaultParameter('settings.GPVarianceFunctionFactor' ,1/sqrt(2) );

%what is the difference between these two?
evaluate3_policyfrommodel.setDefaultParameter('settings.maxSizeReferenceSet' , 3000);
evaluate3_policyfrommodel.setDefaultParameter('maxNumberKernelSamples', 3000);






evaluate_modellearners_rkhs = Experiments.Evaluation(...
    {'modelLearner'},...
    {...
        @(trial) Learner.ModelLearner.RKHSModelLearnernew(trial.dataManager, ...
                ':', trial.stateFeatures,...
                trial.nextStateFeatures,trial.next_s_kernel);...
    },numIterations,numTrials);


evaluate_modellearners_rkhs = Experiments.Evaluation.getCartesianProductOf([evaluate3_policyfrommodel, evaluate_modellearners_rkhs]);


 
experiment = Experiments.Experiment.createByNameNew(experimentName, category, ...
    {configuredTask, configuredFeatures, configuredActionFeatures, ...
    configuredLearner,configuredPolicy}, evaluationCriterion, 5);

experiment.addEvaluation(evaluate_modellearners_rkhs);


experiment.startLocal();
%experiment.startBatch(20);

