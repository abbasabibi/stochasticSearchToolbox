close all;

Common.clearClasses();
clear variables;
%clear all;
clc;

%MySQL.mym('closeall');

category = 'evalImageData';
%category = 'test';
experimentName = 'SpectralPendulumSwingDownImages';

% set some variables
window_size = {
    1 {1:20, 21:40, 41:60}  3 20 4
    2 {1:40, 21:60, 41:80}  4 40 8
    3 {1:60, 21:80, 41:100} 5 60 12
    };
numIterations = 2;
numTrials = 4;

% create a task
configuredTask = Experiments.Tasks.SwingDownTask(false);

configuredStateAliasAdder = Experiments.Filter.AddDataAliasConfigurator('stateAliasAdder');
configuredWindowAliasAdder = Experiments.Filter.AddDataAliasConfigurator('windowAliasAdder');

configuredImageFeature = Experiments.Features.FeaturePicture();

configuredLinearTransformFeature = Experiments.Features.FeatureLinearTransform();
configuredFeatureLearner = Experiments.FeatureLearner.FeatureLearner('stateFeatures');

configuredNoisePreprocessor = Experiments.Preprocessor.NoisePreprocessorConfigurator('noisePreprocessorConfigurator');
configuredWindowPreprocessor = Experiments.Preprocessor.WindowPreprocessorConfigurator('windowPreprocessorConfigurator');
configuredObservationPointsPreprocessor = Experiments.Preprocessor.ObservationPointsPreprocessorConfigurator('observationPointsPreprocessorConfigurator');


configuredSpectral = Experiments.Filter.SpectralFilterConfigurator('spectralConfigurator');

settings = Common.Settings();
settings.setProperty('numSamplesEvaluation',30);
evaluationCriterion = Experiments.EvaluationCriterion();
evaluationCriterion.registerEvaluator(Evaluator.FilteredDataEvaluator());

evaluate = Experiments.Evaluation(...
    {'settings.windowSize', 'windowAliasAdderAliasIndices', 'settings.windowPreprocessor_windowSize', 'windowSize', 'settings.kernel_numWindows'},window_size,numIterations,numTrials);

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

evaluate.setDefaultParameter('windowAliasAdderAliasNames', {'x1', 'x2', 'x3'});
evaluate.setDefaultParameter('windowAliasAdderAliasTargets', {'thetaNoisyPicturePcaFeaturesWindows','thetaNoisyPicturePcaFeaturesWindows','thetaNoisyPicturePcaFeaturesWindows'});
% evaluate.setDefaultParameter('windowAliasAdderAliasIndices', {1:20, 21:40, 41:60});

% general settings
% evaluate.setDefaultParameter('settings.windowSize', 1);
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
% evaluate.setDefaultParameter('settings.windowPreprocessor_windowSize', 3);

evaluate.setDefaultParameter('stateFeaturesLearner',@FeatureGenerators.FeatureLearner.PrimaryComponentsAnalysis.createFromTrial);


evaluate.setDefaultParameter('settings.spectralLearner_observations',{'x1','obsPoints'});
evaluate.setDefaultParameter('settings.spectralLearner_outputDataName', 'thetaNoisy');

evaluate.setDefaultParameter('kernelType','WindowedExponentialQuadraticKernel');
% evaluate.setDefaultParameter('windowSize',20);
evaluate.setDefaultParameter('outputDims',1);
% evaluate.setDefaultParameter('settings.kernel_numWindows',4);
evaluate.setDefaultParameter('numEigenvectors',25);


% referenceSet settings
settings.setProperty('state1KRS_maxSizeReferenceSet', 1000);
settings.setProperty('state2KRS_maxSizeReferenceSet', 1000);
settings.setProperty('state3KRS_maxSizeReferenceSet', 1000);
evaluate.setDefaultParameter('settings.state1KRS_inputDataEntry', 'x1');
evaluate.setDefaultParameter('settings.state1KRS_validityDataEntry', 'thetaNoisyPicturePcaFeaturesWindowsValid');
evaluate.setDefaultParameter('settings.state2KRS_inputDataEntry', 'x2');
evaluate.setDefaultParameter('settings.state2KRS_validityDataEntry', 'thetaNoisyPicturePcaFeaturesWindowsValid');
evaluate.setDefaultParameter('settings.state3KRS_inputDataEntry', 'x3');
evaluate.setDefaultParameter('settings.state3KRS_validityDataEntry', 'thetaNoisyPicturePcaFeaturesWindowsValid');


% optimization settings
evaluate.setDefaultParameter('settings.spectralOptimizer_inputDataEntry','thetaNoisyPicturePcaFeaturesWindows');
evaluate.setDefaultParameter('settings.groundtruthName','theta');
evaluate.setDefaultParameter('settings.CMAOptimizerInitialRangeSpectral_CMAES_optimization', .1);
evaluate.setDefaultParameter('settings.maxNumOptiIterationsSpectral_CMAES_optimization', 500);

evaluate.setDefaultParameter('evaluationGroundtruth','theta');
evaluate.setDefaultParameter('evaluationObservations','x1');
evaluate.setDefaultParameter('evaluationValid','thetaNoisyPicturePcaFeaturesWindowsValid');

experiment = Experiments.Experiment.createByNameNew(experimentName, category, ...
     {configuredTask, configuredStateAliasAdder, configuredNoisePreprocessor, configuredImageFeature, configuredLinearTransformFeature, configuredFeatureLearner, configuredWindowPreprocessor, configuredWindowAliasAdder, configuredObservationPointsPreprocessor, configuredSpectral}, evaluationCriterion, 5, ...
    {'127.0.0.1',1});

experiment.addEvaluation(evaluate);
experiment.startBatch(32,4);
% experiment.startLocal