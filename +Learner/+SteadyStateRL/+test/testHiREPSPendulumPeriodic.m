clear variables;
close all;
Common.clearClasses();
addpath Helper/
Common.clearClasses;


numOptions          = 10;
numSamples          = 20;
numMaxSamples       = 5*numSamples;
numSizeReferenceSet = 300;
numIterations       = 100;

epsilonAction       = 1;
epsilonOption       = 1;

dt                  = 0.01;
dtBase              = 0.05;
numStepsPerDecision = 5;
restartProb         = 0.02 * dt/dtBase * numStepsPerDecision;

doKMeans            = true;
keepOptionsShape    = false;


settings = Common.Settings();
settings.setProperty('numOptions',numOptions);
settings.setProperty('epsilonAction', epsilonAction);
settings.setProperty('epsilonOption',epsilonOption);
settings.setProperty('initSigmaParameters',0.5);



settings.setProperty('dt', dt);
settings.setProperty('numStepsPerDecision', numStepsPerDecision);
settings.setProperty('resetProbDecisionSteps', restartProb);

settings.setProperty('softMaxRegressionToleranceF', 1e-12);


settings.setProperty('InitialContextDistributionWidth', 1);
settings.setProperty('InitialContextDistributionType', 'Uniform');

settings.setProperty('numSamplesEpisode', numSamples);
settings.setProperty('maxSamples', numMaxSamples);
settings.setProperty('maxSizeReferenceSet', numSizeReferenceSet);

settings.setProperty('numInitialSamplesEpisodes', numMaxSamples);
settings.setProperty('kernelMedianBandwidthFactor', 0.5);


settings.setProperty('doKMeansInit', doKMeans);
settings.setProperty('keepOptionsShape', keepOptionsShape);

settings.setProperty('debugPlottingMM', true);
settings.setProperty('periodicRange', [-pi, pi]);




sampler             = Sampler.EpisodeWithDecisionStagesSampler();
dataManager         = sampler.getEpisodeDataManager();

sampler.stageSampler.setIsActiveSampler(Sampler.IsActiveStepSampler.IsActiveFixedGamma(dataManager, 'decisionSteps'));


%sampler.stageSampler.setIsActiveSampler(Sampler.IsActiveStepSampler.IsActiveFixedGamma(dataManager, 'decisionSteps'));



% dataManager.addDataEntryForDepth(2, 'contexts', 2*numJoints);
dataManager.addDataEntryForDepth(2, 'options', 1, 1, numOptions);




environment     = Environments.DynamicalSystems.Pendulum(sampler, true); %non periodic
environment.initObject();


controller          = TrajectoryGenerators.TrajectoryTracker.GoalAttractor(dataManager, 1);

initialStateSampler = Sampler.InitialSampler.InitialStateSamplerStandard(sampler);
contextSampler      = Sampler.InitialSampler.InitialContextSamplerStandard(sampler);
initialStateSampler.setInitStateFromContext(true); %Set this to false to try fake settings 

endStageSampler     = Sampler.test.EnvironmentStageTest(controller); %Change stuff in here


sampler.setTransitionFunction(environment);
sampler.setInitialStateSampler(initialStateSampler);
sampler.setContextSampler(contextSampler);
sampler.stageSampler.setEndStateTransitionSampler(endStageSampler);
sampler.stageSampler.stepSampler.setIsActiveSampler(controller);

actionCost = 0;
stateCost = [10 0; 0 0];
rewardFunction = RewardFunctions.QuadraticRewardFunctionSwingUpSimple(dataManager); %non multimodal reward
rewardFunction.setStateActionCosts(stateCost, actionCost);
returnSampler       = RewardFunctions.ReturnForEpisode.ReturnAvgReward(dataManager);




dataManager.finalizeDataManager();
% minRangeContexts = [- pi, -30]; 
% maxRangeContexts = [+ pi, 30];
minRangeContexts = [pi - pi/4, -5]; 
maxRangeContexts = [pi + pi/4, +5];
maxRange = 3;
dataManager.setRange('contexts', minRangeContexts, maxRangeContexts);
dataManager.setRange('parameters', -maxRange, maxRange);

sampler.initObject();

%%
dataManager.finalizeDataManager();

squaredFeatures     = FeatureGenerators.SquaredFeatures(dataManager, 'contexts', ':', true);

inputFeatureDim     = dataManager.getNumDimensions('contexts');

contextKernel       = Kernels.Kernel.createKernelSQEPeriodic(dataManager, 'contexts');
contextFeatures     = Kernels.KernelBasedFeatureGenerator(dataManager, contextKernel, {'contexts'}, '~contextFeatures');
nextContextFeatures = Kernels.KernelBasedFeatureGenerator(dataManager, contextKernel, {'nextContexts'}, '~nextContextFeatures');

nextContextFeatures.setExternalReferenceSet(contextFeatures);

referenceSetLearner = Kernels.Learner.RandomKernelReferenceSetLearner(dataManager, contextFeatures);
kernelBandwidthLearner = Kernels.Learner.MedianBandwidthSelector(dataManager, contextKernel, referenceSetLearner, contextFeatures);

sampler.initObject();
%%
gaussianDist        = Distributions.Gaussian.GaussianLinearInFeatures(dataManager, 'parameters', 'contexts', 'ActionPolicy');

optionLearner       = Learner.SupervisedLearner.LinearGaussianMLLearner(dataManager, gaussianDist);
optionInitializer   = @Distributions.Gaussian.GaussianLinearInFeatures;
gatingDist          = Distributions.Discrete.SoftMaxDistribution(dataManager, 'options', squaredFeatures.outputName, 'Gating');
gatingLearner       = Learner.ClassificationLearner.MultiClassLogisticRegressionLearner(dataManager, gatingDist, true); %false or true???
mixtureModel        = Distributions.MixtureModel.MixtureModel.createParameterPolicy(...
    dataManager, gatingDist, optionInitializer, 'parameters', 'contexts', 'options');
mixtureModelLearner = Learner.SupervisedLearner.MixtureModelLearner(dataManager, mixtureModel, optionLearner, gatingLearner, 'outputResponsibilities');

mixtureModelLearner.debugActionIndices   = [];
mixtureModel.baseInputVariable          = 'contexts';
% gatingDist.setThetaAllItems(rand(dataManager.getMaxRange('options'),dataManager.getNumDimensions(squaredFeatures.outputName)) -0.5);

initMMLearner         = Learner.SupervisedLearner.InitMMLearner(dataManager, mixtureModelLearner);

mixtureModel.initObject();
gatingDist.initObject();

dataManager.finalizeDataManager();


modelLearner    = Learner.ModelLearner.SampleModelLearner(dataManager, ':', contextFeatures, [], [], sampler.stageSampler.isActiveSampler.resetProbName);
repsLearner     = Learner.SteadyStateRL.HiREPSIter(dataManager, mixtureModelLearner, 'returns', 'returnWeightings', ...
    'responsibilities', contextFeatures.outputName, modelLearner.outputName);



sampler.stageSampler.setParameterPolicy(mixtureModel);

% sampler.stageSampler.addSamplerFunctionToPool('ParameterPolicy', 'sampleInitState', initialStateSampler, -1);
% sampler.stageSampler.addSamplerFunctionToPool('ParameterPolicy', 'generatePhase', phaseGenerator);
% sampler.stageSampler.addSamplerFunctionToPool('ParameterPolicy', 'generateBasis', basisGenerator);
% sampler.stageSampler.addSamplerFunctionToPool('ParameterPolicy', 'getReferenceTrajectory', linTraj);

sampler.stageSampler.setRewardFunction(rewardFunction);
sampler.stageSampler.setReturnFunction(returnSampler);

sampler.stageSampler.setActionPolicy(controller);


mixtureModel.initObject();
repsLearner.initObject();
sampler.initObject();

dataManager.finalizeDataManager();



% %%%%%%%%%%%%%%%%%%%%%%%%%%%
% numInitStates   = 1e3;
% 
% % initContexts    = bsxfun(@times, (rand(numInitStates, dataManager.getNumDimensions('contexts'))-0.5) , dataManager.getRange('contexts'));
% 
% initParams      = bsxfun(@times, (rand(numInitStates, dataManager.getNumDimensions('parameters'))) , dataManager.getRange('parameters'));
% initParams      = bsxfun(@plus, initParams, dataManager.getMinRange('parameters') );
% initContexts    = bsxfun(@times, (rand(numInitStates, dataManager.getNumDimensions('contexts'))-0.5) , 1e1);
% subManager      = dataManager.getDataManagerForDepth( dataManager.getDataEntryDepth(mixtureModel.outputVariable) );
% initData        = subManager.getDataObject(numInitStates);
% initData.setDataEntry('contexts',initContexts);
% initData.setDataEntry('parameters',initParams);
% initData.setDataEntry(mixtureModelLearner.weightName{1}, ones(numInitStates,1));
% 
% 
% KMeansLearner   = Learner.ClassificationLearner.KMeansLearner(dataManager, mixtureModelLearner, [], [], 'contexts');
% KMeansLearner.callDataFunction('learnFunction', initData);
% %%%%%%%%%%%%%%%%%%%%%%%%%%%




newData = dataManager.getDataObject(10);

% parameterPolicy.initObject();
% repsLearner.initObject();

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


plotter = Evaluator.PendulumPlotter(repsLearner, dataManager, contextFeatures.outputName,  'contextsSquared', sampler);
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
 
% Plotter.PlotterData.plotTrajectories(data, 'jointPositions');


% the data you use here for the Plotter.PlotterEvaluations is not the same
% data as used from the trial, sorry;)
% Plotter.PlotterEvaluations.plotData(data,'returns')
% figure
% plot(data.dataStructure.returns)
figure
plot(trial.avgReturn);
