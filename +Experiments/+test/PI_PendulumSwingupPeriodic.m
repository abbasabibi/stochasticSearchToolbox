%close all;

%Common.clearClasses();
%clear all;
%clc;

%MySQL.mym('closeall');

category = 'test';
experimentName = 'test';
numTrials = 1;
numIterations = 20;

configuredTask = Experiments.Tasks.SwingUpTaskPeriodic(true);
configuredTask_nonperiodic = Experiments.Tasks.StepBasedLinear(true);
configuredTask.addParameterSetter(@ParameterSettings.PathIntegralMultiplierSettings);
configuredTask_nonperiodic.addParameterSetter(@ParameterSettings.PathIntegralMultiplierSettings);

%%
configuredLearner = Experiments.Learner.StepBasedPIRKHS('PI_RKHSPeriodic');

evaluationCriterion = Experiments.EvaluationCriterion();
%evaluationCriterion.registerEvaluator(Evaluator.ReturnEvaluatorEvaluationSamples());
%
%evaluationCriterion.registerEvaluator(Evaluator.SaveDataAndTrial());



evaluate1 = Experiments.Evaluation(...
    {'settings.RKHSparamsstate','settings.numSamplesEvaluation','settings.Noise_std','settings.actionCost'},{...
     [1e-4, 1,  0.7114 1 4.3664],...
     100,...
     5,...
     0.05,...
    },numIterations,numTrials);

evaluate_nonperiodic = Experiments.Evaluation(...
    {'settings.RKHSparamsstate','settings.numSamplesEvaluation','settings.Noise_std','settings.actionCost', 'stateFeatures', 'nextStateFeatures'},{...
     [1e-4, 1,  0.7114 4.3664],...
     100,...
     5,...
     0.05,...
     @(trial) FeatureGenerators.Kernel.ExponentialQuadraticKernel( ...
        trial.dataManager, {'states'}, ':', trial.maxFeat),...
     @(trial) FeatureGenerators.Kernel.ExponentialQuadraticKernel( ...
        trial.dataManager, {'nextStates'}, ':', trial.maxFeat,{'states'}), ...  
    },numIterations,numTrials);

 
experiment = Experiments.Experiment.createByName(experimentName, category, configuredTask, configuredLearner, evaluationCriterion, 5);

experiment_nonperiodic = Experiments.Experiment.createByName(experimentName, category, configuredTask_nonperiodic, configuredLearner, evaluationCriterion, 5);

experiment.addEvaluation(evaluate1);
experiment.startLocal();

experiment_nonperiodic.addEvaluation(evaluate_nonperiodic)
%experiment_nonperiodic.startLocal;
%experiment.startBatch(50);

