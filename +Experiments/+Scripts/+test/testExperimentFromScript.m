close all;

Common.clearClasses();

numTrials = 10;

experiment = Experiments.ExperimentFromScript('test', 'PolicyEvaluation.tests.testLSTDFeatureLearnerPendulum');
experiment = Experiments.Experiment.addToDataBase(experiment);


% We can add single evaluations
evaluation1 = experiment.addEvaluationCollection({'maxSizeReferenceSet'}, {300; 400}, numTrials);


% Start experiment
experiment.startLocal()

%We can also just start evaluations or collections
%evaluationCol1.startLocal();

%%
evaluationCol1.plotResultsTrials()

