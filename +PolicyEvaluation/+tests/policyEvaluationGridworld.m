clear variables;
close all;


sampler = Sampler.EpisodeWithStepsSampler();

dataManager = sampler.getEpisodeDataManager();
%sampler.getStepSampler.setIsActiveSampler(Sampler.IsActiveStepSampler.IsActiveNumSteps(dataManager));


environment = Environments.Gridworld.SimpleWorld(sampler);
policy = Distributions.Discrete.UniformDistribution.createPolicy(dataManager);

sampler.setContextSampler(environment);
sampler.setActionPolicy(policy);
sampler.setTransitionFunction(environment);
sampler.setRewardFunction(environment);
sampler.setInitialStateSampler(environment);


currentStateFeatures = FeatureGenerators.TabularFeatures(dataManager, 'states');
nextStateFeatures = FeatureGenerators.TabularFeatures(dataManager, 'nextStates');

currentStateFeatures.initObject();
nextStateFeatures.initObject();

stateActionFeatures = PolicyEvaluation.DiscreteActionStateFeatureGenerator(dataManager, currentStateFeatures.outputName);
stateActionGenerator = PolicyEvaluation.GenerateStateDiscreteActionFeatures(dataManager, 'statesTabular', 'nextStatesTabular', policy);

qFunction = Functions.ValueFunctions.LinearQFunction(dataManager, 'statesTabularDiscreteActions');
lstd = PolicyEvaluation.LeastSquaresTemporalDifferenceLearning(dataManager, qFunction, 'statesTabularDiscreteActions', 'nextStatesTabularDiscreteActions', 'rewards');
evaluation = PolicyEvaluation.PolicyEvaluationPreProcessor(dataManager, lstd, qFunction);


dataManager.finalizeDataManager();
newData = dataManager.getDataObject(10);
newData2 = dataManager.getDataObject(0);


sampler.numSamples = 1000;
sampler.setParallelSampling(true);
fprintf('Generating Data\n');
tic
sampler.createSamples(newData);
toc

stateActionGenerator.preprocessData(newData);

evaluation.preprocessData(newData);

