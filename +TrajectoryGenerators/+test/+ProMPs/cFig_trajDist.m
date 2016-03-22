clear variables;
close all;
Common.clearClasses;

settings = Common.Settings();
settings.setProperty('dt', 0.005);
settings.setProperty('numBasis', 40);
settings.setProperty('numTimeSteps', 200);
settings.setProperty('widthFactorBasis', 1.0);
settings.setProperty('Noise_std', 10);


sampler = Sampler.EpisodeWithStepsSampler();

dataManager = sampler.getEpisodeDataManager();
sampler.getStepSampler.setIsActiveSampler(Sampler.IsActiveStepSampler.IsActiveNumSteps(dataManager));

numJoints = 1;
environment = Environments.DynamicalSystems.LinearSystem(sampler, numJoints);
environment.masses = 1;%  17.5000   26.2500    8.7500];

% dataManager.setRange('actions',-1e10*ones(1,numJoints),1e10*ones(1,numJoints));
dataManager.setRange('actions',-300*ones(1,numJoints),300*ones(1,numJoints));
dataManager.setRestrictToRange('actions', false);
environment.initObject();

sampler.setTransitionFunction(environment);

trajectoryGenerator = TrajectoryGenerators.ProMPs(dataManager, numJoints);
distributionLearner = Learner.SupervisedLearner.LinearGaussianMLLearner(dataManager, trajectoryGenerator.distributionW);
distributionLearner.minCov = 0.0;

gainGenerator = TrajectoryGenerators.ProMPsCtl(dataManager, trajectoryGenerator, environment);

trajectoryGenerator.initObject();

sampler.addParameterPolicy(trajectoryGenerator.phaseGenerator,'generatePhaseD');
sampler.addParameterPolicy(trajectoryGenerator.phaseGenerator,'generatePhaseDD');
sampler.addParameterPolicy(trajectoryGenerator.basisGenerator,'generateBasisD');
sampler.addParameterPolicy(trajectoryGenerator.basisGenerator,'generateBasisDD');

ctrTraj = TrajectoryGenerators.TrajectoryTracker.TimeVarLinearController(dataManager, numJoints, gainGenerator);

sampler.setActionPolicy(ctrTraj);

imitationLearner = TrajectoryGenerators.ImitationLearning.LinearTrajectoryImitationLearner(dataManager, trajectoryGenerator, 'jointPositions');
imitationLearnerDistribution = TrajectoryGenerators.ImitationLearning.ParameterDistributionImitationLearner...
                             (dataManager, imitationLearner, distributionLearner, trajectoryGenerator);
                         
imitationLearner.imitationLearningRegularization = 1e-6; 
                         
sampler.addParameterPolicy(gainGenerator,'updateModel');

sampler.setInitialStateSampler(trajectoryGenerator);


dataManager.finalizeDataManager();

%%% From file
% load('+TrajectoryGenerators/+test/+ProMPs/im_data_opt_1k.mat'  )
load('+TrajectoryGenerators/+test/+ProMPs/im_data_opt_smooth_1k.mat')
nSamples = length(imlearn.q);
trLength = size(imlearn.q{1},1);

trData = dataManager.getDataObject([nSamples trLength]);
sampleData = dataManager.getDataObject(0);


figure;hold all;
for i = 1:nSamples
    plot(imlearn.q{i}(:,1));
    trData.setDataEntry('jointPositions', imlearn.q{i}(:,1:2:end), i);
    trData.setDataEntry('jointVelocities', imlearn.q{i}(:,2:2:end), i); %for comp plotting
end

sampler.numSamples = 300;
sampler.setParallelSampling(true);

imitationLearnerDistribution.updateModel(trData);



tic
sampler.createSamples(sampleData);
toc

% trajectoryGenerator.plotStateDistribution(trData)


[meanValues, stdValues, figureHandles] = Plotter.PlotterData.plotTrajectoriesMeanAndStd(trData,'jointPositions', 1, [], {'r'});
[meanValues, stdValues, figureHandles] = Plotter.PlotterData.plotTrajectoriesMeanAndStd(sampleData,'jointPositions', 1, figureHandles, {'b'});



[meanValues, stdValues, figureHandles] = Plotter.PlotterData.plotTrajectoriesMeanAndStd(trData,'jointVelocities', 1, [], {'r'});
[meanValues, stdValues, figureHandles] = Plotter.PlotterData.plotTrajectoriesMeanAndStd(sampleData,'jointVelocities', 1, figureHandles, {'b'});
