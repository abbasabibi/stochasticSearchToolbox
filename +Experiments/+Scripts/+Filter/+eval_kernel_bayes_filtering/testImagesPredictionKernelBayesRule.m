close all;

Common.clearClasses();
clear variables;
%clear all;
clc;

%MySQL.mym('closeall');

category = 'evalKernelBayesFiltering';
%category = 'test';
experimentName = 'imagePrediction';

% set some variables
redRefSizes = {'std' 100 100 0
               'std' 200 200 0
               'std' 300 300 0
               'std' 400 400 0
               'std' 500 500 0
               'reg' 500 500 100
               'reg' 500 500 200
               'reg' 500 500 300
               'reg' 500 500 400
               'reg' 500 500 500};
numIterations = 1;
numTrials = 50;

% create a task
configuredTask = Experiments.Tasks.SwingTask(false);

configuredAliasAdder = Experiments.Filter.AddDataAliasConfigurator('stateAliasAdder');

configuredImageFeature = Experiments.Features.FeaturePicture();

configuredLinearTransformFeature = Experiments.Features.FeatureLinearTransform();
configuredFeatureLearner = Experiments.FeatureLearner.FeatureLearner('stateFeatures');

configuredNoisePreprocessor = Experiments.Preprocessor.NoisePreprocessorConfigurator('noisePreproConfig');
configuredWindowPreprocessor = Experiments.Preprocessor.WindowPreprocessorConfigurator('winPreproConfig');
configuredObservationPointsPreprocessor = Experiments.Preprocessor.ObservationPointsPreprocessorConfigurator('obsPointsPreproConfig');


configuredGkkf = Experiments.Filter.KernelBayesFilterConfiguratorNoOpt('gkkfConfigurator');

settings = Common.Settings();
% settings.setProperty('numSamplesEvaluation',30);
% settings.setProperty('observationIndex',1:100);
% filteredDataEvaluator = Evaluator.FilteredDataEvaluator();
filteredImageDataEvaluator = Evaluator.FilteredImageDataEvaluator();
filteredImageDataEvaluator.observationIndex = 1:100;
filteredImageDataEvaluator.numSamplesEvaluation = 30;
filteredImageDataEvaluator.groundtruthName = 'theta';
filteredImageDataEvaluator.extractionFunction = @(d) FeatureGenerators.PictureFeatureExtractors.extractTheta(reshape(d,10,10,[]),false);
evaluationCriterion = Experiments.EvaluationCriterion();
% evaluationCriterion.registerEvaluator(filteredDataEvaluator);
evaluationCriterion.registerEvaluator(filteredImageDataEvaluator);

evaluate = Experiments.Evaluation(...
    {'settings.filterLearner_conditionalOperatorType' 'settings.stateKRS_maxSizeReferenceSet' 'settings.obsKRS_maxSizeReferenceSet' 'settings.reducedKRS_maxSizeReferenceSet'},redRefSizes,numIterations,numTrials);

evaluate.setDefaultParameter('maxSamples',500);

evaluate.setDefaultParameter('settings.Noise_std', 1e-2);
evaluate.setDefaultParameter('settings.Noise_mode', 0);
evaluate.setDefaultParameter('settings.dt',1e-1);
evaluate.setDefaultParameter('settings.numSamplesEpisodes',[50]);
evaluate.setDefaultParameter('settings.numTimeSteps',30);

evaluate.setDefaultParameter('stateAliasAdderAliasNames', {'theta'});
evaluate.setDefaultParameter('stateAliasAdderAliasTargets', {'states'});
evaluate.setDefaultParameter('stateAliasAdderAliasIndices', {1});

evaluate.setDefaultParameter('pictureFeatureVariable', 'theta');
evaluate.setDefaultParameter('pictureFeatureSize',10);

evaluate.setDefaultParameter('settings.noisePreprocessor_sigma', 1e-4);
evaluate.setDefaultParameter('settings.noisePreprocessor_positiveOnly', true);
evaluate.setDefaultParameter('settings.noisePreprocessor_inputNames', {'thetaPicture'});

% general settings
% evaluate.setDefaultParameter('settings.windowSize', 3);
% evaluate.setDefaultParameter('settings.observationIndex', 1:100);

evaluate.setDefaultParameter('settings.observationPointsPreprocessor_observationIndices',[1:5]);

% feature generator settings
evaluate.setDefaultParameter('stateFeaturesName','PcaFeatures');
evaluate.setDefaultParameter('stateFeaturesVariables', 'thetaPictureNoisy');
evaluate.setDefaultParameter('stateNumFeatures', 10);
evaluate.setDefaultParameter('settings.PcaFeatures_normalizeEigenVectors',true);

% window settings
windowsPreproName = 'windowsPrepro';
evaluate.setDefaultParameter('settings.windowPreprocessor_inputNames', {'thetaPictureNoisyPcaFeatures'});
% settings.registerAlias([windowsPreproName '_indexPoint'], 'observationIndex');
evaluate.setDefaultParameter('settings.windowPreprocessor_indexPoint', 3);
evaluate.setDefaultParameter('settings.windowPreprocessor_windowSize', 3);

evaluate.setDefaultParameter('stateFeaturesLearner',@FeatureGenerators.FeatureLearner.PrimaryComponentsAnalysis.createFromTrial);


% filterLearner Settings
evaluate.setDefaultParameter('settings.filterLearner_outputDataName', {'thetaPictureNoisy' 'thetaPictureNoisyPcaFeatures'});
evaluate.setDefaultParameter('settings.filterLearner_stateFeatureName', 'thetaPictureNoisyPcaFeaturesWindows');
evaluate.setDefaultParameter('settings.filterLearner_obsFeatureName', 'thetaPictureNoisyPcaFeatures');
evaluate.setDefaultParameter('settings.filterLearner_stateFeatureSize', 30);
evaluate.setDefaultParameter('settings.filterLearner_obsFeatureSize', 10);
evaluate.setDefaultParameter('settings.filterLearner_observations', {'thetaPictureNoisyPcaFeatures','obsPoints'});
% evaluate.setDefaultParameter('settings.filterLearner_conditionalOperatorType', 'reg');
evaluate.setDefaultParameter('settings.filterLearner_referenceSetLearnerType', 'random');
evaluate.setDefaultParameter('settings.filterLearner_stateKernelType', 'WindowedExponentialQuadraticKernel');
evaluate.setDefaultParameter('settings.filterLearner_obsKernelType', 'WindowedExponentialQuadraticKernel');

evaluate.setDefaultParameter('settings.stateKernel_numWindows',15);
evaluate.setDefaultParameter('settings.obsKernel_numWindows',5);

% gkkf settings
gkkfName = 'GKKF';
evaluate.setDefaultParameter('settings.GKKF_kappa', exp(-9));
evaluate.setDefaultParameter('settings.GKKF_lambdaT', exp(-5));
evaluate.setDefaultParameter('settings.GKKF_lambdaO', exp(-8));

% referenceSet settings
% evaluate.setDefaultParameter('settings.stateKRS_maxSizeReferenceSet', 5000);
% evaluate.setDefaultParameter('settings.obsKRS_maxSizeReferenceSet', 5000);
% evaluate.setDefaultParameter('settings.reducedKRS_maxSizeReferenceSet', 500);
evaluate.setDefaultParameter('settings.stateKRS_inputDataEntry', 'thetaPictureNoisyPcaFeaturesWindows');
evaluate.setDefaultParameter('settings.stateKRS_validityDataEntry', 'thetaPictureNoisyPcaFeaturesWindowsValid');
evaluate.setDefaultParameter('settings.obsKRS_inputDataEntry', 'thetaPictureNoisyPcaFeatures');
evaluate.setDefaultParameter('settings.obsKRS_validityDataEntry', 'thetaPictureNoisyPcaFeaturesWindowsValid');
evaluate.setDefaultParameter('settings.reducedKRS_inputDataEntry', 'thetaPictureNoisyPcaFeaturesWindows');
evaluate.setDefaultParameter('settings.reducedKRS_validityDataEntry', 'thetaPictureNoisyPcaFeaturesWindowsValid');

evaluate.setDefaultParameter('settings.stateKRS_kernelMedianBandwidthFactor',5);
evaluate.setDefaultParameter('settings.obsKRS_kernelMedianBandwidthFactor',5);


evaluate.setDefaultParameter('evaluationGroundtruth','theta');
evaluate.setDefaultParameter('evaluationObservations','thetaPictureNoisyPcaFeatures');
evaluate.setDefaultParameter('evaluationValid','');
evaluate.setDefaultParameter('evaluationObservationIndex',1:100);

experiment = Experiments.Experiment.createByNameNew(experimentName, category, ...
     {configuredTask, configuredAliasAdder, configuredImageFeature, ...
     configuredNoisePreprocessor, configuredLinearTransformFeature, ...
     configuredFeatureLearner, configuredWindowPreprocessor, ...
     configuredObservationPointsPreprocessor, configuredGkkf}, evaluationCriterion, 5, ...
    {'127.0.0.1',1});

experiment.addEvaluation(evaluate);
experiment.startBatch(10,1);
% experiment.startLocal
