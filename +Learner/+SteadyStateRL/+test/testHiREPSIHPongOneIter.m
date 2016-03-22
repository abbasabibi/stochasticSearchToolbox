clear variables;
close all;
Common.clearClasses;
addpath Helper/

numOptions  = 2;


settings = Common.Settings();
settings.setProperty('numOptions',numOptions);
settings.setProperty('epsilonOption',1);
settings.setProperty('initSigmaParameters',0.3);

settings.setProperty('InitialStateDistributionMinRange', [-1 -1 -1 0.1 0]);
settings.setProperty('InitialStateDistributionMaxRange', [1 1 1 1 0]);

settings.setProperty('numDecisionSteps', 2);

settings.setProperty('InitialStateDistributionType', 'Uniform');


% settings.setProperty('maxSamplesEpisodes', 200);
settings.setProperty('maxSamples', 200);
settings.setProperty('resetProbDecisionSteps', 0.2);

settings.setProperty('softMaxRegressionToleranceF', 1e-12);

% settings for the initial context distribution (which is startPos and
% startVel)

settings.setProperty('InitialContextDistributionWidth', 1.0);
settings.setProperty('InitialContextDistributionType', 'Uniform');



sampler             = Sampler.EpisodeWithDecisionStagesSampler();
dataManager         = sampler.getEpisodeDataManager();


sampler.stageSampler.setIsActiveSampler(Sampler.IsActiveStepSampler.IsActiveFixedGamma(dataManager, 'decisionSteps'));


controller          = TrajectoryGenerators.TrajectoryTracker.ConstantTrajectoryTracker(dataManager, 2);

%dataManager.addDataEntryForDepth(2, 'contexts', 2*numJoints);
dataManager.addDataEntryForDepth(2, 'options', 1, 1, numOptions);


environment         = Environments.Pong.Pong(sampler, 60, 20);
initialStateSampler = Sampler.InitialSampler.InitialStateSamplerStandardForActions(sampler);
% initialStateSampler = Sampler.InitialSampler.InitialStateSamplerStandardForActions(environment);

contextSampler      = Sampler.InitialSampler.InitialContextSamplerStandard(sampler);
initialStateSampler.setInitStateFromContext(true); %Set this to false to try fake settings 
endStageSampler     = Sampler.test.EnvironmentStageTest(dataManager); %Change stuff in here

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
dataManager.setRange('contexts', [-2 environment.field.ballInitHeight -0.5 -1 0], ...
    [2 environment.field.ballInitHeight 0.5 -1 0]);


squaredFeatures     = FeatureGenerators.SquaredFeatures(dataManager, 'contexts', 1:4, true);
nextSquaredFeatures = FeatureGenerators.SquaredFeatures(dataManager, 'nextContexts', 1:4, true);
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


sampler.stageSampler.setParameterPolicy(mixtureModel);

% sampler.stageSampler.addSamplerFunctionToPool('ActionPolicy', 'getReferenceTrajectory', linTraj);

% sampler.stageSampler.setRewardFunction(rewardFunction);
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

sampler.numSamples = 3;
sampler.setParallelSampling(false);

data = dataManager.getDataObject();
data.printDataAliases

environment.field.enablePlotting = true;

sampler.createSamples(data);

figure()
clf
subplot(2,1,1)
hold on
for i =1 :  data.dataStructure.numElements
    pos = data.getDataEntry('states', i, :) ;
    pos = pos(:,1:2);
    plot(pos(:,1),pos(:,2), '*')
end