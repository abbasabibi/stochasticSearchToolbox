close all;

Common.clearClasses();
clear variables;
%clear all;
clc;

%MySQL.mym('closeall');

category = 'evalImageData';
%category = 'test';
experimentName = 'GkkfRegPendulumSwingDownImages';

% set some variables
redRefSizes = {600; 800; 1000};
numIterations = 2;
numTrials = 4;

% create a task
configuredTask = Experiments.Tasks.SwingDownTask(false);

configuredAliasAdder = Experiments.Filter.AddDataAliasConfigurator('stateAliasAdder');

configuredImageFeature = Experiments.Features.FeaturePicture();

configuredLinearTransformFeature = Experiments.Features.FeatureLinearTransform();
configuredFeatureLearner = Experiments.FeatureLearner.FeatureLearner('stateFeatures');

configuredNoisePreprocessor = Experiments.Preprocessor.NoisePreprocessorConfigurator('noisePreprocessorConfigurator');
configuredWindowPreprocessor = Experiments.Preprocessor.WindowPreprocessorConfigurator('windowPreprocessorConfigurator');
configuredObservationPointsPreprocessor = Experiments.Preprocessor.ObservationPointsPreprocessorConfigurator('observationPointsPreprocessorConfigurator');


configuredGkkf = Experiments.Filter.GeneralizedKernelKalmanFilterConfigurator('gkkfConfigurator');

settings = Common.Settings();
settings.setProperty('numSamplesEvaluation',30);
evaluationCriterion = Experiments.EvaluationCriterion();
evaluationCriterion.registerEvaluator(Evaluator.FilteredDataEvaluator());

evaluate = Experiments.Evaluation(...
    {'settings.reducedKRS_maxSizeReferenceSet'},redRefSizes,numIterations,numTrials);

evaluate.setDefaultParameter('maxSamples',500);

evaluate.setDefaultParameter('settings.Noise_std', 1e-2);
evaluate.setDefaultParameter('settings.Noise_mode', 0);
evaluate.setDefaultParameter('settings.dt',1e-1);
evaluate.setDefaultParameter('settings.numSamplesEpisodes',250);
evaluate.setDefaultParameter('settings.numTimeSteps',30);

evaluate.setDefaultParameter('stateAliasAdderAliasNames', {'theta'});
evaluate.setDefaultParameter('stateAliasAdderAliasTargets', {'states'});
evaluate.setDefaultParameter('stateAliasAdderAliasIndices', {1});

evaluate.setDefaultParameter('settings.noisePreprocessor_sigma', 1e-4);
evaluate.setDefaultParameter('settings.noisePreprocessor_inputNames', {'theta'});

% general settings
evaluate.setDefaultParameter('settings.windowSize', 3);
evaluate.setDefaultParameter('settings.observationIndex', 1);

evaluate.setDefaultParameter('settings.observationPointsPreprocessor_observationIndices',[1:5]);

evaluate.setDefaultParameter('pictureFeatureVariable', 'thetaNoisy');
evaluate.setDefaultParameter('pictureFeatureSize',10);

% feature generator settings
evaluate.setDefaultParameter('stateFeaturesName','PcaFeatures');
evaluate.setDefaultParameter('stateFeaturesVariables', 'thetaNoisyPicture');
evaluate.setDefaultParameter('stateNumFeatures', 20);
evaluate.setDefaultParameter('settings.PcaFeatures_normalizeEigenVectors',false);

% window settings
windowsPreproName = 'windowsPrepro';
evaluate.setDefaultParameter('settings.windowPreprocessor_inputNames', {'thetaNoisyPicturePcaFeatures'});
% settings.registerAlias([windowsPreproName '_indexPoint'], 'observationIndex');
evaluate.setDefaultParameter('settings.windowPreprocessor_indexPoint', 1);
evaluate.setDefaultParameter('settings.windowPreprocessor_windowSize', 3);

evaluate.setDefaultParameter('stateFeaturesLearner',@FeatureGenerators.FeatureLearner.PrimaryComponentsAnalysis.createFromTrial);


% filterLearner Settings
evaluate.setDefaultParameter('settings.filterLearner_outputDataName', {'thetaNoisyPicture' 'thetaNoisyPicturePcaFeatures' 'thetaNoisy'});
evaluate.setDefaultParameter('settings.filterLearner_stateFeatureName', 'thetaNoisyPicturePcaFeaturesWindows');
evaluate.setDefaultParameter('settings.filterLearner_obsFeatureName', 'thetaNoisyPicturePcaFeatures');
evaluate.setDefaultParameter('settings.filterLearner_stateFeatureSize', 60);
evaluate.setDefaultParameter('settings.filterLearner_obsFeatureSize', 20);
evaluate.setDefaultParameter('settings.filterLearner_observations', {'thetaNoisyPicturePcaFeatures','obsPoints'});
evaluate.setDefaultParameter('settings.filterLearner_conditionalOperatorType', 'reg');
evaluate.setDefaultParameter('settings.filterLearner_referenceSetLearnerType', 'random');
evaluate.setDefaultParameter('settings.filterLearner_stateKernelType', 'WindowedExponentialQuadraticKernel');
evaluate.setDefaultParameter('settings.filterLearner_obsKernelType', 'WindowedExponentialQuadraticKernel');

evaluate.setDefaultParameter('settings.stateKernel_numWindows',12);
evaluate.setDefaultParameter('settings.obsKernel_numWindows',4);

% gkkf settings
gkkfName = 'GKKF';
evaluate.setDefaultParameter('settings.GKKF_kappa', 0.1);
% evaluate.setDefaultParameter('settings.GKKF_learnTcov', true);
% GKKF_lambdaT
% GKKF_lambdaO
% GKKF_kappa

% referenceSet settings
evaluate.setDefaultParameter('settings.stateKRS_maxSizeReferenceSet', 10000);
evaluate.setDefaultParameter('settings.obsKRS_maxSizeReferenceSet', 10000);
% evaluate.setDefaultParameter('settings.reducedKRS_maxSizeReferenceSet', 500);
evaluate.setDefaultParameter('settings.stateKRS_inputDataEntry', 'thetaNoisyPicturePcaFeaturesWindows');
evaluate.setDefaultParameter('settings.stateKRS_validityDataEntry', 'thetaNoisyPicturePcaFeaturesWindowsValid');
evaluate.setDefaultParameter('settings.obsKRS_inputDataEntry', 'thetaNoisyPicturePcaFeatures');
evaluate.setDefaultParameter('settings.obsKRS_validityDataEntry', 'thetaNoisyPicturePcaFeaturesWindowsValid');
evaluate.setDefaultParameter('settings.reducedKRS_inputDataEntry', 'thetaNoisyPicturePcaFeaturesWindows');
evaluate.setDefaultParameter('settings.reducedKRS_validityDataEntry', 'thetaNoisyPicturePcaFeaturesWindowsValid');


% optimization settings
evaluate.setDefaultParameter('settings.GKKF_CMAES_optimization_monitoringIndex',121);
evaluate.setDefaultParameter('settings.GKKF_CMAES_optimization_monitoringGroundtruthName','theta');
evaluate.setDefaultParameter('settings.GKKF_CMAES_optimization_groundtruthName','thetaNoisyPicturePcaFeatures');
evaluate.setDefaultParameter('settings.GKKF_CMAES_optimization_validityDataEntry','thetaNoisyPicturePcaFeaturesWindowsValid');
evaluate.setDefaultParameter('settings.GKKF_CMAES_optimization_observationIndex',(1:20)+100);
evaluate.setDefaultParameter('settings.CMAOptimizerInitialRangeGKKF_CMAES_optimization', .1);
evaluate.setDefaultParameter('settings.maxNumOptiIterationsGKKF_CMAES_optimization', 200);

evaluate.setDefaultParameter('evaluationGroundtruth','theta');
evaluate.setDefaultParameter('evaluationObservations','thetaNoisyPicturePcaFeatures');
evaluate.setDefaultParameter('evaluationValid','thetaNoisyPicturePcaFeaturesWindowsValid');
evaluate.setDefaultParameter('evaluationObservationIndex',121);

experiment = Experiments.Experiment.createByNameNew(experimentName, category, ...
     {configuredTask, configuredAliasAdder, configuredNoisePreprocessor, ...
     configuredImageFeature, configuredLinearTransformFeature, configuredFeatureLearner, ...
     configuredWindowPreprocessor, configuredObservationPointsPreprocessor, configuredGkkf}, ...
     evaluationCriterion, 5, ...
    {'127.0.0.1',1});

experiment.addEvaluation(evaluate);
experiment.startBatch(32,4);
% experiment.startLocal
