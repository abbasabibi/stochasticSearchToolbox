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
    {'settings.widthFactorBasis','settings.numBasis'},{...
    1 30; .5 30; 1.5 30;
    1 25; .5 25; 1.5 25;
    1 20; .5 20; 1.5 20;    
    }, numIterations, numTrials);
  
% 0.5 % 1 1.5;
%     10  % 20 30;
%     .25 % .5 1; ...
    
evaluate.setDefaultParameter('settings.epsilonAction', 0.3);
evaluate.setDefaultParameter('settings.maxCorrActions', 1.0);
evaluate.setDefaultParameter('settings.usePeriodicStateSpace', 0.0);
evaluate.setDefaultParameter('settings.Noise_std', 0.5);
evaluate.setDefaultParameter('settings.initSigmaActions', 1.0);
evaluate.setDefaultParameter('settings.numSamplesEpisodes', 200);
evaluate.setDefaultParameter('settings.maxSamples', 200);
evaluate.setDefaultParameter('settings.numInitialSamplesEpisodes', -1);

% evaluate.setDefaultParameter('settings.widthFactorBasis', 1);
% evaluate.setDefaultParameter('settings.numBasis', 30);
evaluate.setDefaultParameter('settings.initSigmaWeights', 0.5);
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