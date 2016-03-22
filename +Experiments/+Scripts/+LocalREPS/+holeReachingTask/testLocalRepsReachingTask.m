close all;

Common.clearClasses();
%clear all;
clc;

%MySQL.mym('closeall');

category = 'test';
experimentName = 'numSamples';
numTrials = 1;
numIterations = 10000;

%We can now use more than one configurator. This allows us to implement the
%configurators much more modular. 

configuredTask = Experiments.Tasks.PlanarReaching();
%%
configuredTrajectoryGenerator = Experiments.Learner.TrajectoryBasedLearningSetup();
configuredLearner = Experiments.Learner.BanditLearningSetupForLocalReps();



%configuredLearner.addDataPreprocessor('beginning', @DataPreprocessors.ImportanceSamplingLastKPolicies.CreateFromTrial);

evaluationCriterion = Experiments.EvaluationCriterion();
%evaluator = Evaluator.ReturnEvaluatorSearchDistributionMean();
%evaluator = Evaluator.ReturnEvaluatorEvaluationSamples();
%evaluationCriterion.registerEvaluator(evaluator);

%evaluatorWeights = Evaluator.ReturnEvaluatorSearchDistributionMean();
%evaluationCriterion.registerEvaluator(evaluatorWeights);

evaluator2 = Evaluator.ReturnEvaluatorAllSamples();
evaluationCriterion.registerEvaluator(evaluator2);

default = Experiments.Evaluation(...
    {'parameterPolicy'},{...
    @Learner.EpisodicRL.LocalREPS.CreateFromTrial; ...
    },numIterations,numTrials);

default.setDefaultParameter('settings.useGoalPos',false);
default.setDefaultParameter('settings.numSamplesEpisodes',2);
default.setDefaultParameter('settings.numInitialSamplesEpisodes', 1000);
default.setDefaultParameter('settings.maxSamples', 1000);
default.setDefaultParameter('settings.maxCorrParameters', 1.0);
default.setDefaultParameter('settings.initSigmaParameters', 0.05);
default.setDefaultParameter('settings.epsilonAction', 0.5);
default.setDefaultParameter('settings.bandwidthFactor', 0.5);
default.setDefaultParameter('useFeaturesForPolicy',false);
default.setDefaultParameter('settings.useViaPointContext', true);
default.setDefaultParameter('settings.useholeRadiusContext',false);
default.setDefaultParameter('settings.InitialContextDistributionType', 'Gaussian');
default.setDefaultParameter('settings.InitialContextDistributionWidth', 0.2);
default.setDefaultParameter('settings.viaPointNoise', 0.0);
default.setDefaultParameter('numBasis', 5); 
default.setDefaultParameter('numJoints', 5);
default.setDefaultParameter('settings.numBasis', 5); 
default.setDefaultParameter('settings.numJoints', 5);
default.setDefaultParameter('useVirtualSamples', false);


evaluate1 = Experiments.Evaluation(...
    {'settings.bandwidthFactor'},{0.25,0.5,1,2,100},numIterations,numTrials);
evaluate1.setDefaultParametersFromEvaluation(default);


%The createByName Function is new. It can take a list of configurators.

experiment = Experiments.Experiment.createByNameNew(experimentName, category, ...
    {configuredTask, configuredTrajectoryGenerator, configuredLearner}, evaluationCriterion, 5, ...
    {'127.0.0.1',2});

experiment.addEvaluation(evaluate1);

experiment.startBatch(50);

%experiment.startLocal();
%experiment.startRemote();
