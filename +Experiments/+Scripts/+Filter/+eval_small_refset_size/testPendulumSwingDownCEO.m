close all;

Common.clearClasses();
clear variables;
%clear all;
clc;

%MySQL.mym('closeall');

category = 'evalReferenceSetSizeSmall';
%category = 'test';
experimentName = 'CeokkfPendulumSwingDown';

% set some variables
winRefSizes = {100; 300; 500};
numIterations = 5;
numTrials = 20;

% create a task
configuredTask = Experiments.Tasks.SwingDownTask(false);

configuredAliasAdder = Experiments.Filter.AddDataAliasConfigurator('stateAliasAdder');

configuredNoisePreprocessor = Experiments.Preprocessor.NoisePreprocessorConfigurator('noisePreprocessorConfigurator');
configuredWindowPreprocessor = Experiments.Preprocessor.WindowPreprocessorConfigurator('windowPreprocessorConfigurator');

configuredObservationPointsPreprocessor = Experiments.Preprocessor.ObservationPointsPreprocessorConfigurator('observationPointsPreprocessorConfigurator');

configuredLinearTransformFeature = Experiments.Features.FeatureLinearTransform();
configuredFeatureLearner = Experiments.FeatureLearner.FeatureLearner('stateFeatures');

configuredCeokkf = Experiments.Filter.CEOKernelKalmanFilterConfigurator('ceokkfConfigurator');

evaluationCriterion = Experiments.EvaluationCriterion();
evaluationCriterion.registerEvaluator(Evaluator.FilteredDataEvaluator());

evaluate = Experiments.Evaluation(...
    {'settings.kernelReferenceSet_maxSizeReferenceSet'},winRefSizes,numIterations,numTrials);

evaluate.setDefaultParameter('settings.Noise_std', 1);
evaluate.setDefaultParameter('settings.Noise_mode', 0);
evaluate.setDefaultParameter('settings.dt',1e-1);
evaluate.setDefaultParameter('settings.numSamplesEpisodes',[20 20 20 20 20]);
evaluate.setDefaultParameter('settings.numTimeSteps',30);

evaluate.setDefaultParameter('stateAliasAdderAliasNames', {'theta'});
evaluate.setDefaultParameter('stateAliasAdderAliasTargets', {'states'});
evaluate.setDefaultParameter('stateAliasAdderAliasIndices', {1});

% general settings
evaluate.setDefaultParameter('settings.windowSize', 4);
evaluate.setDefaultParameter('settings.observationIndex', 1);

% observation noise settings
noisePreproName = 'noisePrepro';
evaluate.setDefaultParameter('settings.noisePreprocessor_sigma', 1e-2);
evaluate.setDefaultParameter('settings.noisePreprocessor_inputNames', {'theta'});
% evaluate.setDefaultParameter('settings.noisePreprocessor_outputNames', {'thetaNoisy', 'nextThetaNoisy'});

evaluate.setDefaultParameter('settings.observationPointsPreprocessor_observationIndices',[1:5,20]);


% window settings
windowsPreproName = 'windowsPrepro';
evaluate.setDefaultParameter('settings.windowPreprocessor_inputNames', {'thetaNoisy', 'theta'});
% settings.registerAlias([windowsPreproName '_indexPoint'], 'observationIndex');
evaluate.setDefaultParameter('settings.windowPreprocessor_indexPoint', 1);

% feature generator settings
% featureGeneratorName1 = 'pcaFeatureGenerator1';
% settings.setProperty([featureGeneratorName1 '_featureName'], 'PcaFeatures');
% settings.setProperty([featureGeneratorName1 '_featureVariables'], 'thetaNoisyWindows');
% settings.setProperty([featureGeneratorName1 '_numFeatures'], 4);
% featureGeneratorName2 = 'pcaFeatureGenerator2';
% settings.setProperty([featureGeneratorName2 '_featureName'], 'PcaFeatures');
% settings.setProperty([featureGeneratorName2 '_featureVariables'], 'nextThetaNoisyWindows');
% settings.setProperty([featureGeneratorName2 '_numFeatures'], 4);
evaluate.setDefaultParameter('stateFeaturesName','PcaFeatures');
evaluate.setDefaultParameter('stateFeaturesVariables', 'thetaNoisyWindows');
evaluate.setDefaultParameter('stateNumFeatures', 4);

evaluate.setDefaultParameter('stateFeaturesLearner',@FeatureGenerators.FeatureLearner.PrimaryComponentsAnalysis.createFromTrial);
evaluate.setDefaultParameter('nextStateFeaturesLearner',@FeatureGenerators.FeatureLearner.PrimaryComponentsAnalysis.createFromTrial);


% gkkfLearner Settings
evaluate.setDefaultParameter('settings.filterLearner_outputDataName', 'thetaNoisyWindows');
evaluate.setDefaultParameter('settings.filterLearner_featureName', 'thetaNoisyWindows');
evaluate.setDefaultParameter('settings.filterLearner_observations', {'thetaNoisyWindows', 'obsPoints'});
evaluate.setDefaultParameter('settings.filterLearner_featureSize', 4);% pca_features);
evaluate.setDefaultParameter('settings.filterLearner_sigma', 1e-6);
evaluate.setDefaultParameter('settings.filterLearner_lambda', 1e-6);
evaluate.setDefaultParameter('settings.filterLearner_q', .0001);
evaluate.setDefaultParameter('settings.filterLearner_r', .0003);

evaluate.setDefaultParameter('settings.kernelReferenceSet_kernelMedianBandwidthFactor', 1);

% referenceSet settings
% evaluate.setDefaultParameter('settings.kernelReferenceSet_maxSizeReferenceSet', 500);
evaluate.setDefaultParameter('settings.kernelReferenceSet_inputDataEntry', 'thetaNoisyWindows');
evaluate.setDefaultParameter('settings.kernelReferenceSet_validityDataEntry', 'thetaNoisyWindowsValid');

% optimization settings
evaluate.setDefaultParameter('settings.ceokkfOptimizer_inputDataEntry','thetaWindows');
evaluate.setDefaultParameter('settings.groundtruthName','theta');
evaluate.setDefaultParameter('settings.CMAOptimizerInitialRangeCEOKKF_CMAES_optimization', .05);
evaluate.setDefaultParameter('settings.maxNumOptiIterationsCEOKKF_CMAES_optimization', 250);

evaluate.setDefaultParameter('evaluationGroundtruth','theta');
evaluate.setDefaultParameter('evaluationObservations','thetaNoisyWindows');
evaluate.setDefaultParameter('evaluationValid','thetaNoisyWindowsValid');

experiment = Experiments.Experiment.createByNameNew(experimentName, category, ...
     {configuredTask, configuredAliasAdder, configuredNoisePreprocessor, configuredWindowPreprocessor, configuredObservationPointsPreprocessor, configuredLinearTransformFeature, configuredFeatureLearner, configuredCeokkf}, evaluationCriterion, 5, ...
    {'127.0.0.1',1});

experiment.addEvaluation(evaluate);
experiment.startBatch(16,8);
% experiment.startLocal