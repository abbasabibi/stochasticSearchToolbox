close all;

Common.clearClasses();
%clear all;
clc;

%MySQL.mym('closeall');

category = 'test';


numOptions          = 10;
numSamples          = 20;
numMaxSamples       = 5*numSamples;
maxReferenceSetSize = 300;
numIterations       = 100;
epsilonAction       = 1;
epsilonOption       = 1;

dt                  = 0.01;
dtBase              = 0.05;
numStepsPerDecision = 5;
restartProb         = 0.02 * dt/dtBase * numStepsPerDecision;


doKMeansInit        = true;
keepOptionsShape    = true;

numTrials           = 10;


% numIterations   = 400;
% numSamples      = 20;
% numMaxSamples   = 2*numSamples;
% epsilon         = 1;
% epsilonOption   = 1;
% maxReferenceSetSize = 300;
% numOptions      = 10;
% restartProb     = 0.04;
% doKMeansInit    = true;
% keepOptionsShape = false;

% warning('Check that features use Offset!');
%%

configuredTask              = Experiments.Tasks.PendulumTask('PendulumPeriodic', true, true);

configuredKernelFeatures    = Experiments.Features.FeatureRBFKernelStatesPeriodicNew('contexts', 'Kernel');
configuredBandwithLearner   = Experiments.FeatureLearner.MedianBandwidthSelectorConfiguratorNew(configuredKernelFeatures.kernelName);

configuredSquaredFeatures   = Experiments.Features.FeatureSquaredConfigurator('contexts', 'Square', true)';

configuredPolicy            = Experiments.ActionPolicies.ParameterMixtureModelConfigurator('MixtureModel');

configuredLearner           = Experiments.Learner.StepBasedHiREPS('HiREPS', configuredKernelFeatures.featureOutputName);

evaluationCriterion         = Experiments.EvaluationCriterion();
evaluationCriterion.registerEvaluator(Evaluator.ReturnEvaluatorNewSamples());



% evaluationCriterion.registerEvaluator(Evaluator.ReturnEvaluatorDecisionStages(10, 2));


configuredPlotter           = Experiments.Evaluators.PendulumPlotterConfigurator(evaluationCriterion, configuredKernelFeatures, configuredSquaredFeatures);

%% TEST
 
numTrials           = 1;
 
evaluate = Experiments.Evaluation(...
    {'settings.numSamplesEpisodes'},{20},numIterations,numTrials); %test
experimentName = 'test';



%%


% evaluate = Experiments.Evaluation(...
%     {'settings.numOptions'},{1, 2, 5, 10}, numIterations,numTrials);  %numOptions
% experimentName = 'NumOptions';

% evaluate = Experiments.Evaluation(...
%     {'settings.maxSamples'},{20, 40, 80, 120},numIterations,numTrials); %MaxSamples
% experimentName = 'MaxSamples';


% evaluate = Experiments.Evaluation(...
%     {'settings.epsilonOption'},{0.9, 0.95, 1, 1.05},numIterations,numTrials); %EpsilonOption
% experimentName = 'EpsilonOption';


% evaluate = Experiments.Evaluation(...
%     {'settings.epsilonAction'},{0.9, 1, 1.1, 1.2},numIterations,numTrials); %EpsilonAction
% experimentName = 'EpsilonAction';


% evaluate = Experiments.Evaluation(...
%     {'settings.numStepsPerDecision', 'settings.resetProbDecisionSteps'},{1, 0.02 * dt/dtBase * 1; 2, 0.02 * dt/dtBase * 2; 5, 0.02 * dt/dtBase *5; 10, 0.02 * dt/dtBase *10},numIterations,numTrials); %numStepsPerDecision
% experimentName = 'numStepsPerDecision';


% evaluate = Experiments.Evaluation(...
%     {'settings.doKMeansInit', 'settings.keepOptionsShape'},{false, false;
%     true, false; true, true},numIterations,numTrials); %kmeans
% experimentName = 'kMeansAndOptionsShape';


% evaluate = Experiments.Evaluation(...
%     {'settings.maxSizeReferenceSet'},{100, 200, 300, 500, 800}, numIterations,numTrials);  %maxReferenceSet
% experimentName = 'MaxReference';

 
% evaluate = Experiments.Evaluation(...
%     {'settings.numSamplesEpisodes'},{5, 10, 20, 40},numIterations,numTrials); %test
% experimentName = 'numSamples';

%%
evaluate.setDefaultParameter('settings.numOptions', numOptions);
evaluate.setDefaultParameter('settings.epsilonAction',epsilonAction);
evaluate.setDefaultParameter('settings.epsilonOption',epsilonOption);
evaluate.setDefaultParameter('settings.initSigmaParameters',0.5);

evaluate.setDefaultParameter('settings.InitialStateDistributionType', 'Uniform');


evaluate.setDefaultParameter('settings.softMaxRegressionToleranceF', 1e-12);


evaluate.setDefaultParameter('settings.InitialContextDistributionWidth', 1.0);
evaluate.setDefaultParameter('settings.InitialContextDistributionType', 'Uniform');

evaluate.setDefaultParameter('settings.numSamplesEpisodes', numSamples);
evaluate.setDefaultParameter('settings.maxSamples', numMaxSamples);
evaluate.setDefaultParameter('settings.numInitialSamplesEpisodes', numMaxSamples);

evaluate.setDefaultParameter('settings.maxSizeReferenceSet', maxReferenceSetSize);

evaluate.setDefaultParameter('parameterGatingInputVariables', configuredSquaredFeatures.featureOutputName);
evaluate.setDefaultParameter('parameterPolicyInputVariables', 'contexts');% 'contextsForFeatures', configuredSquaredFeatures.featureOutputName
evaluate.setDefaultParameter('settings.kernelMedianBandwidthFactor', 0.5);

% evaluate.setDefaultParameter('numOptions', numOptions);



evaluate.setDefaultParameter('settings.doKMeansInit', doKMeansInit);
evaluate.setDefaultParameter('settings.keepOptionsShape', keepOptionsShape);

evaluate.setDefaultParameter('settings.debugPlottingMM', true);

evaluate.setDefaultParameter('settings.periodicRange', [-pi, pi]);

evaluate.setDefaultParameter('settings.dt', dt);
evaluate.setDefaultParameter('settings.numStepsPerDecision', numStepsPerDecision);
evaluate.setDefaultParameter('settings.resetProbDecisionSteps', restartProb);




experiment = Experiments.Experiment.createByNameNew(experimentName, category, ...
     {configuredTask, configuredKernelFeatures, configuredBandwithLearner, configuredSquaredFeatures, configuredPolicy, configuredLearner, configuredPlotter}, evaluationCriterion, 5, ...
    {'127.0.0.1',1});

experiment.addEvaluation(evaluate);
% experiment.startLocal();
experiment.startBatch(64);



% data = obj.getData({'avgReturn'}); plot(data(:).trial.avgReturn)
% data = obj.getTrialData({'avgReturn'}); [plotDataStandardReps ] = Plotter.PlotterEvaluations.preparePlotData(data, 'episodes', 'avgReturn', 'settings.numOptions', @(x_) sprintf('NumOptions = %1.3f', x_), 'ClosedFormREPSBeta', false, [], []); Plotter.PlotterEvaluations.plotData(plotDataStandardReps);
