close all;

Common.clearClasses();
clear variables;
clc;


category = 'evalKernelBayesFiltering';
experimentName = 'fixedKernelSize';

% set some variables
conditionalOperatorTyp = {
                          'std' 100  100  0
                          'std' 150  150  0
                          'std' 300  300  0
                          'std' 450  450  0
                          'std' 600  600  0
                          'reg' 100  100  100
                          'reg' 150  150  100
                          'reg' 300  300  100
                          'reg' 450  450  100
                          'reg' 600  600  100
                          };
% conditionalOperatorTyp = {'std' 5   5   0
%                           'std' 10  10  0
%                           'std' 20  20  0
%                           'std' 50  50  0
%                           'std' 100 100 0
%                           'reg' 100 100 5
%                           'reg' 100 100 10
%                           'reg' 100 100 20
%                           'reg' 100 100 50
%                           'reg' 100 100 100
%                           };
% conditionalOperatorTyp = {'reg' 10000 10000};
numIterations = 1;
numTrials = 20;

% create a task
configuredTask = Experiments.Tasks.SwingTask(false);
% configuredTask = Experiments.Tasks.RandomEventSwingTask(false);

configuredAliasAdder = Experiments.Filter.AddDataAliasConfigurator('stateAliasAdder');

configuredRandomEventPreprocessor = Experiments.Preprocessor.RandomEventPreprocessorConfigurator('randEventPreproConf');
configuredNoisePreprocessor = Experiments.Preprocessor.NoisePreprocessorConfigurator('noisePreproConf');
configuredWindowPreprocessor = Experiments.Preprocessor.WindowPreprocessorConfigurator('windowPreproConf');

configuredObservationPointsPreprocessor = Experiments.Preprocessor.ObservationPointsPreprocessorConfigurator('obsPointsPreproConf');

configuredGkkf = Experiments.Filter.KernelBayesFilterConfiguratorNoOpt('kbfConf');

evaluationCriterion = Experiments.EvaluationCriterion();
filteredDataEvaluator = Evaluator.FilteredDataEvaluator();
filteredDataEvaluator.numSamplesEvaluation = 30;
evaluationCriterion.registerEvaluator(filteredDataEvaluator);
filterTimeEvaluator = Evaluator.FilterTimeEvaluator();
filterTimeEvaluator.numSamplesEvaluation = 30;
evaluationCriterion.registerEvaluator(filterTimeEvaluator);

evaluate = Experiments.Evaluation(...
    {'settings.filterLearner_conditionalOperatorType', 'settings.stateKRS_maxSizeReferenceSet', 'settings.obsKRS_maxSizeReferenceSet', 'settings.reducedKRS_maxSizeReferenceSet'},conditionalOperatorTyp,numIterations,numTrials);


evaluate.setDefaultParameter('settings.Noise_std', 1);
evaluate.setDefaultParameter('settings.Noise_mode', 0);
evaluate.setDefaultParameter('settings.dt',1e-1);
% evaluate.setDefaultParameter('settings.numSamplesEpisodes',[5 5 10 30 50]);
evaluate.setDefaultParameter('settings.numSamplesEpisodes',[200]);
evaluate.setDefaultParameter('settings.numTimeSteps',30);

evaluate.setDefaultParameter('stateAliasAdderAliasNames', {'theta'});
evaluate.setDefaultParameter('stateAliasAdderAliasTargets', {'states'});
evaluate.setDefaultParameter('stateAliasAdderAliasIndices', {1});

% general settings
% evaluate.setDefaultParameter('settings.windowSize', 4);
% evaluate.setDefaultParameter('settings.observationIndex', 1);

evaluate.setDefaultParameter('settings.randomEventPreprocessor_inputNames',{'theta'});
evaluate.setDefaultParameter('settings.randomEventPreprocessor_eventProbability',.1);

% observation noise settings
noisePreproName = 'noisePrepro';
evaluate.setDefaultParameter('settings.noisePreprocessor_sigma', 1e-2);
evaluate.setDefaultParameter('settings.noisePreprocessor_inputNames', {'thetaNoisy'});
% evaluate.setDefaultParameter('settings.noisePreprocessor_outputNames', {'thetaNoisy', 'nextThetaNoisy'});

evaluate.setDefaultParameter('settings.observationPointsPreprocessor_observationIndices',[1:30]);


% window settings
% windowsPreproName = 'windowsPrepro';
evaluate.setDefaultParameter('settings.windowPreprocessor_inputNames', {'thetaNoisyNoisy', 'theta'});
evaluate.setDefaultParameter('settings.windowPreprocessor_indexPoint', 1);
evaluate.setDefaultParameter('settings.windowPreprocessor_windowSize', 1);


% gkkfLearner Settings
evaluate.setDefaultParameter('settings.filterLearner_outputDataName', 'thetaNoisyNoisy');
evaluate.setDefaultParameter('settings.filterLearner_stateFeatureName', 'states');
evaluate.setDefaultParameter('settings.filterLearner_obsFeatureName', 'thetaNoisyNoisy');
evaluate.setDefaultParameter('settings.filterLearner_stateFeatureSize', 2);
evaluate.setDefaultParameter('settings.filterLearner_obsFeatureSize', 1);
evaluate.setDefaultParameter('settings.filterLearner_observations', {'thetaNoisyNoisy','obsPoints'});
% evaluate.setDefaultParameter('settings.filterLearner_conditionalOperatorType','std');
evaluate.setDefaultParameter('settings.filterLearner_referenceSetLearnerType','random');

% gkkf settings
gkkfName = 'GKKF';
evaluate.setDefaultParameter('settings.GKKF_lambdaT',exp(-1));
evaluate.setDefaultParameter('settings.GKKF_lambdaO',exp(-6));
evaluate.setDefaultParameter('settings.GKKF_kappa',exp(-6));

% referenceSet settings
% evaluate.setDefaultParameter('settings.stateKRS_maxSizeReferenceSet', 10000);
% evaluate.setDefaultParameter('settings.obsKRS_maxSizeReferenceSet', 10000);
% evaluate.setDefaultParameter('settings.reducedKRS_maxSizeReferenceSet', 100);
evaluate.setDefaultParameter('settings.stateKRS_inputDataEntry', 'states');
evaluate.setDefaultParameter('settings.stateKRS_validityDataEntry', 'thetaNoisyNoisyWindowsValid');
evaluate.setDefaultParameter('settings.obsKRS_inputDataEntry', 'thetaNoisyNoisy');
evaluate.setDefaultParameter('settings.obsKRS_validityDataEntry', 'thetaNoisyNoisyWindowsValid');
evaluate.setDefaultParameter('settings.reducedKRS_inputDataEntry', 'states');
evaluate.setDefaultParameter('settings.reducedKRS_validityDataEntry', 'thetaNoisyNoisyWindowsValid');

evaluate.setDefaultParameter('evaluationGroundtruth','theta');
evaluate.setDefaultParameter('evaluationObservations','thetaNoisyNoisy');
evaluate.setDefaultParameter('evaluationValid','');


experiment = Experiments.Experiment.createByNameNew(experimentName, category, ...
     {configuredTask, configuredAliasAdder, configuredRandomEventPreprocessor, configuredNoisePreprocessor, configuredWindowPreprocessor, configuredObservationPointsPreprocessor, configuredGkkf}, evaluationCriterion, 5, ...
    {'127.0.0.1',1});

experiment.addEvaluation(evaluate);
experiment.startBatch(20,1);
% experiment.startLocal