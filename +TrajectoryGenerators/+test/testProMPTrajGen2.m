clear variables;
close all;
Common.clearClasses;



sampler = Sampler.EpisodeWithStepsSampler();

dataManager = sampler.getEpisodeDataManager();
sampler.getStepSampler.setIsActiveSampler(Sampler.IsActiveStepSampler.IsActiveNumSteps(dataManager));

numJoints = 2;
environment = Environments.DynamicalSystems.LinearSystem(sampler, numJoints);

dataManager.setRange('actions',-1e10*ones(1,numJoints),1e10*ones(1,numJoints));
dataManager.setRestrictToRange('actions', false);
environment.initObject();

sampler.setTransitionFunction(environment);

settings = Common.Settings();

dt = 0.001;
Ts = 1;
settings.setProperty('dt', dt);
settings.setProperty('numBasis', 50);
settings.setProperty('numTimeSteps', Ts / dt);
settings.setProperty('widthFactorBasis', 1);
settings.setProperty('Noise_std', 0);


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



dataManager.finalizeDataManager();

nSamples = 30;
trLength = Ts / dt;

trData = dataManager.getDataObject([nSamples trLength]);
sampleData = dataManager.getDataObject(0);

t = linspace(0, Ts, trLength)';
figure;hold all;
for i = 1:nSamples
    z = randn(2,1);
    
    jointPositions = [cos(t * 2 *pi  + 0.5) * z(1),   sin(t * 2 *pi  + 0.5) * (z(1) + 0.2 * z(2))];
    jointPositions = jointPositions + randn(size(jointPositions )) * 0.0;
    jointVelocities = diff(jointPositions);
    jointVelocities(end + 1, : ) = jointVelocities(end);
    
    trData.setDataEntry('jointPositions', jointPositions, i);
    trData.setDataEntry('jointVelocities', jointVelocities, i);

    plot(jointPositions(:,1));
end

startDistribution = Distributions.Gaussian.GaussianLinearInFeatures(dataManager, 'states', '', 'initStateDistribution');
meanInit = mean(trData.getDataEntry('states', :, 1));
covInit = cov(trData.getDataEntry('states', :, 1));
startDistribution.setBias(meanInit);
startDistribution.setCovariance(covInit + eye(size(covInit,1)) *10^-8);

sampler.setInitialStateSampler(startDistribution, 'sampleFromDistribution');


sampler.numSamples = 100;
sampler.setParallelSampling(true);

imitationLearnerDistribution.updateModel(trData);

tic
sampler.createSamples(sampleData);
toc

% trajectoryGenerator.plotStateDistribution(trData)


[meanValues, stdValues, figureHandles] = Plotter.PlotterData.plotTrajectoriesMeanAndStd(trData,'jointPositions', 1:numJoints, [], {'r'});
[meanValues, stdValues, figureHandles] = Plotter.PlotterData.plotTrajectoriesMeanAndStd(sampleData,'jointPositions', 1:numJoints, figureHandles, {'b'});

