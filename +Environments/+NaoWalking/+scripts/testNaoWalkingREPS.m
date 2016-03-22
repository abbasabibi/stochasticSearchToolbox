close all;

Common.clearClasses();
%clear all;
clc;

%MySQL.mym('closeall');

category = 'NaoWalking';
experimentName = 'numSamples';
numTrials = 5;
numIterations = 300;
%global con


%configuredTask = NaoWalking.NaoBanditTask();

%%
configuredLearner = Experiments.Learner.BanditLearningSetup('ContextualREPS');



configuredTask = Environments.NaoWalking.NaoBanditTaskHeightChange();

%%

evaluationCriterion = Experiments.EvaluationCriterion();
evaluationCriterion.saveNumDataPoints = 5;

evaluationCriterion.addCriterion('endLoop', 'data', 'contexts', Experiments.StoringType.STORE_PER_ITERATION, @(data)data.getDataEntry3D('contexts'));
evaluationCriterion.addCriterion('endLoop', 'data', 'parameters', Experiments.StoringType.STORE_PER_ITERATION, @(data)data.getDataEntry3D('parameters'));

evaluator = Evaluator.ReturnConditionNumber();
evaluationCriterion.registerEvaluator(evaluator);
evaluator = Evaluator.Returnmedian();
evaluationCriterion.registerEvaluator(evaluator);
evaluator = Evaluator.Returnmax;
evaluationCriterion.registerEvaluator(evaluator);

default = Experiments.Evaluation(...
    {'learner'},{...
    @Learner.EpisodicRL.EpisodicREPS.CreateFromTrial; ...
    },numIterations,numTrials);

default.setDefaultParameter('settings.numSamplesEpisodes',20);
default.setDefaultParameter('settings.numInitialSamplesEpisodes', 500);
default.setDefaultParameter('settings.maxSamples', 600);
default.setDefaultParameter('settings.maxCorrParameters', 1.0);
default.setDefaultParameter('settings.initSigmaParameters', 0.1);
default.setDefaultParameter('settings.epsilonAction', 1);
default.setDefaultParameter('settings.entropyPerEffSample',0.005);
default.setDefaultParameter('useFeaturesForPolicy',true);
default.setDefaultParameter('contextFeatures',@FeatureGenerators.RBF.RadialFeatures);
default.setDefaultParameter('settings.rbfBandwidth',[0.09]);
default.setDefaultParameter('settings.rbfNumDimCenters', 5);
default.setDefaultParameter('parameterPolicyLearner', @Learner.SupervisedLearner.RankMuLinearGaussianMLLearner);



evaluate1 = Experiments.Evaluation(...
    {'settings.numPara'},{4},numIterations,numTrials);
evaluate1.setDefaultParametersFromEvaluation(default);


experiment = Experiments.Experiment.createByName(experimentName, category, ...
    configuredTask, configuredLearner, evaluationCriterion, 5, ...
    {'127.0.0.1',2});

experiment.addEvaluation(evaluate1);
experiment.startLocal();


