close all;

Common.clearClasses();
clear variables;
%clear all;
clc;

%MySQL.mym('closeall');

category = 'evalKernelBayesFiltering';
%category = 'test';
experimentName = 'images';

% set some variables
redRefSizes = {'std' 100  100  0
               'std' 200  200  0
               'std' 300  300  0
               'std' 400  400  0
               'std' 500  500  0
               'reg' 100  100  100
               'reg' 200  200  100
               'reg' 300  300  100
               'reg' 400  400  100
               'reg' 500  500  100};
numIterations = 1;
numTrials = 20;

% create a task
configuredTask = Experiments.Tasks.SwingTask(false);

configuredAliasAdder = Experiments.Filter.AddDataAliasConfigurator('stateAliasAdder');

configuredRandomEventPreprocessor = Experiments.Preprocessor.RandomEventPreprocessorConfigurator('randEvPreproConf');

configuredImageFeature = Experiments.Features.FeaturePicture();

configuredLinearTransformFeature = Experiments.Features.FeatureLinearTransform();
configuredFeatureLearner = Experiments.FeatureLearner.FeatureLearner('stateFeatures');

configuredNoisePreprocessor = Experiments.Preprocessor.NoisePreprocessorConfigurator('noisePreproConf');
configuredWindowPreprocessor = Experiments.Preprocessor.WindowPreprocessorConfigurator('winPreproConf');
configuredObservationPointsPreprocessor = Experiments.Preprocessor.ObservationPointsPreprocessorConfigurator('obsPointsPreproConf');


configuredGkkf = Experiments.Filter.KernelBayesFilterConfiguratorNoOpt('gkkfConf');

settings = Common.Settings();

filteredImageDataEvaluator = Evaluator.FilteredImageDataEvaluator();
filteredImageDataEvaluator.observationIndex = 1:100;
filteredImageDataEvaluator.numSamplesEvaluation = 30;
filteredImageDataEvaluator.groundtruthName = 'theta';
filteredImageDataEvaluator.extractionFunction = @(d) FeatureGenerators.PictureFeatureExtractors.extractTheta(reshape(d,10,10,[]),false);

filterTimeEvaluator = Evaluator.FilterTimeEvaluator();
filterTimeEvaluator.numSamplesEvaluation = 30;

evaluationCriterion = Experiments.EvaluationCriterion();
evaluationCriterion.registerEvaluator(filteredImageDataEvaluator);
evaluationCriterion.registerEvaluator(filterTimeEvaluator);

evaluate = Experiments.Evaluation(...
    {'settings.filterLearner_conditionalOperatorType' 'settings.stateKRS_maxSizeReferenceSet' 'settings.obsKRS_maxSizeReferenceSet' 'settings.reducedKRS_maxSizeReferenceSet'},redRefSizes,numIterations,numTrials);

evaluate.setDefaultParameter('maxSamples',500);

evaluate.setDefaultParameter('settings.Noise_std', 2);
evaluate.setDefaultParameter('settings.Noise_mode', 0);
evaluate.setDefaultParameter('settings.dt',1e-1);
evaluate.setDefaultParameter('settings.numSamplesEpisodes',[100]);
evaluate.setDefaultParameter('settings.numTimeSteps',30);

evaluate.setDefaultParameter('stateAliasAdderAliasNames', {'theta'});
evaluate.setDefaultParameter('stateAliasAdderAliasTargets', {'states'});
evaluate.setDefaultParameter('stateAliasAdderAliasIndices', {1});

evaluate.setDefaultParameter('settings.randomEventPreprocessor_inputNames',{'theta'});

evaluate.setDefaultParameter('pictureFeatureVariable', 'thetaNoisy');
evaluate.setDefaultParameter('pictureFeatureSize',10);

evaluate.setDefaultParameter('settings.noisePreprocessor_sigma', 1e-8);
evaluate.setDefaultParameter('settings.noisePreprocessor_positiveOnly', true);
evaluate.setDefaultParameter('settings.noisePreprocessor_inputNames', {'thetaNoisyPicture'});

% general settings
% evaluate.setDefaultParameter('settings.windowSize', 3);
% evaluate.setDefaultParameter('settings.observationIndex', 1:100);

evaluate.setDefaultParameter('settings.observationPointsPreprocessor_observationIndices',[1:30]);

% feature generator settings
evaluate.setDefaultParameter('stateFeaturesName','PcaFeatures');
evaluate.setDefaultParameter('stateFeaturesVariables', 'thetaNoisyPictureNoisy');
evaluate.setDefaultParameter('stateNumFeatures', 10);
evaluate.setDefaultParameter('settings.PcaFeatures_normalizeEigenVectors',true);

% window settings
windowsPreproName = 'windowsPrepro';
evaluate.setDefaultParameter('settings.windowPreprocessor_inputNames', {'thetaNoisyPictureNoisyPcaFeatures'});
% settings.registerAlias([windowsPreproName '_indexPoint'], 'observationIndex');
evaluate.setDefaultParameter('settings.windowPreprocessor_indexPoint', 1);
evaluate.setDefaultParameter('settings.windowPreprocessor_windowSize', 1);

evaluate.setDefaultParameter('stateFeaturesLearner',@FeatureGenerators.FeatureLearner.PrimaryComponentsAnalysis.createFromTrial);


% filterLearner Settings
evaluate.setDefaultParameter('settings.filterLearner_outputDataName', {'thetaNoisyPictureNoisy' 'thetaNoisyPictureNoisyPcaFeatures'});
evaluate.setDefaultParameter('settings.filterLearner_stateFeatureName', 'states');
evaluate.setDefaultParameter('settings.filterLearner_obsFeatureName', 'thetaNoisyPictureNoisyPcaFeatures');
evaluate.setDefaultParameter('settings.filterLearner_stateFeatureSize', 2);
evaluate.setDefaultParameter('settings.filterLearner_obsFeatureSize', 10);
evaluate.setDefaultParameter('settings.filterLearner_observations', {'thetaNoisyPictureNoisyPcaFeatures','obsPoints'});
% evaluate.setDefaultParameter('settings.filterLearner_conditionalOperatorType', 'reg');
evaluate.setDefaultParameter('settings.filterLearner_referenceSetLearnerType', 'random');
% evaluate.setDefaultParameter('settings.filterLearner_stateKernelType', 'WindowedExponentialQuadraticKernel');
evaluate.setDefaultParameter('settings.filterLearner_obsKernelType', 'WindowedExponentialQuadraticKernel');

% evaluate.setDefaultParameter('settings.stateKernel_numWindows',15);
evaluate.setDefaultParameter('settings.obsKernel_numWindows',5);

% gkkf settings
gkkfName = 'GKKF';
evaluate.setDefaultParameter('settings.GKKF_kappa', exp(0.8));
evaluate.setDefaultParameter('settings.GKKF_lambdaT', exp(-10));
evaluate.setDefaultParameter('settings.GKKF_lambdaO', exp(-10));
evaluate.setDefaultParameter('settings.GKKF_normalization', true);

% referenceSet settings
% evaluate.setDefaultParameter('settings.stateKRS_maxSizeReferenceSet', 5000);
% evaluate.setDefaultParameter('settings.obsKRS_maxSizeReferenceSet', 5000);
% evaluate.setDefaultParameter('settings.reducedKRS_maxSizeReferenceSet', 500);
evaluate.setDefaultParameter('settings.stateKRS_inputDataEntry', 'states');
evaluate.setDefaultParameter('settings.stateKRS_validityDataEntry', 'thetaNoisyPictureNoisyPcaFeaturesWindowsValid');
evaluate.setDefaultParameter('settings.obsKRS_inputDataEntry', 'thetaNoisyPictureNoisyPcaFeatures');
evaluate.setDefaultParameter('settings.obsKRS_validityDataEntry', 'thetaNoisyPictureNoisyPcaFeaturesWindowsValid');
evaluate.setDefaultParameter('settings.reducedKRS_inputDataEntry', 'states');
evaluate.setDefaultParameter('settings.reducedKRS_validityDataEntry', 'thetaNoisyPictureNoisyPcaFeaturesWindowsValid');

% evaluate.setDefaultParameter('settings.stateKRS_kernelMedianBandwidthFactor',5);
% evaluate.setDefaultParameter('settings.obsKRS_kernelMedianBandwidthFactor',5);


evaluate.setDefaultParameter('evaluationGroundtruth','theta');
evaluate.setDefaultParameter('evaluationObservations','thetaNoisyPictureNoisyPcaFeatures');
evaluate.setDefaultParameter('evaluationValid','');
evaluate.setDefaultParameter('evaluationObservationIndex',1:100);

experiment = Experiments.Experiment.createByNameNew(experimentName, category, ...
     {configuredTask, configuredAliasAdder, configuredRandomEventPreprocessor, configuredImageFeature, ...
     configuredNoisePreprocessor, configuredLinearTransformFeature, ...
     configuredFeatureLearner, configuredWindowPreprocessor, ...
     configuredObservationPointsPreprocessor, configuredGkkf}, evaluationCriterion, 5, ...
    {'127.0.0.1',1});

experiment.addEvaluation(evaluate);
experiment.startBatch(10,1);
% experiment.startLocal
