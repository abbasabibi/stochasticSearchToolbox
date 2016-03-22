clear variables;
close all;
addpath(genpath('Helper/'));

% rng(3)
% warning('RNG is fixed');

numOptions          = 10;
numSamples          = 20;
numMaxSamples       = 3*numSamples;
numSizeReferenceSet = 300;
numIterations       = 100;
maxIterationsEM     = 20;
toleranceEM         = -inf;

epsilonAction       = 1;
epsilonOption       = 100;

dt                  = 0.05;

numTimeSteps        = 50;
restartProb         = 1/numTimeSteps;


fileName = 'Helper/PendulumTrajs/dataHandCoded';


minRangeContexts = [-pi -10];
maxRangeContexts = [pi 10];
maxRangeActions     = 35;


settings = Common.Settings();

settings.setProperty('numSamplesEpisodes', numSamples);
settings.setProperty('numTimeSteps', numTimeSteps);
settings.setProperty('periodicRange', [-pi, pi]);

settings.setProperty('InitialStateDistributionMinRange', minRangeContexts);
settings.setProperty('InitialStateDistributionMaxRange', maxRangeContexts);
settings.setProperty('pendulumStateMinRange', minRangeContexts);
settings.setProperty('pendulumStateMaxRange', maxRangeContexts);
settings.setProperty('pendulumActionMaxRange', maxRangeActions);

settings.setProperty('InitialContextDistributionWidth', 1);
settings.setProperty('InitialStateDistributionType', 'Uniform');
settings.setProperty('maxTorque', maxRangeActions);


settings.setProperty('numOptions',numOptions);
settings.setProperty('epsilonAction', epsilonAction);
settings.setProperty('epsilonOption',epsilonOption);
settings.setProperty('initSigmaParameters',0.5);

settings.setProperty('logLikelihoodThresholdEM',toleranceEM);
settings.setProperty('softMaxRegressionTerminationFactor',1e-9);
settings.setProperty('softMaxRegressionToleranceF', 1e-15);

settings.setProperty('numInitialSamplesEpisodes', numMaxSamples);
settings.setProperty('maxSamples', numMaxSamples);
settings.setProperty('kernelMedianBandwidthFactor', 0.5);

settings.setProperty('debugPlottingMM', true);

settings.setProperty('regularizationRegression', 1e-15);
settings.setProperty('logisticRegressionRegularizer', 1e-20);

settings.setProperty('dt', dt);
% settings.setProperty('resetProbDecisionSteps', restartProb);
settings.setProperty('useKMeans',false); %Only for the EM, KMeans is already done before
settings.setProperty('respNameEM', 'responsibilities');




sampler             = Sampler.EpisodeWithStepsSamplerOptions();
dataManager         = sampler.getEpisodeDataManager();
dataManager.finalizeDataManager();



environment         = Environments.DynamicalSystems.Pendulum(sampler, true); %periodic
environment.initObject();

depth = dataManager.getDataEntryDepth('states');
dataManager.addDataEntryForDepth(depth, 'options', 1, 1, numOptions);
dataManager.addDataEntryForDepth(depth, 'optionsOld', 1, 1, numOptions);
dataManager.addDataEntryForDepth(depth, 'terminations', 1, 1, 2);
% dataManager.addDataEntryForDepth(depth, 'contexts', dataManager.getNumDimensions('states')); %Doesnt work, context is already set as alias?
dataManager.addDataEntry('contexts',2)



initialStateSampler = Sampler.InitialSampler.InitialStateSamplerStandard(sampler);

sampler.setTransitionFunction(environment);
sampler.setInitialStateSampler(initialStateSampler);


actionCost = 0;
stateCost = [10 0; 0 0];
rewardFunction = RewardFunctions.QuadraticRewardFunctionSwingUpSimple(dataManager); %non multimodal reward
rewardFunction.setStateActionCosts(stateCost, actionCost);
returnSampler       = RewardFunctions.ReturnForEpisode.ReturnAvgReward(dataManager);



sampler.setRewardFunction(rewardFunction);
sampler.setReturnFunction(returnSampler); 
% sampler.getStepSampler.setIsActiveSampler(Sampler.IsActiveStepSampler.IsActiveFixedGamma(dataManager)); %doesnt work atm with the EM, would need to change some stuff  
sampler.getStepSampler.setIsActiveSampler(Sampler.IsActiveStepSampler.IsActiveNumSteps(dataManager));




dataManager.finalizeDataManager();
dataManager.setRange('states', minRangeContexts, maxRangeContexts);
dataManager.setRange('actions', -50, 50);

sampler.initObject();
dataManager.finalizeDataManager();
%%
squaredFeatures = FeatureGenerators.SquaredFeatures(dataManager, 'states', [], true);
linearFeatures  = FeatureGenerators.LinearFeatures(dataManager, 'states', [], true);

inputFeatureDim     = dataManager.getNumDimensions('states');

contextKernel       = Kernels.Kernel.createKernelSQEPeriodic(dataManager, 'states');
contextFeatures     = Kernels.KernelBasedFeatureGenerator(dataManager, contextKernel, {'states'}, '~stateFeatures');
nextContextFeatures = Kernels.KernelBasedFeatureGenerator(dataManager, contextKernel, {'nextStates'}, '~nextStateFeatures');

nextContextFeatures.setExternalReferenceSet(contextFeatures);

referenceSetLearner = Kernels.Learner.RandomKernelReferenceSetLearner(dataManager, contextFeatures);
kernelBandwidthLearner = Kernels.Learner.MedianBandwidthSelector(dataManager, contextKernel, referenceSetLearner, contextFeatures);

sampler.initObject();
%%



gaussianDist  = Distributions.Gaussian.GaussianLinearInFeatures(dataManager, 'actions', 'states', 'ActionPolicy');

optionLearner = Learner.SupervisedLearner.LinearGaussianMLLearner(dataManager, gaussianDist);
optionInitializer = @Distributions.Gaussian.GaussianLinearInFeatures;


gatingDist    = Distributions.Discrete.SoftMaxDistribution(dataManager, 'options', squaredFeatures.outputName, 'Gating');
gatingLearner = Learner.ClassificationLearner.MultiClassLogisticRegressionLearner(dataManager, gatingDist, true); %false or true???

gatingDist.setThetaAllItems(rand(size(gatingDist.thetaAllItems)) -0.5);


mixtureModel  = Distributions.MixtureModel.MixtureModel.createPolicy(...
    dataManager, gatingDist, optionInitializer, 'actions', 'states', 'options');


sampler.setActionPolicy(mixtureModel);
sampler.setParallelSampling(true);


mixtureModel.initObject();
gatingDist.initObject();

mixtureModelLearner = Learner.SupervisedLearner.MixtureModelLearner(dataManager, mixtureModel, optionLearner, gatingLearner, 'outputResponsibilities');

initMMLearner         = Learner.SupervisedLearner.InitMMLearner(dataManager, mixtureModelLearner);

%Needs resetProb
modelLearner    = Learner.ModelLearner.SampleModelLearner(dataManager, ':', contextFeatures, [], [], sampler.stepSampler.isActiveSampler.resetProbName);
% modelLearner    = Learner.ModelLearner.SampleModelLearner(dataManager, ':', contextFeatures, [], []);
repsLearner     = Learner.SteadyStateRL.HiREPSIter(dataManager, mixtureModelLearner, 'rewards', 'rewardWeightings', ...
    'responsibilities', contextFeatures.outputName, modelLearner.outputName);


%%

newData = dataManager.getDataObject(10);


sampler.numSamples = numSamples;
sampler.setParallelSampling(true);

evaluationCriterion = Experiments.EvaluationCriterion();
learningScenario = LearningScenario.LearningScenario(dataManager, evaluationCriterion, sampler);

learningScenario.addInitialLearner(initMMLearner);

learningScenario.addLearner(kernelBandwidthLearner);
learningScenario.addLearner(modelLearner);
learningScenario.addLearner(repsLearner);

respPreProcessor = DataPreprocessors.DataProbabilitiesPreprocessor(dataManager, mixtureModel, [], 'computeResponsibilities');
learningScenario.addDataPreprocessor(respPreProcessor, true);

trial = Experiments.Trial('./test/', {}, {}, 1, numIterations , 1);
trial.numIterations = numIterations;

repsLearner.addDefaultCriteria(trial, evaluationCriterion);
evaluator = Evaluator.ReturnEvaluatorNewSamples();
evaluationCriterion.registerEvaluator(evaluator);

% steadySampleEvaluator = Evaluator.ReturnEvaluatorDecisionStages(10, 10, sampler);
% evaluationCriterion.registerEvaluator(steadySampleEvaluator);


plotter = Evaluator.PendulumPlotter(repsLearner, dataManager, contextFeatures.outputName, gatingDist.inputVariables{1}, sampler);
evaluationCriterion.registerEvaluator(plotter);

trial.setprop('PolicyLearner',mixtureModelLearner);
trial.setprop('resetInitialData', false);
trial.setprop('dataManager', dataManager);



           
evaluationCriterion.addSaveDataEntry('returns');
evaluationCriterion.addSaveDataEntry('states');
evaluationCriterion.addSaveDataEntry('actions');
evaluationCriterion.addSaveDataEntry('rewards');
evaluationCriterion.addSaveDataEntry('Weights');
evaluationCriterion.addSaveDataEntry('Tau');
evaluationCriterion.addSaveDataEntry('referencePos');
evaluationCriterion.addSaveDataEntry('parameters');
evaluationCriterion.addSaveDataEntry('contexts');
evaluationCriterion.addSaveDataEntry('rewardEval');


learningScenario.learnScenario(trial);

data = dataManager.getDataObject(0);
data.copyValuesFromDataStructure(trial.data)
 

figure
plot(trial.avgReturn);
