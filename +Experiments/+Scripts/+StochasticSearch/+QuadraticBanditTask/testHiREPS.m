close all;

Common.clearClasses();
%clear all;
clc;

%MySQL.mym('closeall');

category = 'test';

numOptions          = 1;
numSamples          = 5;
numMaxSamples       = 1*numSamples;
numIterations       = 20;
epsilonAction       = 1;
epsilonOption       = 1;
numTrials           = 50;

configuredTask = Experiments.Tasks.QuadraticBanditTask();


%%
configuredPolicy            = Experiments.ActionPolicies.ParameterMixtureModelConfigurator('MixtureModel');

configuredLearner           = Experiments.Learner.HiREPSBanditLearningSetup('HiREPS');

evaluationCriterion         = Experiments.EvaluationCriterion();
evaluationCriterion.registerEvaluator(Evaluator.ReturnEvaluatorNewSamples());

% evaluationCriterion = Experiments.EvaluationCriterion();
% evaluator = Evaluator.ReturnEvaluatorEvaluationSamples();
% evaluationCriterion.registerEvaluator(evaluator);


%%

% evaluate = Experiments.Evaluation(...
%     {'settings.numSamplesEpisodes'},{200},numIterations,numTrials); %test
% experimentName = 'test';

% evaluate = Experiments.Evaluation(...
%     {'settings.numOptions'},{1, 2, 5, 10}, numIterations,numTrials);  %numOptions
% experimentName = 'NumOptions';

% evaluate = Experiments.Evaluation(...
%     {'settings.maxSamples'},{20, 40, 80, 120},numIterations,numTrials); %MaxSamples
% experimentName = 'MaxSamples';


% evaluate = Experiments.Evaluation(...
%     {'settings.epsilonOption'},{0.9, 0.95, 1, 1.05},numIterations,numTrials); %EpsilonOption
% experimentName = 'EpsilonOption';


evaluate = Experiments.Evaluation(...
    {'settings.epsilonAction'},{0.1},numIterations,numTrials); %EpsilonAction
experimentName = 'EpsilonAction';



%%
evaluate.setDefaultParameter('settings.numOptions', numOptions);
evaluate.setDefaultParameter('settings.epsilonAction',epsilonAction);
evaluate.setDefaultParameter('settings.epsilonOption',epsilonOption);
evaluate.setDefaultParameter('settings.initSigmaParameters',1);

evaluate.setDefaultParameter('settings.InitialStateDistributionType', 'Uniform');


evaluate.setDefaultParameter('settings.softMaxRegressionToleranceF', 1e-12);


evaluate.setDefaultParameter('settings.InitialContextDistributionWidth', 1.0);
evaluate.setDefaultParameter('settings.InitialContextDistributionType', 'Uniform');

evaluate.setDefaultParameter('settings.numSamplesEpisodes', numSamples);
evaluate.setDefaultParameter('settings.maxSamples', numMaxSamples);
evaluate.setDefaultParameter('settings.numInitialSamplesEpisodes', numMaxSamples);



experiment = Experiments.Experiment.createByNameNew(experimentName, category, ...
     {configuredTask, configuredPolicy, configuredLearner}, evaluationCriterion, 5, ...
    {'127.0.0.1',1});



experiment.addEvaluation(evaluate);
experiment.startBatch(1);