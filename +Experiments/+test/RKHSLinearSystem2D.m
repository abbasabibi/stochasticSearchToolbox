%close all;

%Common.clearClasses();
%clear all;
%clc;

%MySQL.mym('closeall');

category = 'test';
experimentName = 'test';
numTrials = 10;
numIterations = 15;

configuredTask = Experiments.Tasks.StepBasedLinear2D(true);

%%
configuredLearner = Experiments.Learner.StepBasedRKHSREPS('RKHSREPSPeriodic');


% feature configurator
configuredFeatures = Experiments.Features.FeatureRBFKernelStates;
configuredActionFeatures = Experiments.Features.FeatureRBFKernelActionsProd;

% action policy configurator
configuredPolicy = Experiments.ActionPolicies.GaussianProcessPolicyConfigurator;

evaluationCriterion = Experiments.EvaluationCriterion();

evaluationCriterion.registerEvaluator(Evaluator.ReturnEvaluatorEvaluationSamples());
%evaluationCriterion.registerEvaluator(Evaluator.SaveDataAndTrial());


evaluate3_policyfrommodel = Experiments.Evaluation(...
    {'actionPolicy','policyLearner', 'useStateFeaturesForPolicy',...
    'settings.RKHSparamsstate','settings.RKHSparamsactions',...
    'settings.tolSF','settings.policyParameters','settings.epsilonAction',...
    'settings.numSamplesEvaluation','maxNumberKernelSamples'},{...
    @(trial,ft) Distributions.NonParametric.GaussianProcessPolicy(trial.dataManager,trial.policyFeatures),...
    @(dm, pol, ft)Learner.SupervisedLearner.GaussianProcessPolicyLearner3(dm,pol,'sampleWeights', 'states', 'actions',ft),...  
    false,...
    [-1e-2  1  -7 -40  -7  -40  1    1    1], ... %negative values indicates features should be optimized
    [-1e-2  1   1   1   1    1  1 -200 -200], ... %negative values indicates features should be optimized
     0.0001,...
     [-300, -300,  -4 -22 -4 -22],...
     0.5,... % higher KL?...
     100,...
     600,...
    %(dataManager, linearfunctionApproximator, varargin)
    },numIterations,numTrials);



singlemodellearner = Experiments.Evaluation(...
    {'modelLearner'},...
    {...
        @Learner.ModelLearner.RKHSModelLearner_unc;...
    },numIterations,numTrials);

%'vanilla' version
evalute_RKHSREPS = Experiments.Evaluation.getCartesianProductOf([evaluate3_policyfrommodel, singlemodellearner]);


 
%experiment = Experiments.Experiment.createByName(experimentName, category, configuredTask, configuredLearner, evaluationCriterion, 5);
experiment = Experiments.Experiment.createByNameNew(experimentName, category, ...
    {configuredTask, configuredFeatures, configuredActionFeatures, ...
    configuredPolicy, configuredLearner}, evaluationCriterion, 5);

experiment.addEvaluation(evalute_RKHSREPS);


experiment.startLocal();
%experiment.startBatch();

