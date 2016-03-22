%close all;

%Common.clearClasses();
%clear all;
%clc;

%MySQL.mym('closeall');

category = 'test';
experimentName = 'test';
numTrials = 10;
numIterations = 20;

configuredTask = Experiments.Tasks.SwingUpTaskPeriodic(true);

%%
configuredLearner = Experiments.Learner.StepBasedRKHSREPS('RKHSREPSPeriodic');

% feature configurator
configuredFeatures = Experiments.Features.FeatureRBFKernelStatesPeriodicNew;
%configuredActionFeatures = Experiments.Features.FeatureRBFKernelActionsProdNew;
configureModelKernel = Experiments.Features.ModelFeatures;

% action policy configurator
configuredPolicy = Experiments.ActionPolicies.GaussianProcessPolicyConfiguratorNew;


evaluationCriterion = Experiments.EvaluationCriterion();



evaluationCriterion.registerEvaluator(Evaluator.ReturnEvaluatorEvaluationSamplesAverage());
%evaluationCriterion.registerEvaluator(Evaluator.SaveDataAndTrial());


evaluate = Experiments.Evaluation(...
    {},{},numIterations,numTrials);

evaluate.setDefaultParameter('GPInitializer', @Kernels.GPs.GaussianProcess.CreateSquaredExponentialPeriodicGP);
evaluate.setDefaultParameter('GPLearnerInitializer', @Kernels.Learner.GPHyperParameterLearnerCVTrajLikelihood.CreateWithStandardReferenceSet);
evaluate.setDefaultParameter('useStateFeaturesForPolicy' , false);

evaluate.setDefaultParameter('settings.RKHSparams_V' , [-1e-2 -0.6 -5]);
evaluate.setDefaultParameter('settings.RKHSparams_ns' ,[-1e-2 -0.6 -5 -50] );
evaluate.setDefaultParameter('settings.tolSF',0.0001);
evaluate.setDefaultParameter('settings.epsilonAction' , 0.5);
evaluate.setDefaultParameter('settings.numSamplesEvaluation' , 100);
evaluate.setDefaultParameter('settings.GPVarianceNoiseFactorActions' ,1/sqrt(2) );
evaluate.setDefaultParameter('settings.GPVarianceFunctionFactor' ,1/sqrt(2) );

%what is the difference between these two?
evaluate.setDefaultParameter('settings.maxSizeReferenceSet' , 3000);
evaluate.setDefaultParameter('maxNumberKernelSamples', 3000);



evaluate_modellearners_rkhs = Experiments.Evaluation(...
    {'modelLearner'},...
    {...
        @(trial) Learner.ModelLearner.RKHSModelLearnernew(trial.dataManager, ...
                ':', trial.stateFeatures,...
                trial.nextStateFeatures,trial.modelKernel);...
    },numIterations,numTrials);






evaluate_modellearners_rkhs = Experiments.Evaluation.getCartesianProductOf([evaluate, evaluate_modellearners_rkhs]);



 
experiment = Experiments.Experiment.createByNameNew(experimentName, category, ...
    {configuredTask, configuredFeatures, configureModelKernel, ...
    configuredPolicy, configuredLearner}, evaluationCriterion, 5);

experiment.addEvaluation(evaluate_modellearners_rkhs);


experiment.startLocal();
%experiment.startBatch(20);

