close all;

Common.clearClasses();
%clear all;
clc;

MySQL.mym('closeall');

category = 'NaoWalking';
experimentName = 'numSamples';
numTrials = 2;
numIterations = 500;
%global con


configuredTask = NaoWalking.NaoBanditTaskHeightChange();

%%
configuredLearner = Experiments.Learner.BanditLearnedRewardModelLearningSetup('REPSWalkingWithoutHeighChange');

evaluationCriterion = Experiments.EvaluationCriterion();

evaluationCriterion.addCriterion('endLoop', 'data', 'contexts', Experiments.StoringType.STORE_PER_ITERATION, @(data)data.getDataEntry3D('contexts'));
evaluationCriterion.addCriterion('endLoop', 'data', 'parameters', Experiments.StoringType.STORE_PER_ITERATION, @(data)data.getDataEntry3D('parameters'));


default = Experiments.Evaluation(...
    {'learner'},{...
    @Learner.EpisodicRL.EpisodicREPS.CreateFromTrial; ...
    },numIterations,numTrials);

default.setDefaultParameter('settings.numSamplesEpisodes',30);
default.setDefaultParameter('parameterPolicyLearner', @Learner.SupervisedLearner.ShrunkLinearGaussianMLLearner);
default.setDefaultParameter('settings.numInitialSamplesEpisodes', 100);
default.setDefaultParameter('settings.maxSamples', 200);
default.setDefaultParameter('settings.maxCorrParameters', 1.0);
default.setDefaultParameter('settings.initSigmaParameters', 0.3);
default.setDefaultParameter('settings.numSamplesEpisodesVirtual', 1000);
default.setDefaultParameter('settings.epsilonAction', 0.5);
default.setDefaultParameter('settings.numPara', 4);
default.setDefaultParameter('settings.bayesParametersSigma', 0.1);
default.setDefaultParameter('settings.numProjMat', 1000);
default.setDefaultParameter('settings.bayesNoiseSigma',10);
default.setDefaultParameter('useVirtualSamples', false);
default.setDefaultParameter('settings.entropyBeta', 0.5);
default.setDefaultParameter('settings.entropyBetaDiscount', 0.984);
%default.setDefaultParameter('settings.InitialContextDistributionType', 'Gaussian');
default.setDefaultParameter('settings.InitialContextDistributionType', 'Uniform');
default.setDefaultParameter('useFeaturesForPolicy',false);
default.setDefaultParameter('contextFeatures',@FeatureGenerators.RBF.RadialFeatures);
default.setDefaultParameter('settings.rbfBandwidth',0.5);
default.setDefaultParameter('settings.rbfNumDimCenters', 3);
%default.setDefaultParameter('settings.InitialContextDistributionWidth', 0.2);

evaluate1 = Experiments.Evaluation(...
    {'settings.numPara'},{4},numIterations,numTrials);
evaluate1.setDefaultParametersFromEvaluation(default);


experiment = Experiments.Experiment.createByName(experimentName, category, ...
    configuredTask, configuredLearner, evaluationCriterion, 5, ...
    {'127.0.0.1',2});

experiment.addEvaluation(evaluate1);
experiment.startLocal();