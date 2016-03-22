close all;
[~, trialIdx] = Common.clearClasses();
clc;
addpath(genpath('Helper/'));


%MySQL.mym('closeall');

category = 'testEM';


numOptions          = 20;
numSamples          = 20;
numMaxSamples       = 3*numSamples;
maxReferenceSetSize = 300;
numIterations       = 100;
maxIterationsEM     = 1;  % HERE
toleranceEM         = -inf;

epsilonAction       = 1;
epsilonOption       = 1;

priorTerminate      = 0.5;

dt                  = 0.05;

numTimeSteps        = 50;
% restartProb         = 1/numTimeSteps;
minRangeContexts    = [-pi -10];
maxRangeContexts    = [pi 10];
maxRangeActions     = 100;

doKMeansInit        = true;
keepOptionsShape    = true;
learnInputShape     = true;
learnOutputShape    = false;
    

numTrialsCluster    = 5;





%%

configuredTask              = Experiments.Tasks.PendulumOptionTask('PendulumPeriodic', false, true);

configuredKernelFeatures    = Experiments.Features.FeatureRBFKernelStatesPeriodicNew('states', 'Kernel');
configuredBandwithLearner   = Experiments.FeatureLearner.MedianBandwidthSelectorConfiguratorNew(configuredKernelFeatures.kernelName);

configuredSquaredFeatures   = Experiments.Features.FeatureSquaredConfigurator('states', 'Square', true)';

configuredPolicy            = Experiments.ActionPolicies.ExplorationMMConfigurator('MixtureModel');

configuredLearner           = Experiments.Learner.StepBasedActionHiREPS('HiREPS', configuredKernelFeatures.featureOutputName, true);

evaluationCriterion         = Experiments.EvaluationCriterion();
evaluationCriterion.registerEvaluator(Evaluator.ReturnEvaluatorNewSamples());



% evaluationCriterion.registerEvaluator(Evaluator.ReturnEvaluatorDecisionStages(10, 2));


configuredPlotter           = Experiments.Evaluators.PendulumPlotterExplorationConfigurator(evaluationCriterion, configuredKernelFeatures, configuredSquaredFeatures);

% TEST
numTrials           = 1;
 
evaluate = Experiments.Evaluation(...
    {'settings.numSamplesEpisodes'},{20},numIterations,numTrials); %test
experimentName = 'test';



%%

if(trialIdx > 0)    
    numTrials           = numTrialsCluster;
    switch trialIdx
        case {1}
            evaluate = Experiments.Evaluation(...
                {'settings.numOptions'},{1, 2, 5, 10}, numIterations,numTrials);  %numOptions
            experimentName = 'NumOptions';
            
            
        case {2}
            evaluate = Experiments.Evaluation(...
                {'settings.maxSamples'},{20, 40, 80, 120},numIterations,numTrials); %MaxSamples
            experimentName = 'MaxSamples';
            
        case {3}
            evaluate = Experiments.Evaluation(...
                {'settings.epsilonOption'},{0.9, 0.95, 1, 1.05},numIterations,numTrials); %EpsilonOption
            experimentName = 'EpsilonOption';
            
        case {4}
            evaluate = Experiments.Evaluation(...
                {'settings.epsilonAction'},{0.9, 1, 1.1, 1.2},numIterations,numTrials); %EpsilonAction
            experimentName = 'EpsilonAction';
        case {5}
            evaluate = Experiments.Evaluation(...
                {'settings.priorTerminate'},{0.3, 0.4, 0.5, 0.6, 1},numIterations,numTrials); %priorTerminate
            experimentName = 'priorTerminate';
            
            
        case {6}
            evaluate = Experiments.Evaluation(...
                {'settings.maxSizeReferenceSet'},{100, 200, 300, 500, 800}, numIterations,numTrials);  %maxReferenceSet
            experimentName = 'MaxReference';
            
            % evaluate = Experiments.Evaluation(...
            %     {'settings.doKMeansInit', 'settings.keepOptionsShape'},{false, false;
            %     true, false; true, true},numIterations,numTrials);                    %kmeans
            % experimentName = 'kMeansAndOptionsShape';
            
            
    end
end

%%

evaluate.setDefaultParameter('sampler', @Sampler.EpisodeWithStepsSamplerOptions);
evaluate.setDefaultParameter('settings.respNameEM', 'responsibilities');

evaluate.setDefaultParameter('settings.numTimeSteps', numTimeSteps);
evaluate.setDefaultParameter('settings.periodicRange', [-pi, pi]);

evaluate.setDefaultParameter('settings.InitialStateDistributionMinRange', minRangeContexts);
evaluate.setDefaultParameter('settings.InitialStateDistributionMaxRange', maxRangeContexts);
evaluate.setDefaultParameter('settings.pendulumStateMinRange', minRangeContexts);
evaluate.setDefaultParameter('settings.pendulumStateMaxRange', maxRangeContexts);
evaluate.setDefaultParameter('settings.pendulumActionMaxRange', maxRangeActions);


evaluate.setDefaultParameter('settings.InitialContextDistributionWidth', 1);
evaluate.setDefaultParameter('settings.InitialStateDistributionType', 'Uniform');
evaluate.setDefaultParameter('settings.maxTorque', 35);


evaluate.setDefaultParameter('settings.numOptions',numOptions);
evaluate.setDefaultParameter('settings.epsilonAction', epsilonAction);
evaluate.setDefaultParameter('settings.epsilonOption',epsilonOption);
evaluate.setDefaultParameter('settings.priorTerminate',priorTerminate);

% evaluate.setDefaultParameter('settings.initSigmaMuActions',0.5);
% evaluate.setDefaultParameter('settings.initSigmaActions',0.4);

evaluate.setDefaultParameter('settings.numIterationsEM',maxIterationsEM);
evaluate.setDefaultParameter('settings.logLikelihoodThresholdEM',toleranceEM);
evaluate.setDefaultParameter('settings.softMaxRegressionTerminationFactor',1e-9);
evaluate.setDefaultParameter('settings.softMaxRegressionToleranceF', 1e-15);

evaluate.setDefaultParameter('settings.numSamplesEpisodes', numSamples);
evaluate.setDefaultParameter('settings.numInitialSamplesEpisodes', numMaxSamples);
evaluate.setDefaultParameter('settings.maxSamples', numMaxSamples);
evaluate.setDefaultParameter('settings.kernelMedianBandwidthFactor', 0.5);

evaluate.setDefaultParameter('settings.debugPlottingMM', true);

evaluate.setDefaultParameter('settings.regularizationRegression', 1e-15);
evaluate.setDefaultParameter('settings.logisticRegressionRegularizer', 1e-20);

evaluate.setDefaultParameter('settings.dt', dt);
% evaluate.setDefaultParameter('settings.resetProbTimeSteps', restartProb);
evaluate.setDefaultParameter('settings.useKMeans',false); %Only for the EM, KMeans is already done before
evaluate.setDefaultParameter('settings.reinitializeEM',true);





evaluate.setDefaultParameter('settings.maxSizeReferenceSet', maxReferenceSetSize);

evaluate.setDefaultParameter('actionGatingInputVariables', configuredSquaredFeatures.featureOutputName);
% evaluate.setDefaultParameter('actionGatingInputVariables', configuredKernelFeatures.featureOutputName);
evaluate.setDefaultParameter('terminationInputVariables', configuredSquaredFeatures.featureOutputName);
evaluate.setDefaultParameter('policyInputVariables', 'states');% 'contextsForFeatures', configuredSquaredFeatures.featureOutputName
evaluate.setDefaultParameter('settings.kernelMedianBandwidthFactor', 0.5);


% evaluate.setDefaultParameter('settings.resetProbDecisionSteps', restartProb);

evaluate.setDefaultParameter('settings.doKMeansInit', doKMeansInit);
evaluate.setDefaultParameter('settings.keepOptionsShape', keepOptionsShape);
evaluate.setDefaultParameter('settings.learnInputShapeKMeans', learnInputShape);
evaluate.setDefaultParameter('settings.learnOutputShapeKMeans', learnOutputShape);
evaluate.setDefaultParameter('settings.numInitStatesKMeans', 1e3);


experiment = Experiments.Experiment.createByNameNew(experimentName, category, ...
     {configuredTask, configuredKernelFeatures, configuredBandwithLearner, configuredSquaredFeatures, configuredPolicy, configuredLearner, configuredPlotter}, evaluationCriterion, 5, ...
    {'127.0.0.1',1});

experiment.addEvaluation(evaluate);
% experiment.startLocal();
experiment.startBatch(64,16,'00:30');



% data = obj.getData({'avgReturn'}); plot(data(:).trial.avgReturn)
% data = obj.getTrialData({'avgReturn'}); [plotDataStandardReps ] = Plotter.PlotterEvaluations.preparePlotData(data, 'episodes', 'avgReturn', 'settings.numOptions', @(x_) sprintf('NumOptions = %1.3f', x_), 'ClosedFormREPSBeta', false, [], []); Plotter.PlotterEvaluations.plotData(plotDataStandardReps);
