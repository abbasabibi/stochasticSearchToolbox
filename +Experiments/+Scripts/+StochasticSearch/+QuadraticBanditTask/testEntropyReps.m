close all;

%Common.clearClasses();
%clear all;
clc;

%MySQL.mym('closeall');

category = 'test';
experimentName = 'numSamples';
numTrials = 5;
numIterations =1000;

%configuredTask = Experiments.Tasks.QuadraticBanditTask();
%configuredTask = Experiments.Tasks.StandardOptimisationFunctions();
configuredTask = Experiments.Tasks.PlanarHoleReaching();
%configuredTask = Experiments.Tasks.PlanarReaching();
%configuredTask = Experiments.Tasks.StandardOptimisationFunctions();


%configuredTrajectoryGenerator = Experiments.Learner.TrajectoryBasedLearningSetup();
configuredTrajectoryGenerator = Experiments.TrajectoryGenerators.TrajectoryBasedLearningSetup();


%%
configuredLearner = Experiments.Learner.BanditLearnedRewardModelLearningSetup('MOREholeReaching');
configuredImportanceWeighting = Experiments.Preprocessor.ImportanceSamplingLastKPreprocessor();

%             if (trial.useImportanceWeightings)
%                 
%                 trial.setprop('importanceSampler', Experiments.Preprocessor.ImportanceSamplingLastKPreprocessor());
%                 trial.preprocessors = [{trial.importanceSampler}, trial.preprocessors];
%             
%             end

evaluationCriterion = Experiments.EvaluationCriterion();

% evaluator = Evaluator.RmatrixEvaluation();
% evaluationCriterion.registerEvaluator(evaluator);
%evaluator = Evaluator.ReturnEvaluatorEvaluationSamples();
 %evaluationCriterion.registerEvaluator(evaluator);


default = Experiments.Evaluation(...
{'learner'},{...
    @Learner.EpisodicRL.ConstraintEntropyREPSCLosedForm.CreateFromTrial; ...
    },numIterations,numTrials);



%default = Experiments.Evaluation(...
%{'learner'},{...
%    @Learner.EpisodicRL.EntropyREPSClosedFormWithContext.CreateFromTrial; ...
%    },numIterations,numTrials);

%set the reward function here
%default.setDefaultParameter('rewardFunctionLearner', @Learner.ModelLearner.simpleQuadraticBayesianlearnerWithPrior);
default.setDefaultParameter('standardRewardFunction', @Environments.BanditEnvironments.RosenbrockReward);
%default.setDefaultParameter('standardRewardFunction', @Environments.BanditEnvironments.SphereReward);
default.setDefaultParameter('settings.useGoalPos',true);
default.setDefaultParameter('settings.numSamplesEpisodes',40);
default.setDefaultParameter('settings.numInitialSamplesEpisodes', 100);
default.setDefaultParameter('settings.maxSamples', 500);
default.setDefaultParameter('settings.maxCorrParameters', 1.0);
default.setDefaultParameter('settings.initSigmaParameters', 0.05);
default.setDefaultParameter('settings.numSamplesEpisodesVirtual', 0);
default.setDefaultParameter('settings.epsilonAction',1);
default.setDefaultParameter('settings.numPara',5);
default.setDefaultParameter('settings.bayesParametersSigma', 100000);
default.setDefaultParameter('settings.viaPointNoise',0);
default.setDefaultParameter('settings.numProjMat', 1000);
default.setDefaultParameter('settings.bayesNoiseSigma',100000);
default.setDefaultParameter('useVirtualSamples', false);
%default.setDefaultParameter('settings.entropyBeta', 0);
default.setDefaultParameter('settings.eta',1);


default.setDefaultParameter('settings.entropyBetaDiscount',  0.997);

default.setDefaultParameter('settings.rewardNoiseMult',0);
default.setDefaultParameter('dimParameters',42);
default.setDefaultParameter('settings.numSamplesVirtual', 0);
default.setDefaultParameter('settings.numInitialSamplesVirtual', 0);
default.setDefaultParameter('settings.projectContext',false);
default.setDefaultParameter('settings.useViaPointContext', false);
default.setDefaultParameter('settings.viaPointNoise', 0.0);
default.setDefaultParameter('numBasis', 5); 
default.setDefaultParameter('numJoints', 5);
default.setDefaultParameter('settings.numBasis', 5); 
default.setDefaultParameter('settings.numJoints', 5);
%default.setDefaultParameter('useVirtualSamples', false);
default.setDefaultParameter('parameterPolicyLearner', @Learner.SupervisedLearner.ShrunkLinearGaussianMLLearner);

%number of samples for NES
default.setDefaultParameter('settings.L', 40);
%nember of samples for CMA-ESx
default.setDefaultParameter('settings.lambda', 20);
evaluate1 = Experiments.Evaluation(...
    {'settings.entropyBetaDiscount'},{0.997,0.999},numIterations,numTrials);
evaluate1.setDefaultParametersFromEvaluation(default);


% experiment = Experiments.Experiment.createByName(experimentName, category, ...
%     configuredTask,configuredTrajectoryGenerator, configuredLearner, evaluationCriterion, 5, ...
%     {'127.0.0.1',2});
%   experiment = Experiments.Experiment.createByNameNew(experimentName, category, ...
%       {configuredTask,configuredLearner,configuredImportanceWeighting}, evaluationCriterion, 5, ...
%       {'127.0.0.1',2});

 experiment = Experiments.Experiment.createByNameNew(experimentName, category, ...
     {configuredTask, configuredTrajectoryGenerator, configuredLearner, configuredImportanceWeighting}, evaluationCriterion, 5, ...
     {'127.0.0.1',2});
experiment.addEvaluation(evaluate1);
experiment.startLocal();
%experiment.startRemote();
%experiment.startBatch(5);