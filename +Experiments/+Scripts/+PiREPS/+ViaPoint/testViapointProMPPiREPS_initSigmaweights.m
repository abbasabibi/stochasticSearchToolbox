close all;

Common.clearClasses();
%clear all;
clc;

category = 'test';
experimentName = 'InitSigmaWeights';
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

widthFactorBasis = Experiments.Evaluation(...
    {'settings.widthFactorBasis'},{...
    .25 .5 1 1.5;
    }, numIterations, numTrials);

initSigmaWeights = Experiments.Evaluation(...
    {'settings.initSigmaWeights'},{...
    .25 .5 1 1.5 2;
    }, numIterations, numTrials);

numBasis = Experiments.Evaluation(...
    {'settings.numBasis'},{...
    10 15 20 25 30 35;
    }, numIterations, numTrials);

evaluate.setDefaultParameter('settings.epsilonAction', 0.3);
evaluate.setDefaultParameter('settings.maxCorrActions', 1.0);
evaluate.setDefaultParameter('settings.usePeriodicStateSpace', 0.0);
evaluate.setDefaultParameter('settings.Noise_std', 0.5);
evaluate.setDefaultParameter('settings.initSigmaActions', 1.0);
evaluate.setDefaultParameter('settings.numSamplesEpisodes', 200);
evaluate.setDefaultParameter('settings.maxSamples', 200);
evaluate.setDefaultParameter('settings.numInitialSamplesEpisodes', -1);

evaluate.setDefaultParameter('settings.linearFeedbackNoiseRegularization', 10^-8);

evaluate = Experiments.Evaluation.getCartesianProductOf([evaluate, initSigmaWeights numBasis]);

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