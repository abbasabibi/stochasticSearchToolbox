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
configuredFeatures = Experiments.Features.FeatureRBFKernelStatesPeriodic;
configuredActionFeatures = Experiments.Features.SquaredActionPeriodicStateKernel;

% action policy configurator
configuredPolicy = Experiments.ActionPolicies.PeriodicGaussianProcessPolicyConfigurator;


evaluationCriterion = Experiments.EvaluationCriterion();



evaluationCriterion.registerEvaluator(Evaluator.ReturnEvaluatorEvaluationSamplesAverage());
%evaluationCriterion.registerEvaluator(Evaluator.SaveDataAndTrial());



evaluate3_policyfrommodel = Experiments.Evaluation(...
    { 'useStateFeaturesForPolicy',...
    'settings.RKHSparams_V','settings.RKHSparams_ns','settings.tolSF',...
    'settings.epsilonAction',...
    'settings.numSamplesEvaluation','maxNumberKernelSamples',...
    'settings.usetomlab','settings.optimalg'},{...
    false,...
    [-1e-2 1 -0.6 1 -5], ... %0 indicates features should be optimized
    [-1e-2 1 -0.6 1 -5 1 0], ... %0 indicates features should be optimized
     0.0001,...
     0.5,...
     100,...
     3000,...
     false, ... % use tomlab
     0, ... %default tomlab optim. alg
    %(dataManager, linearfunctionApproximator, varargin)
    },numIterations,numTrials);

%what is the difference between these two?
evaluate3_policyfrommodel.setDefaultParameter('settings.maxSizeReferenceSet' , 3000);
evaluate3_policyfrommodel.setDefaultParameter('maxNumberKernelSamples', 3000);
evaluate3_policyfrommodel.setDefaultParameter('settings.GPVarianceNoiseFactorActions' ,1/sqrt(2) );
evaluate3_policyfrommodel.setDefaultParameter('settings.GPVarianceFunctionFactor' ,1/sqrt(2) );
evaluate3_policyfrommodel.setDefaultParameter('settings.GPInitializer', @Kernels.GPs.GaussianProcess.CreateSquaredExponentialPeriodicGP);
evaluate3_policyfrommodel.setDefaultParameter('settings.GPLearnerInitializer', @Kernels.Learner.GPHyperParameterLearnerLOOCVLikelihood.CreateWithStandardReferenceSet);





evaluate_modellearners_rkhs = Experiments.Evaluation(...
    {'modelLearner'},...
    {...
        @(trial) Learner.ModelLearner.RKHSModelLearnernew(trial.dataManager, ...
                ':', trial.stateFeatures,...
                trial.nextStateFeatures,trial.next_s_kernel);...
    },numIterations,numTrials);






%evaluatepicturesvartemp = Experiments.Evaluation.getCartesianProductOf([evaluate_picture4_val, evaluate_temperatures]);
evaluate_modellearners_rkhs = Experiments.Evaluation.getCartesianProductOf([evaluate3_policyfrommodel, evaluate_modellearners_rkhs]);



 
experiment = Experiments.Experiment.createByNameNew(experimentName, category, ...
    {configuredTask, configuredFeatures, configuredActionFeatures, ...
    configuredPolicy, configuredLearner}, evaluationCriterion, 5);

experiment.addEvaluation(evaluate_modellearners_rkhs);


experiment.startLocal();
%experiment.startBatch(20);

