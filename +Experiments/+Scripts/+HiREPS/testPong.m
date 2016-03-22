close all;

Common.clearClasses();
%clear all;
clc;

%MySQL.mym('closeall');

category = 'test';
%category = 'test';
experimentName = 'PongNumOptionsAngle';

numTrials       = 10;
numIterations   = 90;
numSamples      = 50;
numMaxSamples   = 50;
% numTimeSteps    = 60;
epsilon         = 0.5;
% gamma           = 0.7;
maxReferenceSetSize = 300;
numOptions      = 20;

%%

configuredTask              = Experiments.Tasks.PongTask('Pong', true);

configuredKernelFeatures    = Experiments.Features.FeatureRBFKernelStatesPeriodicNew('contextsForFeatures', 'Kernel');
configuredBandwithLearner   = Experiments.FeatureLearner.MedianBandwidthSelectorConfiguratorNew(configuredKernelFeatures.kernelName);

configuredSquaredFeatures   = Experiments.Features.FeatureSquaredConfigurator('contextsForFeatures', 'Square',true)';

configuredPolicy            = Experiments.ActionPolicies.ParameterMixtureModelConfigurator('MixtureModel');

configuredLearner           = Experiments.Learner.StepBasedHiREPS('HiREPS', configuredKernelFeatures.featureOutputName);

evaluationCriterion         = Experiments.EvaluationCriterion();
evaluationCriterion.registerEvaluator(Evaluator.ReturnEvaluatorNewSamples());

% plotter = Evaluator.PongPlotter(environment.field);
% evaluationCriterion.registerEvaluator(plotter);

configuredPlotter           = Experiments.Evaluators.PongPlotterConfigurator(evaluationCriterion);


% plotter = Evaluator.PongPlotter(environment.field);
% evaluationCriterion.registerEvaluator(plotter);
 
evaluate = Experiments.Evaluation(...
    {'settings.numOptions'},{1, 2, 5, 10},numIterations,numTrials);  %numOptions

% evaluate = Experiments.Evaluation(...  
%     {'parameterPolicyInputVariables'},{configuredSquaredFeatures.featureOutputName,
%     'contextsForFeatures'},numIterations,numTrials); %PolicyFeatures


% evaluate = Experiments.Evaluation(...
%     {'settings.numSamplesEpisodes'},{10, 25, 50, 75, 100},numIterations,numTrials); %NumSamples


% evaluate = Experiments.Evaluation(...
%     {'settings.maxSizeReferenceSet'},{100, 200, 300}, numIterations,numTrials);  %maxReferenceSet

% evaluate = Experiments.Evaluation(...
%     {'settings.doKMeansInit'},{true, false}, numIterations,numTrials);  %doKMeans

% 
% evaluate = Experiments.Evaluation(...
%     {'settings.maxSamples'},{50, 100, 200, 300, 500},numIterations,numTrials); %NumMaxSamples

% evaluate = Experiments.Evaluation(...
%     {'settings.epsilonOption'},{0.9, 0.95, 1, 1.05, 1.1},numIterations,numTrials); %EpsilonOption
%%
evaluate.setDefaultParameter('settings.numOptions', numOptions);
evaluate.setDefaultParameter('settings.epsilonOption',1);
evaluate.setDefaultParameter('settings.initSigmaParameters',0.3);

evaluate.setDefaultParameter('settings.InitialStateDistributionMinRange', [-1 -1 -1 0.1 0 -50]);
evaluate.setDefaultParameter('settings.InitialStateDistributionMaxRange', [1 1 1 1 0 -50]);

evaluate.setDefaultParameter('settings.numDecisionSteps', 2);

evaluate.setDefaultParameter('settings.InitialStateDistributionType', 'Uniform');


% settings.setProperty('maxSamplesEpisodes', 200);
evaluate.setDefaultParameter('settings.resetProbDecisionSteps', 0.3);

evaluate.setDefaultParameter('settings.softMaxRegressionToleranceF', 1e-12);

% settings for the initial context distribution (which is startPos and
% startVel)
evaluate.setDefaultParameter('settings.InitialContextDistributionWidth', 1.0);
evaluate.setDefaultParameter('settings.InitialContextDistributionType', 'Uniform');

evaluate.setDefaultParameter('settings.maxSamples', numMaxSamples);
evaluate.setDefaultParameter('settings.maxSizeReferenceSet', maxReferenceSetSize);

evaluate.setDefaultParameter('parameterGatingInputVariables', configuredSquaredFeatures.featureOutputName);
evaluate.setDefaultParameter('parameterPolicyInputVariables', 'contextsForFeatures');% 'contextsForFeatures', configuredSquaredFeatures.featureOutputName

% evaluate.setDefaultParameter('numOptions', numOptions);

evaluate.setDefaultParameter('settings.numSamplesEpisodes', numSamples);
evaluate.setDefaultParameter('settings.numInitialSamplesEpisodes', numMaxSamples);

evaluate.setDefaultParameter('settings.doKMeansInit', false);

experiment = Experiments.Experiment.createByNameNew(experimentName, category, ...
     {configuredTask, configuredKernelFeatures, configuredBandwithLearner, configuredSquaredFeatures, configuredPolicy, configuredLearner, configuredPlotter}, evaluationCriterion, 5, ...
    {'127.0.0.1',1});

experiment.addEvaluation(evaluate);
% experiment.startLocal();
experiment.startBatch(100);



% data = obj.getData({'avgReturn'}); plot(data(:).trial.avgReturn)
% data = obj.getTrialData({'avgReturn'}); [plotDataStandardReps ] = Plotter.PlotterEvaluations.preparePlotData(data, 'episodes', 'avgReturn', 'settings.numOptions', @(x_) sprintf('NumOptions = %1.3f', x_), 'ClosedFormREPSBeta', false, [], []); Plotter.PlotterEvaluations.plotData(plotDataStandardReps);

