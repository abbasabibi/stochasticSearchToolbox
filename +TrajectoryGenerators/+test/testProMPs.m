clear variables;
close all;
Common.clearClasses;


sampler = Sampler.EpisodeWithStepsSampler();

dataManager = sampler.getEpisodeDataManager();
sampler.getStepSampler.setIsActiveSampler(Sampler.IsActiveStepSampler.IsActiveNumSteps(dataManager));

numJoints = 3;
environment = Environments.DynamicalSystems.LinearSystem(sampler, numJoints);

sampler.setTransitionFunction(environment);

settings = Common.Settings();
settings.setProperty('dt', 0.001);
settings.setProperty('numBasis', 30);
settings.setProperty('numTimeSteps', 100);
settings.setProperty('widthFactorBasis', 1);


trajectoryGenerator = TrajectoryGenerators.ProMPs(dataManager, numJoints);
distributionLearner = Learner.SupervisedLearner.LinearGaussianMLLearner(dataManager, trajectoryGenerator.distributionW);
distributionLearner.regularizationRegression = 1e-8; 


sampler.addSamplerFunctionToPool('ParameterPolicy', 'generatePhaseD', trajectoryGenerator.phaseGenerator);
sampler.addSamplerFunctionToPool('ParameterPolicy', 'generatePhaseDD', trajectoryGenerator.phaseGenerator);
sampler.addSamplerFunctionToPool('ParameterPolicy', 'generateBasisD', trajectoryGenerator.basisGenerator);
sampler.addSamplerFunctionToPool('ParameterPolicy', 'generateBasisDD', trajectoryGenerator.basisGenerator);

dataManager.finalizeDataManager();


imitationLearner = TrajectoryGenerators.ImitationLearning.LinearTrajectoryImitationLearner(dataManager, trajectoryGenerator, 'jointPositions');
imitationLearnerDistribution = TrajectoryGenerators.ImitationLearning.ParameterDistributionImitationLearner...
                             (dataManager, imitationLearner, distributionLearner, trajectoryGenerator);
                         
imitationLearnerDistribution.setAddInitialSigma(true);

trajectoryGenerator.initObject();


%% Generate
trData = dataManager.getDataObject([10 400]); %FIXME on the states

figure;hold all;
for i = 1:10
    t = 0.01:0.01:4;
    z = randn(1);
    ImTraj = sin ( t*pi) * (1 + z);
    ImTraj = ImTraj .* exp(-t) + 0.05 * randn(size(t));
    ImTraj = ImTraj';
    plot(ImTraj);
    trData.setDataEntry('jointPositions', [ImTraj,ImTraj,ImTraj], i);
end
sampler.numSamples = 1;
sampler.setParallelSampling(true);

imitationLearnerDistribution.updateModel(trData);

sampler.createSamples(trData);

% trajectoryGenerator.basisGenerator.callDataFunction('generateBasis', trData)

fp = trajectoryGenerator.plotStateDistribution(trData);
fv = trajectoryGenerator.plotStateDistribution(trData,1);

[meanValues, stdValues, figureHandles] = Plotter.PlotterData.plotTrajectoriesMeanAndStd(trData,'jointPositions', 1:numJoints, [], {'r'});
