close all;

Common.clearClasses();
%clear all;
clc;

%MySQL.mym('closeall');

category = 'NaoWalking';
experimentName = 'numSamples';
numTrials = 1;
numIterations = 1000;
%global con
%load('walkkickinitialtypr4.mat')
load('typeForInitial22para.mat')
configuredTask = Environments.NaoWalking.NaoKickReturn();

%%
configuredLearner = Experiments.Learner.BanditLearningSetup('ContextualRepsKick');

evaluationCriterion = Experiments.EvaluationCriterion();

evaluationCriterion.addCriterion('endLoop', 'data', 'contexts', Experiments.StoringType.STORE_PER_ITERATION, @(data)data.getDataEntry3D('contexts'));
evaluationCriterion.addCriterion('endLoop', 'data', 'parameters', Experiments.StoringType.STORE_PER_ITERATION, @(data)data.getDataEntry3D('parameters'));

evaluationCriterion = Experiments.EvaluationCriterion();
evaluationCriterion.saveNumDataPoints = 10;

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




default.setDefaultParameter('settings.numSamplesEpisodes',25);
default.setDefaultParameter('parameterPolicyLearner', @Learner.SupervisedLearner.RankMuLinearGaussianMLLearner);
default.setDefaultParameter('settings.numInitialSamplesEpisodes', 200);
default.setDefaultParameter('settings.maxSamples', 600);
default.setDefaultParameter('settings.maxCorrParameters', 1.0);
default.setDefaultParameter('settings.initSigmaParameters', 0.25);
%default.setDefaultParameter('settings.numSamplesEpisodesVirtual', 1000);
default.setDefaultParameter('settings.epsilonAction', 1);
default.setDefaultParameter('settings.initMuParameters',initial);
default.setDefaultParameter('settings.entropyPerEffSample',0.006);

default.setDefaultParameter('useVirtualSamples', false);

evaluate1 = Experiments.Evaluation(...
    {'settings.epsilonAction'},{1},numIterations,numTrials);
evaluate1.setDefaultParametersFromEvaluation(default);


experiment = Experiments.Experiment.createByName(experimentName, category, ...
    configuredTask, configuredLearner, evaluationCriterion, 5, ...
    {'127.0.0.1',2});

experiment.addEvaluation(evaluate1);
experiment.startLocal();