clear variables;
close all;
Common.clearClasses;
numBasis = 5;
numJoints = 3;

settings = Common.Settings();
settings.setProperty('useTau', 1);
settings.setProperty('numBasis', numBasis);
settings.setProperty('numTimeSteps', 100);
settings.setProperty('useWeights', 1);
settings.setProperty('InitialStateDistributionMinRange', [0.0 0 0 0 0 0]);
settings.setProperty('InitialStateDistributionMaxRange', [0.0 0 0 0 0 0]);

settings.setProperty('InitialStateDistributionType', 'Uniform');

sampler = Sampler.EpisodeWithStepsSampler();

dataManager = sampler.getEpisodeDataManager();
sampler.getStepSampler.setIsActiveSampler(Sampler.IsActiveStepSampler.IsActiveNumSteps(dataManager));


environment = Environments.DynamicalSystems.LinearSystem(sampler, numJoints);
initialStateSampler = Sampler.InitialSampler.InitialStateSamplerStandard(sampler);

sampler.setTransitionFunction(environment);
sampler.setInitialStateSampler(initialStateSampler);

phaseGenerator = TrajectoryGenerators.PhaseGenerators.DMPPhaseGenerator(dataManager);
basisGenerator = TrajectoryGenerators.BasisFunctions.DMPBasisGenerator(dataManager,phaseGenerator);

controller = TrajectoryGenerators.TrajectoryTracker.LinearTrajectoryTracker(dataManager, numJoints);


viaPoint.times   = [40, 100]; 
viaPoint.factors = repmat([1e4, 1e4, 0, 0], length(viaPoint.times), 1);
viaPoint.points{1}  = [1.0, 1.0, 0.0, 0.0];
viaPoint.points{2}  = [numJoints, 0.0, 0.0, 0.0];                
viaPoint.uFactor = 0.5 * 10^0;

planarKinematics = Environments.Misc.PlanarForwardKinematics(dataManager, numJoints);
rewardFunction = RewardFunctions.TimeDependent.TaskSpaceViaPointRewardFunction(dataManager, planarKinematics, viaPoint.times,viaPoint.points,viaPoint.factors,viaPoint.uFactor);
returnSampler = RewardFunctions.ReturnForEpisode.ReturnSummedReward(sampler);

linTraj = TrajectoryGenerators.DynamicMovementPrimitives(dataManager,numJoints);

parameterPolicy = Distributions.Gaussian.GaussianParameterPolicy(dataManager);
parameterPolicyLearner = Learner.SupervisedLearner.LinearGaussianMLLearner(dataManager, parameterPolicy);
sampler.setParameterPolicy(parameterPolicy);

repsLearner = Learner.EpisodicRL.EpisodicREPS(dataManager, parameterPolicyLearner, 'returns', 'returnWeightings');

sampler.addParameterPolicy(phaseGenerator,'generatePhase');
sampler.addParameterPolicy(basisGenerator,'generateBasis');
sampler.addParameterPolicy(linTraj,'getReferenceTrajectory');

sampler.setRewardFunction(rewardFunction);
sampler.setReturnFunction(returnSampler);


sampler.setActionPolicy(controller);

dataManager.finalizeDataManager();
newData = dataManager.getDataObject(10);

parameterPolicy.initObject();
repsLearner.initObject();

sampler.numSamples = 100;
sampler.setParallelSampling(true);

evaluationCriterion = Experiments.EvaluationCriterion();
learningScenario = LearningScenario.LearningScenario(dataManager, evaluationCriterion, sampler);

learningScenario.addLearner(repsLearner);

trial = Experiments.Trial('./test/', {}, {}, 1, 20, 1);
repsLearner.addDefaultCriteria(trial, evaluationCriterion);
evaluator = Evaluator.ReturnEvaluatorNewSamples();
evaluationCriterion.registerEvaluator(evaluator);
           
evaluationCriterion.addSaveDataEntry('returns');

learningScenario.learnScenario(trial);




