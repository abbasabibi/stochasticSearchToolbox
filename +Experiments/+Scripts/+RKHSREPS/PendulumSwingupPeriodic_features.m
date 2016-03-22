%close all;

%Common.clearClasses();
%clear all;
%clc;

%MySQL.mym('closeall');

category = 'test';
experimentName = 'test';
numTrials = 1;
numIterations = 1;

configuredTask = Experiments.Tasks.SwingUpTaskPeriodic(true);

%%
configuredLearner = Experiments.Learner.StepBasedRKHSREPS('RKHSREPSPeriodic');

% feature configurator
configuredFeatures = Experiments.Features.FeatureRBFKernelStatesPeriodicNew;
configuredPolicyFeatures = Experiments.Features.PolicyFeatureGenerator;
%configuredActionFeatures = Experiments.Features.FeatureRBFKernelActionsProdNew;
configureModelKernel = Experiments.Features.ModelFeatures;

% action policy configurator
configuredPolicy = Experiments.ActionPolicies.GaussianProcessPolicyConfiguratorNew;


evaluationCriterion = Experiments.EvaluationCriterion();



evaluationCriterion.registerEvaluator(Evaluator.ReturnEvaluatorEvaluationSamplesAverage());
%evaluationCriterion.registerEvaluator(Evaluator.SaveDataAndTrial());
% try 500 features
nfeatures = 500;

evaluate = Experiments.Evaluation(...
     {'GPInitializer','GPLearnerInitializer','policyInputVariables','policyFeatureGenerator'},...
     {...
           @Kernels.GPs.GaussianProcess.CreateSquaredExponentialPeriodicGP,...
           @Kernels.Learner.GPHyperParameterLearnerCVTrajLikelihood.CreateWithStandardReferenceSet,...
           {'states'},...
           []
         ;...
           @(dm, out, in,i) Distributions.Gaussian.GaussianLinearInFeaturesQuadraticCovariance(dm, out, in, 'BayesLinear'),... 
           @Learner.SupervisedLearner.BayesianLinearHyperLearnerCV...
           {'policyFeatures'},...%special policyFeatures? -> influences REPS if it is stateFeatures...?
            @(trial_) FeatureGenerators.FourierKernelFeatures(trial_.dataManager, copy(trial_.stateKernel), nfeatures, 'states', '~policyFeatures'),...
         ;...




    },numIterations,numTrials);

evaluate.setDefaultParameter('useStateFeaturesForPolicy' , false);

evaluate.setDefaultParameter('settings.RKHSparams_V' , [-1e-2 -0.6 -5]);
evaluate.setDefaultParameter('settings.RKHSparams_ns' ,[-1e-2 -0.6 -5 -50] );
evaluate.setDefaultParameter('settings.tolSF',0.0001);
evaluate.setDefaultParameter('settings.epsilonAction' , 0.5);
evaluate.setDefaultParameter('settings.numSamplesEvaluation' , 100);
evaluate.setDefaultParameter('settings.GPVarianceNoiseFactorActions' ,1/sqrt(2) );
evaluate.setDefaultParameter('settings.GPVarianceFunctionFactor' ,1/sqrt(2) );

%what is the difference between these two?
evaluate.setDefaultParameter('settings.maxSizeReferenceSet' , 3000);
evaluate.setDefaultParameter('maxNumberKernelSamples', 3000);
evaluate.setDefaultParameter('settings.HyperParametersOptimizerBayesLinearOptimizerActions','FMINUNC')
evaluate.setDefaultParameter('settings.HyperParametersOptimizerGaussianProcessActions','FMINUNC')
evaluate.setDefaultParameter('settings.HyperParametersOptimizerGPOptimizationActions','FMINUNC')
safeatures = @(trial) FeatureGenerators.FourierKernelFeatures(trial.dataManager, trial.modelKernel, nfeatures, {{'states','actions'}}, '~stateactionFeatures');
%evaluate.setDefaultParameter('modelLearner', @(trial) ...
%    Learner.ModelLearner.FeatureModelLearnernew(trial.dataManager, ...
%    ':', trial.stateFeatures,...
%    trial.nextStateFeatures,safeatures(trial)));
%evaluate.setDefaultParameter('stateFeatures', @(trial_) FeatureGenerators.FourierKernelFeatures(trial_.dataManager, trial_.stateKernel, nfeatures, 'states', '~stateFeatures'));            
%evaluate.setDefaultParameter('nextStateFeatures', @(trial_) FeatureGenerators.FourierKernelFeatures(trial_.dataManager, trial_.stateKernel, nfeatures, 'nextStates', '~nextStateFeatures'));
            
% evaluate.setDefaultParameter('GPInitializer', @Kernels.GPs.GaussianProcess.CreateSquaredExponentialPeriodicGP);
% evaluate.setDefaultParameter('GPLearnerInitializer', @Kernels.Learner.GPHyperParameterLearnerCVTrajLikelihood.CreateWithStandardReferenceSet);
% 



evaluateModel = Experiments.Evaluation(...
     {'modelLearner','stateFeatures','nextStateFeatures'},...
     {...
           @(trial) Learner.ModelLearner.FeatureModelLearnernew(trial.dataManager, ...
            ':', trial.stateFeatures,...
            trial.nextStateFeatures,safeatures(trial)),...
            @(trial_) FeatureGenerators.FourierKernelFeatures(trial_.dataManager, trial_.stateKernel, nfeatures, 'states', '~stateFeatures'),...
            @(trial_) FeatureGenerators.FourierKernelFeatures(trial_.dataManager, trial_.stateKernel, nfeatures, 'nextStates', '~nextStateFeatures')...
         ;...
            @(trial) Learner.ModelLearner.RKHSModelLearnernew(trial.dataManager, ...
                ':', trial.stateFeatures,...
                trial.nextStateFeatures,trial.modelKernel),...
            @(trial_) Kernels.KernelBasedFeatureGenerator(trial_.dataManager, trial_.stateKernel, 'states', '~stateFeatures'),...
            @(trial_) Kernels.KernelBasedFeatureGenerator(trial_.dataManager, trial_.stateKernel, 'nextStates', '~nextStateFeatures')
         ;...
    },numIterations,numTrials);



evaluate_all = Experiments.Evaluation.getCartesianProductOf([evaluate, evaluateModel]);



 
experiment = Experiments.Experiment.createByNameNew(experimentName, category, ...
    {configuredTask, configuredFeatures, configureModelKernel, configuredPolicyFeatures, ...
    configuredPolicy, configuredLearner}, evaluationCriterion, 5);

experiment.addEvaluation(evaluate_all);


experiment.startLocal();
%experiment.startBatch(20);

