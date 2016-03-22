clear variables;
close all;
Common.clearClasses;
addpath Helper/


numBasis    = 3;
numJoints   = 1;
numOptions  = 2;


settings = Common.Settings();
settings.setProperty('numOptions',numOptions);
settings.setProperty('epsilonOption',1);

settings.setProperty('useTau', 0);
settings.setProperty('useGoal', false);
settings.setProperty('numBasis', numBasis);
settings.setProperty('numTimeSteps', 100);
settings.setProperty('useWeights', 1);
settings.setProperty('InitialStateDistributionMinRange', [-1 0]);
settings.setProperty('InitialStateDistributionMaxRange', [1 0]);
settings.setProperty('useStartPos',1); 
settings.setProperty('useStartVel',1); 

settings.setProperty('numDecisionSteps', 2);

settings.setProperty('InitialStateDistributionType', 'Uniform');


% settings.setProperty('maxSamplesEpisodes', 200);
settings.setProperty('maxSamples', 200);
settings.setProperty('resetProbDecisionSteps', 0.3);

settings.setProperty('softMaxRegressionToleranceF', 1e-12);

% settings for the initial context distribution (which is startPos and
% startVel)

settings.setProperty('minStartVel', 0);
settings.setProperty('maxStartVel', 0);

settings.setProperty('minStartPos', -0.5);
settings.setProperty('maxStartPos', 0.5);

settings.setProperty('InitialContextDistributionWidth', 1.0);
settings.setProperty('InitialContextDistributionType', 'Uniform');



sampler             = Sampler.EpisodeWithDecisionStagesSampler();
dataManager         = sampler.getEpisodeDataManager();

sampler.stageSampler.setIsActiveSampler(Sampler.IsActiveStepSampler.IsActiveFixedGamma(dataManager, 'decisionSteps'));

%sampler.stageSampler.setIsActiveSampler(Sampler.IsActiveStepSampler.IsActiveFixedGamma(dataManager, 'decisionSteps'));


%dataManager.addDataEntryForDepth(2, 'contexts', 2*numJoints);
dataManager.addDataEntryForDepth(2, 'options', 1, 1, numOptions);


environment         = Environments.DynamicalSystems.LinearSystem(sampler, numJoints);
initialStateSampler = Sampler.InitialSampler.InitialStateSamplerStandard(sampler);
% initialStateSampler = Sampler.InitialSampler.InitialStateDynamicalSystem(sampler);
contextSampler = Sampler.InitialSampler.InitialContextSamplerStandard(sampler);
initialStateSampler.setInitStateFromContext(true); %Set this to false to try fake settings 
endStageSampler     = Sampler.test.EnvironmentStageTest(dataManager); %Change stuff in here

sampler.setTransitionFunction(environment);
sampler.setInitialStateSampler(initialStateSampler);
sampler.setContextSampler(contextSampler);
sampler.stageSampler.setEndStateTransitionSampler(endStageSampler);

phaseGenerator      = TrajectoryGenerators.PhaseGenerators.DMPPhaseGenerator(dataManager);
basisGenerator      = TrajectoryGenerators.BasisFunctions.DMPBasisGenerator(dataManager,phaseGenerator);
controller          = TrajectoryGenerators.TrajectoryTracker.LinearTrajectoryTracker(dataManager, numJoints);


viaPoint.times      = [10]; 
viaPoint.factors    = repmat([1e4, 1e4], length(viaPoint.times), 1);
viaPoint.points{1}  = [1.0, 0.0]; %in task space: [pos pos vel vel]
viaPoint.uFactor    = 0.5 * 10^0;

linTraj             = TrajectoryGenerators.DynamicMovementPrimitives(dataManager,numJoints);

% planarKinematics    = Environments.Misc.PlanarForwardKinematics(dataManager, numJoints);
rewardFunction      = RewardFunctions.TimeDependent.ViaPointRewardFunction(dataManager, viaPoint.times, ...
    viaPoint.points, viaPoint.factors, viaPoint.uFactor, {'jointPositions', 'jointVelocities'});

returnSampler       = RewardFunctions.ReturnForEpisode.ReturnSummedReward(dataManager);

% parameterPolicy = Distributions.Gaussian.GaussianParameterPolicy(dataManager);
% parameterPolicyLearner = Learner.SupervisedLearner.LinearGaussianMLLearner(dataManager, parameterPolicy);

sampler.initObject();

squaredFeatures     = FeatureGenerators.SquaredFeatures(dataManager, 'contexts', 1, true);
nextSquaredFeatures = FeatureGenerators.SquaredFeatures(dataManager, 'nextContexts', 1, true);
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





dataManager.finalizeDataManager();

sampler.numSamples = 100;
sampler.setParallelSampling(true);

data = dataManager.getDataObject();
data.printDataAliases

sampler.createSamples(data);

figure()
clf
subplot(2,1,1)
hold on
for i =1 :  data.dataStructure.numElements
    plot(data.getDataEntry('jointPositions', i, :))
end
subplot(2,1,2)
hold on
for i =1 :  data.dataStructure.numElements
    plot(data.getDataEntry('referencePos', i, :))
end
