clear variables;
close all;
Common.clearClasses;
numJoints = 2;

%system('rm Ks0.mat');

settings = Common.Settings();
settings.setProperty('numTimeSteps', 250);
settings.setProperty('dt', 0.002);
settings.setProperty('InitialStateDistributionMinRange', [0 0 0 0]);
settings.setProperty('InitialStateDistributionMaxRange', [0 0 0 0]);
settings.setProperty('numSamplesEpisodes', 100);
settings.setProperty('maxSamples',100);

settings.setProperty('InitialStateDistributionType', 'Uniform');
settings.setProperty('usePeriodicStateSpace', false);
settings.setProperty('Noise_std', 0.5);

settings.setProperty('numBasis', 30);   % tune
settings.setProperty('widthFactorBasis', 1);  % tune
settings.setProperty('initSigmaWeights', 0.5);
settings.setProperty('initSigmaWeightsMu', 0.0);
settings.setProperty('linearFeedbackNoiseRegularization', 10^-8); % tune
settings.setProperty('PathIntegralCostActionMultiplier', 0.01);
settings.setProperty('alphaL2ThetaPunishment', 0);

sampler = Sampler.EpisodeWithStepsSampler();

dataManager = sampler.getEpisodeDataManager();
sampler.getStepSampler.setIsActiveSampler(Sampler.IsActiveStepSampler.IsActiveNumSteps(dataManager));

environment = Environments.DynamicalSystems.LinearSystem(sampler, numJoints);
dataManager.setRange('actions', -ones(1,2) * 500, ones(1,2) * 500);

dataManager.addDataEntry('contexts', dataManager.getNumDimensions('states'));
dataManager.setRange('contexts', [0 0 0 0], [0 0 0 0]);

initialContextSampler = Sampler.InitialSampler.InitialContextSamplerStandard(sampler);
initialStateSampler = Sampler.InitialSampler.InitialStateSamplerStandard(sampler);
initialStateSampler.setInitStateFromContext(true); 

contextFeatures = FeatureGenerators.SquaredFeatures(dataManager, 'contexts');

sampler.setTransitionFunction(environment);
sampler.setInitialStateSampler(initialStateSampler);
%sampler.setContextSampler(initialContextSampler);

numTimeSteps = settings.getProperty('numTimeSteps');
viaPoint.times   = [numTimeSteps - 20:numTimeSteps]; 
viaPoint.factors = repmat([1e4, 1e3, 1e4, 1e3], length(viaPoint.times), 1);
for i = 1:length(viaPoint.factors)
    viaPoint.points{i}  = [1.0, 0.0, -1.0, 0.0];
end
viaPoint.uFactor = 10^-4;

rewardFunction = RewardFunctions.TimeDependent.ViaPointRewardFunction(dataManager, viaPoint.times,viaPoint.points,viaPoint.factors,viaPoint.uFactor);
rewardFunction.useSeperateStateActionReward(true);
returnSampler = RewardFunctions.ReturnForEpisode.ReturnSummedReward(dataManager);

trajectoryGenerator = TrajectoryGenerators.ProMPs(dataManager, numJoints);
distributionLearner = Learner.SupervisedLearner.LinearGaussianMLLearner(dataManager, trajectoryGenerator.distributionW);
distributionLearner.regularizationRegression = 1e-16; 

gainGenerator = TrajectoryGenerators.ProMPsCtl(dataManager, trajectoryGenerator, environment);

trajectoryGenerator.initObject();

sampler.addSamplerFunctionToPool('ParameterPolicy','generatePhaseD', trajectoryGenerator.phaseGenerator);
sampler.addSamplerFunctionToPool('ParameterPolicy','generatePhaseDD', trajectoryGenerator.phaseGenerator);
sampler.addSamplerFunctionToPool('ParameterPolicy','generateBasisD', trajectoryGenerator.basisGenerator);
sampler.addSamplerFunctionToPool('ParameterPolicy','generateBasisDD', trajectoryGenerator.basisGenerator);

ctrTraj = TrajectoryGenerators.TrajectoryTracker.TimeVarLinearController(dataManager, numJoints, gainGenerator);

sampler.setActionPolicy(ctrTraj);

imitationLearner = TrajectoryGenerators.ImitationLearning.LinearTrajectoryImitationLearner(dataManager, trajectoryGenerator, 'jointPositions');
imitationLearnerDistribution = TrajectoryGenerators.ImitationLearning.ParameterDistributionImitationLearner...
                             (dataManager, imitationLearner, distributionLearner, trajectoryGenerator);
                         
sampler.addSamplerFunctionToPool('ParameterPolicy', 'updateModel', gainGenerator);

piRepsLearner = Learner.EpisodicRL.EpisodicPIREPSLambda(dataManager, environment, imitationLearnerDistribution, ctrTraj, contextFeatures.outputName);
            
sampler.setRewardFunction(rewardFunction);
sampler.setReturnFunction(returnSampler);

startDistribution = Distributions.Gaussian.GaussianLinearInFeatures(dataManager, 'contexts', '', 'initStateDistribution');
startDistribution.setBias([0 0 0 0]);
startDistribution.setCovariance(diag([0.001, 0.02, 0.001, 0.02]));

sampler.setContextSampler(startDistribution, 'sampleFromDistribution');

dataManager.finalizeDataManager();
newData = dataManager.getDataObject(10);

ctrTraj.initObject();
piRepsLearner.initObject();

sampler.setParallelSampling(true);

evaluationCriterion = Experiments.EvaluationCriterion();
learningScenario = LearningScenario.LearningScenario(dataManager, evaluationCriterion, sampler);

learningScenario.addLearner(piRepsLearner);

trial = Experiments.Trial('./test/', {}, {}, 1, 100, 1);
trial.dataManager = dataManager;
trial.setprop('transitionFunction', environment);
trial.setprop('trajectoryGenerator', trajectoryGenerator);

Experiments.ParameterSettings.PathIntegralRewardSettings.setParametersForTrial(trial);
piRepsLearner.addDefaultCriteria(trial, evaluationCriterion);

evaluator = Evaluator.ReturnEvaluatorNewSamples();
evaluationCriterion.registerEvaluator(evaluator);

%evaluatorProMP = Experiments.Scripts.PiREPS.test.DistributionPlotterProMP();
%evaluationCriterion.registerEvaluator(evaluatorProMP);

evaluationCriterion.addSaveDataEntry('returns');

learningScenario.learnScenario(trial);

%%
%experimentName = 'pireps_promps';
%category = 'test';
%experiment = Experiments.Experiment.createByNameNew(experimentName, category, ...
%    {configuredTask, configuredFeatures, configuredPolicy, configuredLearner}, evaluationCriterion, 5, ...
%    {'127.0.0.1',2});
%experiment.addEvaluation(evaluate);
%experiment.startBatch(10);

