close all;

Common.clearClasses();
%clear all;
clc;

%MySQL.mym('closeall');

category = 'test';
experimentName = 'numSamples';
numTrials = 10;
numIterations = 300;

configuredTask = Experiments.Tasks.PlanarReaching();

%%
configuredLearner = Experiments.Learner.TrajectoryBasedLearningSetup('BOWithoutNoise');

evaluationCriterion = Experiments.EvaluationCriterion();

standard = Experiments.Evaluation(...
    {'settings.initSigmaParameters'},{0.01},numIterations,numTrials);

standard.setDefaultParameter('settings.numSamplesEpisodes', 1.0);
standard.setDefaultParameter('settings.numInitialSamplesEpisodes', 100.0);
standard.setDefaultParameter('settings.maxCorrParameters', 1.0);
standard.setDefaultParameter('settings.initSigmaParameters', 0.025);
standard.setDefaultParameter('settings.numBasis', 5);
standard.setDefaultParameter('numJoints', 5);
standard.setDefaultParameter('settings.viaPointNoise', 0.0);
standard.setDefaultParameter('parameterPolicy', @BayesianOptimisation.Opt.BayesianOptimisationPolicy);            
standard.setDefaultParameter('parameterPolicyLearner', []);                        
standard.setDefaultParameter('learner', @BayesianOptimisation.Opt.BayesianOptimisation.CreateFromTrial);                        
 
evaluate = Experiments.Evaluation.getCartesianProductOf([standard]);


experiment = Experiments.Experiment.createByName(experimentName, category, ...
    configuredTask, configuredLearner, evaluationCriterion, 5, ...
    {'127.0.0.1',2});

experiment.addEvaluation(evaluate);
experiment.startBatch(10);
%experiment.startLocal();
