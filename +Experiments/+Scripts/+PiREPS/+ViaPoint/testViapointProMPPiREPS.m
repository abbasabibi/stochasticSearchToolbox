close all;

Common.clearClasses();
%clear all;
clc;

category = 'test';
experimentName = 'FactorBasis';
numTrials = 4;
numIterations = 100;

configuredTask = Experiments.Tasks.ViaPoint();
configuredTask.addParameterSetter(@Experiments.ParameterSettings.PathIntegralMultiplierSettings);

%%
configuredFeatures = Experiments.Features.FeatureSquaredContextConfigurator();

configuredTrajectoryGenerator = Experiments.TrajectoryGenerators.ProMPWithController();
configuredTrajectoryLearner = Experiments.TrajectoryGenerators.ProMPDistributionLearner();

configuredLearner = Experiments.Learner.StepBasedLearningSetup('EpisodicPiREPS');

evaluationCriterion = Experiments.EvaluationCriterion();
evaluationCriterion.setSaveNumDataPoints(20);
evaluationCriterion.setSaveIterationModulo(50);

evaluate = Experiments.Evaluation(...
    {'settings.ctlPinvThresh'},{...
    5e-3 1e-3 5e-4 1e-4;    
    }, numIterations, numTrials);

evaluate.setDefaultParameter('settings.epsilonAction', .3);
evaluate.setDefaultParameter('settings.maxCorrActions', 1.0);
evaluate.setDefaultParameter('settings.usePeriodicStateSpace', 0.0);
evaluate.setDefaultParameter('settings.Noise_std', 0.5);
evaluate.setDefaultParameter('settings.initSigmaActions', 1.0);
evaluate.setDefaultParameter('settings.numSamplesEpisodes', 200);
evaluate.setDefaultParameter('settings.maxSamples', 200);
evaluate.setDefaultParameter('settings.numInitialSamplesEpisodes', -1);
% ~/policysearchtoolbox/+Learner/+SupervisedLearner
% LinearGaussianMLLearner.m
% priorCovWeightWeights 

evaluate.setDefaultParameter('settings.widthFactorBasis', 1.5);
evaluate.setDefaultParameter('settings.numBasis', 15);
evaluate.setDefaultParameter('settings.initSigmaWeights', 1);
evaluate.setDefaultParameter('settings.linearFeedbackNoiseRegularization', 10^-8);


%evaluate.setDefaultParameter('learner', @Learner.EpisodicRL.EpisodicPIREPSLambda.CreateFromTrialForActionPolicy);
evaluate.setDefaultParameter('learner', @Learner.EpisodicRL.EpisodicREPS.CreateFromTrialActionPolicy);

% lambda = Experiments.Evaluation(...
%     {'settings.PathIntegralCostActionMultiplier'},{...
%     1; 
%     },numIterations,numTrials);
experiment = Experiments.Experiment.createByNameNew(experimentName, category, ...
    {configuredTask, configuredFeatures, configuredTrajectoryGenerator, configuredTrajectoryLearner,  configuredLearner}, evaluationCriterion, 5, ...
    {'193.145.51.37',2});

experiment.addEvaluation(evaluate);
%experiment.startLocal();
%experiment.startRemote();
experiment.startBatch(16, 8);

%Plotter.PlotterData.plotTrajectoriesMeanAndStd(data, 'jointPositions', :, 1);
