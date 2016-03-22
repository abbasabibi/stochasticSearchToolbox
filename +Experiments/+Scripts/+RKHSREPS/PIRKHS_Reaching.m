%close all;

%Common.clearClasses();
%clear all;
%clc;

%MySQL.mym('closeall');
error('check whether the script works in the new toolbox!');
category = 'test';
experimentName = 'test';
numTrials = 1;
numIterations = 20;

configuredTask = Experiments.Tasks.PlanarReachingInfHorizon;
configuredTask.addParameterSetter(@ParameterSettings.PathIntegralMultiplierSettings);
%%
configuredLearner = Experiments.Learner.StepBasedPIRKHS('PI_RKHS');

% feature configurator
configuredFeatures = Experiments.Features.FeatureRBFKernelStatesPeriodic;
configuredActionFeatures = Experiments.Features.FeatureRBFKernelActionsProd;

% action policy configurator
configuredPolicy = Experiments.ActionPolicies.LogValFcBasedPolicyConfigurator;


evaluationCriterion = Experiments.EvaluationCriterion();



evaluationCriterion.registerEvaluator(Evaluator.ReturnEvaluatorEvaluationSamplesAverage());
%evaluationCriterion.registerEvaluator(Evaluator.SaveDataAndTrial());



evaluate3_policyfrommodel = Experiments.Evaluation(...
    {'useStateFeaturesForPolicy','settings.RKHSparamsstate',...
    'settings.numSamplesEvaluation','maxNumberKernelSamples',...
    'settings.maxSizeReferenceSet',...
    'settings.numSamplesEpisodes','settings.numInitialSamplesEpisodes',...
    'settings.maxSamples','numJoints',...
    'desPos','settings.initSigmaActions','settings.Noise_std','settings.actionCost'},{...
    false,...
    ...%[1e-2 1 0.6 0.6 1 5 5], ... %0 indicates features should be optimized
    [1e-2 1 0.6 1 5],...
     100,...
     3000,...
     3000,...
     20,...% num samples
     20,...
     20,...
     ...%2,... % two joints
     ...%[2 0],... %desired position
     1,...
     [1,0],...
     0.5, ... %sigma actions (fraction of range)
     ...1,... %Set U factor ???
     1,... %set Noise ???
     0.02, ... % action cost (changed to yield good multiplier)
    %(dataManager, linearfunctionApproximator, varargin)
    },numIterations,numTrials);

u_factors=Experiments.Evaluation(...
    {'settings.uFactor'},{0.5 1 2},numIterations,numTrials);



evalute_reps = Experiments.Evaluation.getCartesianProductOf([evaluate3_policyfrommodel, u_factors]);


 
experiment = Experiments.Experiment.createByNameNew(experimentName, category, ...
    {configuredTask, configuredFeatures, configuredActionFeatures, ...
    configuredPolicy, configuredLearner}, evaluationCriterion, 5);



experiment.addEvaluation(evalute_reps);

experiment.startLocal();
%experiment.startBatch();

