clear variables;
close all;
Common.clearClasses;


sampler = Sampler.EpisodeWithStepsSampler();

dataManager = sampler.getEpisodeDataManager();
sampler.getStepSampler.setIsActiveSampler(Sampler.IsActiveStepSampler.IsActiveNumSteps(dataManager));

numJoints = 3;
environment = Environments.DynamicalSystems.LinearSystem(sampler, numJoints);

sampler.setTransitionFunction(environment);


numBasis = 25;

settings = Common.Settings();
settings.setProperty('useTau', true);
settings.setProperty('numBasis', numBasis);
settings.setProperty('useWeights', true);
settings.setProperty('numTimeSteps', 400);


trajectoryGenerator = TrajectoryGenerators.DynamicMovementPrimitives(dataManager, 3);

numJoints = 3;

dataManager.finalizeDataManager();

%sampler.createSamples(trData);

imitationLearner = TrajectoryGenerators.ImitationLearning.DMPsImitationLearner(dataManager, trajectoryGenerator, 'jointPositions');
dmpParameterDistribution = Distributions.Gaussian.GaussianParameterPolicy(dataManager);
dmpParameterDistribution.initObject();
dmpParameterDistributionLearner = Learner.SupervisedLearner.LinearGaussianMLLearner(dataManager, dmpParameterDistribution);

imitationLearnerDistribution = TrajectoryGenerators.ImitationLearning.ParameterDistributionImitationLearner(dataManager, imitationLearner, dmpParameterDistributionLearner, trajectoryGenerator);
imitationLearnerDistribution.setAddInitialSigma(true);

trData = dataManager.getDataObject([10 400]); %FIXME on the states

for i = 1:10
    t = 0.01:0.01:4;
    z = randn(1);
    ImTraj = sin ( t*pi) * (1 + z);
    ImTraj = ImTraj .* exp(-t);
    ImTraj = ImTraj';
    trData.setDataEntry('jointPositions', [ImTraj,ImTraj,ImTraj], i);

end
sampler.numSamples = 1;
sampler.setParallelSampling(true);

imitationLearnerDistribution.updateModel(trData);
