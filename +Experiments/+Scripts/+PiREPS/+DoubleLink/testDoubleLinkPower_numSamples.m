close all;

Common.clearClasses();
%clear all;
clc;

%MySQL.mym('closeall');

category = 'test';
experimentName = 'temperatureScalingPower';
numTrials = 5;
numIterations = 100;

configuredTask = Experiments.Tasks.DoubleLinkSwingUpFiniteHorizon();
configuredTask.addParameterSetter(@Experiments.ParameterSettings.PathIntegralRewardSettings);

%%
configuredLearner = Experiments.Learner.StepBasedComposedTimeDependentLearningSetup('Power');

evaluationCriterion = Experiments.EvaluationCriterion();

evaluate = Experiments.Evaluation(...
    {'settings.maxCorrActions',  'settings.Noise_std', 'settings.initSigmaActions'},{...
    1.0, 0.05, 1.0; ...
    },numIterations,numTrials);

numSamples = Experiments.Evaluation({'settings.numSamplesEpisodes', 'settings.maxSamples'}, {...
            800 800;
            }, numIterations,numTrials);

lambda = Experiments.Evaluation(...
    {'settings.PathIntegralCostActionMultiplier'},{...
    1; 
    },numIterations,numTrials);

lambdaPower = Experiments.Evaluation(...
    {'settings.temperatureScalingPower'},{...
    7; 10; 13; 17;...
    },numIterations,numTrials);


% learner = Experiments.Evaluation(...
%     {'learner'},{...
%     @Learner.StepBasedRL.StepBasedRLPower; ...
%     },numIterations,numTrials);
learner = Experiments.Evaluation(...
    {'learner'},{...
    @Learner.StepBasedRL.StepBasedPower.CreateFromTrialKnowsNoise; ...
%    @Learner.StepBasedRL.StepBasedPower.CreateFromTrial; ...
    },numIterations,numTrials);
% learner = Experiments.Evaluation(...
%     {'learner'},{...
%     @Learner.StepBasedRL.StepBasedRLREPS; ...
%     },numIterations,numTrials);

%learner.setDefaultParameter('policyLearner', []);

evaluate = Experiments.Evaluation.getCartesianProductOf([evaluate, learner, lambda, lambdaPower, numSamples]);


experiment = Experiments.Experiment.createByName(experimentName, category, ...
    configuredTask, configuredLearner, evaluationCriterion, 5, ...
    {'127.0.0.1',2});

experiment.addEvaluation(evaluate);
experiment.startLocal();
%experiment.startRemote();