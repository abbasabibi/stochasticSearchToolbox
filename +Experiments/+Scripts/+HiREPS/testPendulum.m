close all;

Common.clearClasses();
%clear all;
clc;

%MySQL.mym('closeall');

category = 'test';
%category = 'test';
% experimentName = 'Pendulum';

numTrials       = 7;
numIterations   = 400;
numSamples      = 30;
numMaxSamples   = 2*numSamples;
% numTimeSteps    = 60;
epsilon         = 1;
epsilonOption   = 1;
% gamma           = 0.7;
maxReferenceSetSize = 500;
numOptions      = 5;
restartProb     = 0.04;

%%

configuredTask              = Experiments.Tasks.PendulumTask('Pendulum', true);

configuredKernelFeatures    = Experiments.Features.FeatureRBFKernelStatesPeriodicNew('contexts', 'Kernel');
configuredBandwithLearner   = Experiments.FeatureLearner.MedianBandwidthSelectorConfiguratorNew(configuredKernelFeatures.kernelName);

configuredSquaredFeatures   = Experiments.Features.FeatureSquaredConfigurator('contexts', 'Square', true);

configuredPolicy            = Experiments.ActionPolicies.ParameterMixtureModelConfigurator('MixtureModel');

configuredLearner           = Experiments.Learner.StepBasedHiREPS('HiREPS', configuredKernelFeatures.featureOutputName);

evaluationCriterion         = Experiments.EvaluationCriterion();
evaluationCriterion.registerEvaluator(Evaluator.ReturnEvaluatorNewSamples());



evaluationCriterion.registerEvaluator(Evaluator.ReturnEvaluatorDecisionStages(100, 250));


configuredPlotter           = Experiments.Evaluators.PendulumPlotterConfigurator(evaluationCriterion, configuredKernelFeatures);



%%
 

 
% evaluate = Experiments.Evaluation(...
%     {'settings.numSamplesEpisodes'},{10},numIterations,numTrials); %test
% experimentName = 'test';


evaluate = Experiments.Evaluation(...
    {'settings.numSamplesEpisodes', 'settings.maxSamples'},{10, 20; 20, 40; 30, 60;},numIterations,numTrials); %NumSamples
experimentName = 'numSamples';


% evaluate = Experiments.Evaluation(...
%     {'settings.numOptions'},{1, 2, 5, 10, 20}, numIterations,numTrials);  %numOptions
% experimentName = 'NumOptions';


% evaluate = Experiments.Evaluation(...
%     {'settings.maxSizeReferenceSet'},{100, 200, 300}, numIterations,numTrials);  %maxReferenceSet
% experimentName = 'MaxReference';



% evaluate = Experiments.Evaluation(...
%     {'settings.maxSamples'},{30, 50, 100, 200, 300, 500},numIterations,numTrials); %NumMaxSamples
% experimentName = 'MaxSamples';


% evaluate = Experiments.Evaluation(...
%     {'settings.epsilonOption'},{0.9, 0.95, 1, 1.05, 1.1},numIterations,numTrials); %EpsilonOption
% experimentName = 'EpsilonOption';


% evaluate = Experiments.Evaluation(...
%     {'settings.epsilonAction'},{0.8, 0.9, 1, 1.1, 1.2},numIterations,numTrials); %EpsilonAction
% experimentName = 'EpsilonAction';

%%
evaluate.setDefaultParameter('settings.numOptions', numOptions);
evaluate.setDefaultParameter('settings.epsilonOption',epsilonOption);
evaluate.setDefaultParameter('settings.initSigmaParameters',0.5);

% evaluate.setDefaultParameter('settings.InitialStateDistributionMinRange', [-1 -1 -1 0.1 0 -50]);
% evaluate.setDefaultParameter('settings.InitialStateDistributionMaxRange', [1 1 1 1 0 -50]);

% evaluate.setDefaultParameter('settings.numDecisionSteps', 2);

evaluate.setDefaultParameter('settings.InitialStateDistributionType', 'Uniform');


% settings.setProperty('maxSamplesEpisodes', 200);
evaluate.setDefaultParameter('settings.resetProbDecisionSteps', restartProb);

evaluate.setDefaultParameter('settings.softMaxRegressionToleranceF', 1e-12);

% settings for the initial context distribution (which is startPos and
% startVel)
evaluate.setDefaultParameter('settings.InitialContextDistributionWidth', 1.0);
evaluate.setDefaultParameter('settings.InitialContextDistributionType', 'Uniform');

evaluate.setDefaultParameter('settings.maxSamples', numMaxSamples);
evaluate.setDefaultParameter('settings.maxSizeReferenceSet', maxReferenceSetSize);

evaluate.setDefaultParameter('parameterGatingInputVariables', configuredSquaredFeatures.featureOutputName);
evaluate.setDefaultParameter('parameterPolicyInputVariables', 'contexts');% 'contextsForFeatures', configuredSquaredFeatures.featureOutputName
evaluate.setDefaultParameter('settings.kernelMedianBandwidthFactor', 0.5);

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

