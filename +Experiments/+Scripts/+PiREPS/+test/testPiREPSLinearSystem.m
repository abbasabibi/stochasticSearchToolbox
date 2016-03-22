clear variables;
close all;
Common.clearClasses;
numBasis = 5;
numJoints = 2;

settings = Common.Settings();
settings.setProperty('numTimeSteps', 200);
settings.setProperty('dt', 0.005);
settings.setProperty('InitialStateDistributionMinRange', [0 0 0 0]);
settings.setProperty('InitialStateDistributionMaxRange', [0 0 0 0]);
settings.setProperty('numSamplesEpisodes', 100);

settings.setProperty('InitialStateDistributionType', 'Uniform');
settings.setProperty('usePeriodicStateSpace', false);
settings.setProperty('Noise_std', 0.05);

sampler = Sampler.EpisodeWithStepsSampler();

dataManager = sampler.getEpisodeDataManager();
sampler.getStepSampler.setIsActiveSampler(Sampler.IsActiveStepSampler.IsActiveNumSteps(dataManager));

%environment = Environments.DynamicalSystems.LinearSystem(sampler, numJoints);
environment = Environments.DynamicalSystems.DoubleLink(sampler);


dataManager.addDataEntry('contexts', dataManager.getNumDimensions('states'));
dataManager.setRange('contexts', [0 0 0 0], [0 0 0 0]);

initialContextSampler = Sampler.InitialSampler.InitialContextSamplerStandard(sampler);
initialStateSampler = Sampler.InitialSampler.InitialStateSamplerStandard(sampler);
initialStateSampler.setInitStateFromContext(true); 

contextFeatures = FeatureGenerators.SquaredFeatures(dataManager, 'contexts');

sampler.setTransitionFunction(environment);
sampler.setInitialStateSampler(initialStateSampler);
sampler.setContextSampler(initialContextSampler);

viaPoint.times   = [180:200];
viaPoint.factors = repmat([1e4, 1e3, 1e4, 1e3], length(viaPoint.times), 1);
for i = 1:length(viaPoint.factors)
    viaPoint.points{i}  = [0.0, 0.0, 0.0, 0.0];
end
viaPoint.uFactor = 10^-3;

rewardFunction = RewardFunctions.TimeDependent.ViaPointRewardFunction(dataManager, viaPoint.times,viaPoint.points,viaPoint.factors,viaPoint.uFactor);
rewardFunction.useSeperateStateActionReward(true);
returnSampler = RewardFunctions.ReturnForEpisode.ReturnSummedReward(dataManager);

actionPolicyPerTimeStep = @Distributions.Gaussian.GaussianActionPolicy;
actionPolicy = Distributions.TimeDependent.ComposedTimeDependentPolicy(dataManager, actionPolicyPerTimeStep);

policyLearnerPerTimeStep = @Learner.SupervisedLearner.LinearGaussianMLLearner;
policyLearner = Learner.SupervisedLearner.TimeDependentLearner(dataManager, actionPolicy, policyLearnerPerTimeStep);
            
piRepsLearner = Learner.EpisodicRL.EpisodicPIREPSLambda(dataManager, environment, policyLearner, actionPolicy, contextFeatures.outputName);

startDistribution = Distributions.Gaussian.GaussianLinearInFeatures(dataManager, 'contexts', '', 'initStateDistribution');
startDistribution.setBias([0 0 0 0]);
startDistribution.setCovariance(diag([0.001, 0.02, 0.001, 0.02]));

%sampler.setContextSampler(startDistribution, 'sampleFromDistribution');


sampler.setRewardFunction(rewardFunction);
sampler.setReturnFunction(returnSampler);


sampler.setActionPolicy(actionPolicy);

dataManager.finalizeDataManager();
newData = dataManager.getDataObject(10);

actionPolicy.initObject();
piRepsLearner.initObject();

sampler.setParallelSampling(true);

evaluationCriterion = Experiments.EvaluationCriterion();
learningScenario = LearningScenario.LearningScenario(dataManager, evaluationCriterion, sampler);

learningScenario.addLearner(piRepsLearner);

trial = Experiments.Trial('./test/', {}, {}, 1, 50, 1);
trial.dataManager = dataManager;
trial.setprop('transitionFunction', environment);
Experiments.ParameterSettings.PathIntegralRewardSettings.setParametersForTrial(trial);
piRepsLearner.addDefaultCriteria(trial, evaluationCriterion);
evaluator = Evaluator.ReturnEvaluatorNewSamples();
evaluationCriterion.registerEvaluator(evaluator);
           
evaluationCriterion.addSaveDataEntry('returns');

learningScenario.learnScenario(trial);




