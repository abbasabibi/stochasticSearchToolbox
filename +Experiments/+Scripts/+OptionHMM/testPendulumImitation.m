close all;

Common.clearClasses();
%clear all;
clc;

%MySQL.mym('closeall');

category = 'test';


numOptions          = 20;
numSamples          = 50;

doKMeansInit        = true;
keepOptionsShape    = true;

numTrials           = 10;


numEMIterations     = 30;
numTimeSteps        = 50;

numIterations       = 1;


EMThreshold         = 5e-1;




%%

configuredData              = Experiments.Preprocessor.LoadFromFileConfigurator('Helper/PendulumTrajs/data.mat');

configuredTask              = Experiments.Tasks.PendulumOptionTask('PendulumPeriodic', true, true);

configuredSquaredFeatures   = Experiments.Features.FeatureSquaredConfigurator('states', 'Square', true)';

configuredLinearFeatures    = Experiments.Features.FeatureLinearConfigurator('states', 'Linear', true)';

configuredPolicy            = Experiments.ActionPolicies.TerminationMMConfigurator('MixtureModel');

% configuredLearner           = needed for trial.resetInitalData

evaluationCriterion         = Experiments.EvaluationCriterion();
evaluationCriterion.registerEvaluator(Evaluator.EvaluatorLLH('Helper/PendulumTrajs/dataTest.mat') );
evaluationCriterion.addSaveDataEntry('llhOnTestset');

% configuredPlotter           = Experiments.Evaluators.PendulumPlotterConfigurator(evaluationCriterion, configuredKernelFeatures, configuredSquaredFeatures);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TESTING ONLY
% numTrials           = 2;
% numEMIterations     = 5;
% 
% % evaluate = Experiments.Evaluation(...
% %     {'settings.numSamplesEpisodes'},{20},numIterations,numTrials); %test
% % experimentName = 'test';
% 

% evaluate = Experiments.Evaluation(...
%     {'settings.numOptions'},{ 2; 5}, numIterations,numTrials);  %numOptions
% experimentName = 'test';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%


% evaluate = Experiments.Evaluation(...
%     {'settings.numOptions'},{1, 2, 5, 10, 20, 30}, numIterations,numTrials);  %numOptions
% experimentName = 'NumOptions';


% evaluate = Experiments.Evaluation(...
%     {'settings.useKMeans'},{false; true},numIterations,numTrials); %kmeans
% experimentName = 'kMeansAndOptionsShape';

%  
% evaluate = Experiments.Evaluation(...
%     {'settings.numImitationEpisodes'},{50; 100; 200; },numIterations,numTrials); %numImitationEpisodes
% experimentName = 'numSamples';


% evaluate = Experiments.Evaluation(...
%     {'settings.numIterationsEM'},{10; 25; 50; 75; 100;},numIterations,numTrials); %numIterEM
% experimentName = 'numIterEM';

% evaluate = Experiments.Evaluation(...
%     {'settings.numImitationSteps'},{30; 40; 50;},numIterations,numTrials); %numImitationSteps
% experimentName = 'numImitationSteps';

% evaluate = Experiments.Evaluation(...
%     {'settings.logLikelihoodThresholdEM'},{1e-3; 1e-2; 1e-1; 1; 10},numIterations,numTrials); %logLikelihoodThresholdEM
% experimentName = 'logLikelihoodThresholdEM';

evaluate = Experiments.Evaluation(...
    {'settings.logisticRegressionNumIterations'},{1e2; 1e3; 1e4},numIterations,numTrials); %logisticRegressionNumIterations
experimentName = 'logisticRegressionNumIterations';
%%
evaluate.setDefaultParameter('settings.numOptions', numOptions);


evaluate.setDefaultParameter('settings.InitialStateDistributionType', 'Uniform');


evaluate.setDefaultParameter('settings.softMaxRegressionToleranceF', 1e-12);

evaluate.setDefaultParameter('actionGatingInputVariables', configuredSquaredFeatures.featureOutputName);
evaluate.setDefaultParameter('policyInputVariables', 'states');% 'contextsForFeatures', configuredSquaredFeatures.featureOutputName

evaluate.setDefaultParameter('settings.numIterationsEM', numEMIterations);


evaluate.setDefaultParameter('settings.useKMeans', doKMeansInit);
evaluate.setDefaultParameter('settings.keepOptionsShape', keepOptionsShape);


evaluate.setDefaultParameter('sampler', @Sampler.EpisodeWithStepsSamplerOptions);

evaluate.setDefaultParameter('usePolicyForInitialLearner', true);

evaluate.setDefaultParameter('numIterations', numIterations);

evaluate.setDefaultParameter('settings.numImitationEpisodes', numSamples);
evaluate.setDefaultParameter('settings.numImitationSteps', numTimeSteps);

evaluate.setDefaultParameter('settings.logLikelihoodThresholdEM', EMThreshold);

evaluate.setDefaultParameter('settings.logisticRegressionRegularizer',1e-7);
evaluate.setDefaultParameter('settings.logisticRegressionNumIterations',1000);
evaluate.setDefaultParameter('settings.logisticRegressionLearningRate',1e-2);


experiment = Experiments.Experiment.createByNameNew(experimentName, category, ...
     {configuredData, configuredTask, configuredSquaredFeatures, configuredLinearFeatures, configuredPolicy}, evaluationCriterion, 5, ...
    {'127.0.0.1',1});

experiment.addEvaluation(evaluate);
% experiment.startLocal();
experiment.startBatch(64, 16, '00:30');



% data = obj.getData({'avgReturn'}); plot(data(:).trial.avgReturn)
% data = obj.getTrialData({'avgReturn'}); [plotDataStandardReps ] = Plotter.PlotterEvaluations.preparePlotData(data, 'episodes', 'avgReturn', 'settings.numOptions', @(x_) sprintf('NumOptions = %1.3f', x_), 'ClosedFormREPSBeta', false, [], []); Plotter.PlotterEvaluations.plotData(plotDataStandardReps);
