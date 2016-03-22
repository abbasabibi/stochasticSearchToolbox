clear variables;
close all;
Common.clearClasses;
addpath Helper/

numOptions          = 2;
numSamples          = 50;
numMaxSamples       = 50;
numSizeReferenceSet = 100;
numBricks           = 5;
numIterations       = 30;

settings = Common.Settings();
settings.setProperty('numOptions',numOptions);
settings.setProperty('epsilonOption',1);
settings.setProperty('initSigmaParameters',0.3);

% settings.setProperty('InitialStateDistributionMinRange', [-1 -1 -1 0.1 0 -50]);
% settings.setProperty('InitialStateDistributionMaxRange', [1 1 1 1 0 -50]);

settings.setProperty('numDecisionSteps', 2);

settings.setProperty('InitialStateDistributionType', 'Uniform');


% settings.setProperty('maxSamplesEpisodes', 200);
settings.setProperty('resetProbDecisionSteps', 0.3);

settings.setProperty('softMaxRegressionToleranceF', 1e-12);

% settings for the initial context distribution (which is startPos and
% startVel)

settings.setProperty('InitialContextDistributionWidth', 1.0);
settings.setProperty('InitialContextDistributionType', 'Uniform');

settings.setProperty('numSamplesEpisode', numSamples);
settings.setProperty('maxSamples', numMaxSamples);
settings.setProperty('maxSizeReferenceSet', numSizeReferenceSet);

settings.setProperty('numInitialSamplesEpisodes', numMaxSamples);

settings.setProperty('doKMeansInit', false);

sampler             = Sampler.EpisodeWithDecisionStagesSampler();
dataManager         = sampler.getEpisodeDataManager();


sampler.stageSampler.setIsActiveSampler(Sampler.IsActiveStepSampler.IsActiveFixedGamma(dataManager, 'decisionSteps'));


controller          = TrajectoryGenerators.TrajectoryTracker.ConstantTrajectoryTracker(dataManager, 2);

%dataManager.addDataEntryForDepth(2, 'contexts', 2*numJoints);
dataManager.addDataEntryForDepth(2, 'options', 1, 1, numOptions);


environment         = Environments.Pong.Breakout(sampler, 60, 20, numBricks);
initialStateSampler = Sampler.InitialSampler.InitialStateSamplerStandardForActions(sampler);
% initialStateSampler = Sampler.InitialSampler.InitialStateSamplerStandardForActions(environment);

contextSampler      = Sampler.InitialSampler.InitialContextSamplerStandard(sampler);
initialStateSampler.setInitStateFromContext(true); %Set this to false to try fake settings 
% endStageSampler     = Sampler.test.EnvironmentStageTest(dataManager); %Change stuff in here
endStageSampler     = Sampler.test.TransitionContextSampler(dataManager, [], contextSampler); %Change stuff in here

sampler.setTransitionFunction(environment);
sampler.setInitialStateSampler(initialStateSampler);
sampler.setContextSampler(contextSampler);
sampler.stageSampler.setEndStateTransitionSampler(endStageSampler);
sampler.stageSampler.stepSampler.setIsActiveSampler(environment);

% goalPos         = 0;
% rewardFunction  = RewardFunctions.TimeDependent.GoalRewardFunction(dataManager, goalPos);

returnSampler   = RewardFunctions.ReturnForEpisode.PongReturn(dataManager);

% parameterPolicy = Distributions.Gaussian.GaussianParameterPolicy(dataManager);
% parameterPolicyLearner = Learner.SupervisedLearner.LinearGaussianMLLearner(dataManager, parameterPolicy);

sampler.initObject();
% dataManager.setRange('contexts', [-10 environment.field.ballInitHeight -1 -1 0 -20], ...
%     [10 environment.field.ballInitHeight 1 -1 0 20]); %[posX, posY, velX, velY, reward, opponentX]

% dataManager.setRange('contexts', [-5 environment.field.ballInitHeight -0.3 -1 0 -20], ...
%     [5 environment.field.ballInitHeight 0.3 -1 0 20]); %[posX, posY, velX, velY, reward, opponentX]

% dataManager.setRange('contexts', [-20 environment.field.ballInitHeight -2 -1 0 -20], ...
%     [20 environment.field.ballInitHeight 2 -1 0 20]); %[posX, posY, velX, velY, reward, opponentX

% dataManager.setRange('contexts', [-20 environment.field.ballInitHeight -pi/2 -1 0 -20], ...
%     [20 environment.field.ballInitHeight pi/2 -1 0 20]); %[posX, posY, velX, velY, reward, opponentX

% dataManager.addDataAliasForDepth(2,'contextsForFeaturesOnlyBricks', 'contexts', [6 : 5+numBricks]);
% dataManager.addDataAliasForDepth(2,'contextsForFeaturesNoBricks', 'contexts', [1,3]);
dataManager.addDataAliasForDepth(2,'contextsForFeatures', 'contexts', [1,3, 6 : 5+numBricks]);
dataManager.addDataAliasForDepth(2,'nextContextsForFeatures', 'nextContexts', [1,3, 6 : 5+numBricks]);
dataManager.finalizeDataManager();

squaredFeatures     = FeatureGenerators.SquaredFeatures(dataManager, 'contextsForFeatures', [1,2], true);
dataManager.addDataAliasForDepth(2,'gatingFeatures', {squaredFeatures.outputName, 'contexts'}, {':', [6 : 5+numBricks]});

inputFeatureDim     = dataManager.getNumDimensions('contextsForFeatures');

contextKernel       = Kernels.ExponentialQuadraticKernel(dataManager, inputFeatureDim, 'contextKernel', false);
contextFeatures     = Kernels.KernelBasedFeatureGenerator(dataManager, contextKernel, {'contextsForFeatures'}, '~contextFeatures');
nextContextFeatures = Kernels.KernelBasedFeatureGenerator(dataManager, contextKernel, {'nextContextsForFeatures'}, '~nextContextFeatures');

nextContextFeatures.setExternalReferenceSet(contextFeatures);

referenceSetLearner = Kernels.Learner.RandomKernelReferenceSetLearner(dataManager, contextFeatures);
kernelBandwidthLearner = Kernels.Learner.MedianBandwidthSelector(dataManager, contextKernel, referenceSetLearner, contextFeatures);

gaussianDist        = Distributions.Gaussian.GaussianLinearInFeatures(dataManager, 'parameters', 'contextsForFeatures', 'ActionPolicy');

optionLearner       = Learner.SupervisedLearner.LinearGaussianMLLearner(dataManager, gaussianDist);
optionInitializer   = @Distributions.Gaussian.GaussianLinearInFeatures;
gatingDist          = Distributions.Discrete.SoftMaxDistribution(dataManager, 'options', 'gatingFeatures', 'Gating');
gatingLearner       = Learner.ClassificationLearner.MultiClassLogisticRegressionLearner(dataManager, gatingDist, true); %false or true???
mixtureModel        = Distributions.MixtureModel.MixtureModel.createParameterPolicy(...
    dataManager, gatingDist, optionInitializer, 'parameters', 'contextsForFeatures', 'options');
mixtureModelLearner = Learner.SupervisedLearner.MixtureModelLearner(dataManager, mixtureModel, optionLearner, gatingLearner, 'outputResponsibilities');

mixtureModelLearner.debugStateIndices   = 2;
mixtureModel.baseInputVariable          = 'contextsForFeatures';
% gatingDist.setThetaAllItems(rand(dataManager.getMaxRange('options'),dataManager.getNumDimensions(squaredFeatures.outputName)) -0.5);

initMMLearner         = Learner.SupervisedLearner.InitMMLearner(dataManager, mixtureModelLearner);

mixtureModel.initObject();
gatingDist.initObject();

dataManager.finalizeDataManager();


modelLearner    = Learner.ModelLearner.SampleModelLearner(dataManager, ':', contextFeatures, [], [], sampler.stageSampler.isActiveSampler.resetProbName);
repsLearner     = Learner.SteadyStateRL.HiREPSIter(dataManager, mixtureModelLearner, 'returns', 'returnWeightings', ...
    'responsibilities', contextFeatures.outputName, modelLearner.outputName);


sampler.stageSampler.setParameterPolicy(mixtureModel);

% sampler.stageSampler.addSamplerFunctionToPool('ActionPolicy', 'getReferenceTrajectory', linTraj);

% sampler.stageSampler.setRewardFunction(rewardFunction);
sampler.stageSampler.setReturnFunction(returnSampler);  % Set this in conf file

sampler.stageSampler.setActionPolicy(controller);


mixtureModel.initObject();
repsLearner.initObject();
sampler.initObject();

dataManager.finalizeDataManager();



% %%%%%%%%%%%%%%%%%%%%%%%%%%
% numInitStates   = 1e3;
% 
% initContexts    = bsxfun(@times, (rand(numInitStates, dataManager.getNumDimensions('contexts'))-0.5) , dataManager.getRange('contexts'));
% 
% initParams      = bsxfun(@times, (rand(numInitStates, dataManager.getNumDimensions('parameters'))) , dataManager.getRange('parameters'));
% initParams      = bsxfun(@plus, initParams, dataManager.getMinRange('parameters') );
% initContexts    = bsxfun(@times, (rand(numInitStates, dataManager.getNumDimensions('contextsForFeatures'))-0.5) , 1e1);
% subManager      = dataManager.getDataManagerForDepth( dataManager.getDataEntryDepth(mixtureModel.outputVariable) );
% initData        = subManager.getDataObject(numInitStates);
% initData.setDataEntry('contextsForFeatures',initContexts);
% initData.setDataEntry('parameters',initParams);
% initData.setDataEntry(mixtureModelLearner.weightName{1}, ones(numInitStates,1));
% 
% 
% KMeansLearner   = Learner.ClassificationLearner.KMeansLearner(dataManager, mixtureModelLearner, [], [], 'contextsForFeatures');
% KMeansLearner.callDataFunction('learnFunction', initData);
% %%%%%%%%%%%%%%%%%%%%%%%%%%
% 




dataManager.finalizeDataManager();

% sampler.numSamples = 2;
% sampler.setParallelSampling(false);
% 
% data = dataManager.getDataObject();
% data.printDataAliases
% 
% sampler.createSamples(data);



newData = dataManager.getDataObject(10);

% parameterPolicy.initObject();
% repsLearner.initObject();

sampler.numSamples = numSamples;
sampler.setParallelSampling(true);
% 
% sampler.setParallelSampling(false);
% environment.field.enablePlotting = true;

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
trial.setprop('resetInitialData', false);
trial.rngState = 1;

repsLearner.addDefaultCriteria(trial, evaluationCriterion);
evaluator = Evaluator.ReturnEvaluatorNewSamples();
evaluationCriterion.registerEvaluator(evaluator);

plotter = Evaluator.PongPlotter(environment);
evaluationCriterion.registerEvaluator(plotter);

trial.setprop('PolicyLearner',mixtureModelLearner);
trial.setprop('dataManager', dataManager);

           
evaluationCriterion.addSaveDataEntry('returns');
evaluationCriterion.addSaveDataEntry('states');
evaluationCriterion.addSaveDataEntry('actions');


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


% states = iter00005.data.decisionStages(1).steps.states;
% plot(states(:,1),states(:,2), '*')
