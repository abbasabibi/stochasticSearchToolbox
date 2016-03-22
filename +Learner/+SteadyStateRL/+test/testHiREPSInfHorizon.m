clear variables;
close all;
Common.clearClasses;
numBasis    = 5;
numJoints   = 3;
numOptions  = 2;


settings = Common.Settings();
settings.setProperty('numOptions',numOptions);
settings.setProperty('epsilonOption',1);

settings.setProperty('useTau', 1);
settings.setProperty('numBasis', numBasis);
settings.setProperty('numTimeSteps', 100);
settings.setProperty('useWeights', 1);
settings.setProperty('InitialStateDistributionMinRange', [0.0 0 0 0 0 0]);
settings.setProperty('InitialStateDistributionMaxRange', [0.0 0 0 0 0 0]);
settings.setProperty('InitialStateDistributionMaxRange', [0.0 0 0 0 0 0]);
settings.setProperty('numDecisionSteps', 2);

% settings.setProperty('maxSamplesEpisodes', 200);
settings.setProperty('maxSamples', 200);
settings.setProperty('resetProbDecisionSteps', 0.3);

settings.setProperty('softMaxRegressionToleranceF', 1e-12);


sampler = Sampler.EpisodeWithDecisionStagesSampler();
dataManager = sampler.getEpisodeDataManager();

sampler.stageSampler.setIsActiveSampler(Sampler.IsActiveStepSampler.IsActiveFixedGamma(dataManager, 'decisionSteps'));

%sampler.stageSampler.setIsActiveSampler(Sampler.IsActiveStepSampler.IsActiveFixedGamma(dataManager, 'decisionSteps'));


dataManager.addDataEntryForDepth(2, 'contexts', 2*numJoints);
dataManager.addDataEntryForDepth(2, 'options', 1, 1, numOptions);


environment         = Environments.DynamicalSystems.LinearSystem(sampler, numJoints);
initialStateSampler = Sampler.InitialSampler.InitialStateSamplerStandard(sampler);
initialStateSampler.setInitStateFromContext(true); %Set this to false to try fake settings
endStageSampler     = Sampler.test.EnvironmentStageTest(dataManager);

sampler.setTransitionFunction(environment);
sampler.setInitialStateSampler(initialStateSampler);
sampler.stageSampler.setEndStateTransitionSampler(endStageSampler);

phaseGenerator = TrajectoryGenerators.PhaseGenerators.DMPPhaseGenerator(dataManager);
basisGenerator = TrajectoryGenerators.BasisFunctions.DMPBasisGenerator(dataManager,phaseGenerator);

controller = TrajectoryGenerators.TrajectoryTracker.LinearTrajectoryTracker(dataManager, numJoints);


viaPoint.times   = [40, 100]; 
viaPoint.factors = repmat([1e4, 1e4, 0, 0], length(viaPoint.times), 1);
viaPoint.points{1}  = [1.0, 1.0, 0.0, 0.0]; %in task space: [pos pos vel vel]
viaPoint.points{2}  = [numJoints, 0.0, 0.0, 0.0];                
viaPoint.uFactor = 0.5 * 10^0;

planarKinematics    = Environments.Misc.PlanarForwardKinematics(dataManager, numJoints);
rewardFunction      = RewardFunctions.TimeDependent.TaskSpaceViaPointRewardFunction(dataManager, planarKinematics, viaPoint.times,viaPoint.points,viaPoint.factors,viaPoint.uFactor);
returnSampler       = RewardFunctions.ReturnForEpisode.ReturnSummedReward(dataManager);

linTraj = TrajectoryGenerators.DynamicMovementPrimitives(dataManager,numJoints);

% parameterPolicy = Distributions.Gaussian.GaussianParameterPolicy(dataManager);
% parameterPolicyLearner = Learner.SupervisedLearner.LinearGaussianMLLearner(dataManager, parameterPolicy);

sampler.initObject();

squaredFeatures     = FeatureGenerators.SquaredFeatures(dataManager, 'contexts', 1, true);
nextSquaredFeatures = FeatureGenerators.SquaredFeatures(dataManager, 'nextContexts', 1, true)
gaussianDist        = Distributions.Gaussian.GaussianLinearInFeatures(dataManager, 'parameters', 'contexts', 'ActionPolicy');

optionLearner       = Learner.SupervisedLearner.LinearGaussianMLLearner(dataManager, gaussianDist);
optionInitializer   = @Distributions.Gaussian.GaussianLinearInFeatures;
gatingDist          = Distributions.Discrete.SoftMaxDistribution(dataManager, 'options', squaredFeatures.outputName, 'Gating');
gatingLearner       = Learner.ClassificationLearner.MultiClassLogisticRegressionLearner(dataManager, gatingDist, true); %false or true???
mixtureModel        = Distributions.MixtureModel.MixtureModel.createParameterPolicy(...
    dataManager, gatingDist, optionInitializer, 'parameters', 'contextsSquared', 'options');
mixtureModelLearner = Learner.SupervisedLearner.MixtureModelLearner(dataManager, mixtureModel, optionLearner, gatingLearner, 'outputResponsibilities');

mixtureModelLearner.debugStateIndices   = 2;
mixtureModel.baseInputVariable          = 'contexts';
% gatingDist.setThetaAllItems(rand(dataManager.getMaxRange('options'),dataManager.getNumDimensions(squaredFeatures.outputName)) -0.5);

mixtureModel.initObject();
gatingDist.initObject();

dataManager.finalizeDataManager();




modelLearner    = Learner.ModelLearner.SampleModelLearner(dataManager, ':', squaredFeatures, [], [], sampler.stageSampler.isActiveSampler.resetProbName);
repsLearner     = Learner.SteadyStateRL.HiREPSIter(dataManager, mixtureModelLearner, 'returns', 'returnWeightings', ...
    'responsibilities', 'contextsSquared', 'contextsSquaredSampleModel');

% repsLearner = Learner.EpisodicRL.EpisodicREPS(dataManager, parameterPolicyLearner, 'returns', 'returnWeightings');


sampler.stageSampler.setParameterPolicy(mixtureModel);

sampler.stageSampler.addSamplerFunctionToPool('ParameterPolicy', 'generatePhase', phaseGenerator);
sampler.stageSampler.addSamplerFunctionToPool('ParameterPolicy', 'generateBasis', basisGenerator);
sampler.stageSampler.addSamplerFunctionToPool('ParameterPolicy', 'getReferenceTrajectory', linTraj);

sampler.stageSampler.setRewardFunction(rewardFunction);
sampler.stageSampler.setReturnFunction(returnSampler);

sampler.stageSampler.setActionPolicy(controller);


mixtureModel.initObject();
repsLearner.initObject();
sampler.initObject();

dataManager.finalizeDataManager();

%%%%%%%%%%%%%%%%%%%%%%%%%%%
numInitStates   = 1e3;

initParams      = bsxfun(@times, (rand(numInitStates, dataManager.getNumDimensions('parameters'))-0.5) , dataManager.getRange('parameters'));
initContexts    = bsxfun(@times, (rand(numInitStates, dataManager.getNumDimensions('contexts'))-0.5) , dataManager.getRange('contexts'));
subManager      = dataManager.getDataManagerForDepth( dataManager.getDataEntryDepth(mixtureModel.outputVariable) );
initData        = subManager.getDataObject(numInitStates);
initData.setDataEntry('contexts',initContexts);
initData.setDataEntry('parameters',initParams);
initData.setDataEntry(mixtureModelLearner.weightName{1}, ones(numInitStates,1));


KMeansLearner   = Learner.ClassificationLearner.KMeansLearner(dataManager, mixtureModelLearner, [], [], 'contexts');
KMeansLearner.callDataFunction('learnFunction', initData);
%%%%%%%%%%%%%%%%%%%%%%%%%%%




newData = dataManager.getDataObject(10);

% parameterPolicy.initObject();
% repsLearner.initObject();

sampler.numSamples = 10;
sampler.setParallelSampling(true);

evaluationCriterion = Experiments.EvaluationCriterion();
learningScenario = LearningScenario.LearningScenario(dataManager, evaluationCriterion, sampler);

learningScenario.addLearner(modelLearner);
learningScenario.addLearner(repsLearner);
respPreProcessor = DataPreprocessors.DataProbabilitiesPreprocessor(dataManager, mixtureModel, [], 'computeResponsibilities');
learningScenario.addDataPreprocessor(respPreProcessor, true);

trial = Experiments.Trial('./test/', {}, {}, 1, 40, 1);
repsLearner.addDefaultCriteria(trial, evaluationCriterion);
evaluator = Evaluator.ReturnEvaluatorNewSamples();
evaluationCriterion.registerEvaluator(evaluator);
trial.setprop('DMPs', linTraj);
trial.setprop('PolicyLearner',mixtureModelLearner);

           
evaluationCriterion.addSaveDataEntry('returns');
evaluationCriterion.addSaveDataEntry('states');
evaluationCriterion.addSaveDataEntry('actions');
evaluationCriterion.addSaveDataEntry('rewards');
evaluationCriterion.addSaveDataEntry('Weights');
evaluationCriterion.addSaveDataEntry('Tau');
evaluationCriterion.addSaveDataEntry('referencePos');

learningScenario.learnScenario(trial);

% data = dataManager.getDataObject(0);
% data.copyValuesFromDataStructure(trial.data)
% 
% Plotter.PlotterData.plotTrajectories(data, 'jointPositions');
% Plotter.PlotterData.plotTrajectories(data, 'endEffPositions');
% Plotter.PlotterEvaluations.plotData(data,'returns')
% figure
% plot(data.dataStructure.returns)
plot(trial.avgReturn);
