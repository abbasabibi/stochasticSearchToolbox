%close all;

%Common.clearClasses();
%clear all;
%clc;

%MySQL.mym('closeall');

category = 'test';
experimentName = 'test';
numTrials = 10;
numIterations = 20;

configuredTask = Experiments.Tasks.PlanarReachingInfHorizon;

%%
configuredLearner = Experiments.Learner.StepBasedRKHSREPS('NPADP');

% feature configurator
configuredFeatures = Experiments.Features.FeatureRBFKernelStatesPeriodic;
configuredActionFeatures = Experiments.Features.FeatureRBFKernelActionsProd;

% action policy configurator
configuredPolicy = Experiments.ActionPolicies.PeriodicGaussianProcessPolicyConfigurator;


evaluationCriterion = Experiments.EvaluationCriterion();



evaluationCriterion.registerEvaluator(Evaluator.ReturnEvaluatorEvaluationSamplesAverage());
%evaluationCriterion.registerEvaluator(Evaluator.SaveDataAndTrial());



evaluate3_policyfrommodel = Experiments.Evaluation(...
    {'learner','actionPolicy','policyLearner', 'settings.lipschitzConstant',...
    'useStateFeaturesForPolicy','settings.RKHSparamsstate',...
    'settings.RKHSparamsactions','settings.tolSF','settings.policyParameters',...
    'settings.epsilonAction','settings.numSamplesEvaluation',...
    'modelLearner','settings.numSamples','settings.numInitialSamplesEpisodes','settings.maxSamples','numJoints',...
    'desPos','settings.initSigmaActions'},{...
    @(trial) Learner.SteadyStateRL.NPALinearProgramming(trial.dataManager, trial.actionPolicy),...
    @(trial,ft) Functions.NPALPPolicy(trial.dataManager),...
    @(dm, pol, ft) Learner.Learner(),...   % dummy
    1, ... % lipschitz constant
    false,...
    [-1e-2 1 -0.6 -0.6 1 -5 -5 1 1 1], ... %0 indicates features should be optimized
    [-1e-2 1 1 1 1 1 1 1 -50 -50], ... %0 indicates features should be optimized
     0.0001,...
     [-500, -500,  -0.6 -0.6  1 -3 -3],...
     0.5,...
     100,...
     @(trial) Learner.ModelLearner.RKHSModelLearner_unc(trial.dataManager, ...
                ':', trial.stateFeatures,...
                trial.nextStateFeatures,trial.stateActionFeatures),...
     10,...% num samples
     30,...
     30,...
     2,... % two joints
     [0.5 0],... %desired position
     0.5, ... %sigma actions (fraction of range)
     %0.0,...epsilongreedy
     %0.3, ...explorationwidth
     %[1,1,1,1],...%feature scale
    %(dataManager, linearfunctionApproximator, varargin)
    },numIterations,numTrials);

%what is the difference between these two?
evaluate3_policyfrommodel.setDefaultParameter('settings.maxSizeReferenceSet' , 3000);
evaluate3_policyfrommodel.setDefaultParameter('maxNumberKernelSamples', 3000);

evaluate_featurescale = Experiments.Evaluation(...
    {'settings.featureScale'},...
    {[1 1 1 1]; ...
     [1 0.5 1 0.5]; ...
     [2 2 2 2];...
     [1 2 1 2];...
     [0.5 0.5 0.5 0.5]});

 evaluate_epsilongreedy = Experiments.Evaluation(...
     {'settings.epsilongreedy'},...
     {0.01; 0.03; 0.1});
 
 evaluate_epsilonwidth = Experiments.Evaluation(...
     {'settings.epsilonwidth'},...
     {0.1; 0.2; 0.3});


evalute_reps = Experiments.Evaluation.getCartesianProductOf([evaluate3_policyfrommodel,evaluate_featurescale, evaluate_epsilongreedy, evaluate_epsilonwidth]);


 
experiment = Experiments.Experiment.createByNameNew(experimentName, category, ...
    {configuredTask, configuredFeatures, configuredActionFeatures, ...
    configuredPolicy, configuredLearner}, evaluationCriterion, 5);



experiment.addEvaluation(evalute_reps);

experiment.startLocal();
%experiment.startBatch();

