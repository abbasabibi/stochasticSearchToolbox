clear variables;
%close all;
Common.clearClasses;

rng(0);
% Create Sampler for SL environment
sampler = Environments.SL.SLSampler();
dataManager = sampler.getEpisodeDataManager();

numBasis = 5;

% Set properties -> we want to learn the weights only, 25 Basis with 7
% joints -> 174 parameters!
settings = Common.Settings();
settings.setProperty('useTau', false);
settings.setProperty('numBasis', numBasis);
settings.setProperty('useWeights', true);
settings.setProperty('initSigmaParameters', 0.005);

% Create sampler to load the joint data for imitation learning
samplerFromFile = Sampler.SamplerFromFile(dataManager, '+SL/+barrett/BallInACup_InitTrajectory.mat');

% create the robot
robot = Environments.SL.barrett.BarrettCommunication();
% create the SL task
task = Environments.SL.SLRobotTask(dataManager, robot);

dimJoints = robot.dimJoints;

%We want to learn with trajectory generators
environment = Environments.SL.SLTrajectoryEnvironment(dataManager, task, robot);
environment.registerSLReturnAsReward();
sampler.setSLEpisodeSampler(environment);

%which are DMPs...
trajectoryGenerator = TrajectoryGenerators.DynamicMovementPrimitives(dataManager, dimJoints);


dataManager.finalizeDataManager();

%Imitation learning fro DMPs: 
% -Imitation for a single trajectory
imitationLearner = TrajectoryGenerators.ImitationLearning.DMPsImitationLearner(dataManager, trajectoryGenerator, 'jointPositions');

% distribution in DMP parameters
dmpParameterDistribution = Distributions.Gaussian.GaussianParameterPolicy(dataManager);
dmpParameterDistribution.initObject();

%Use parameter distribution to sample the parameters
sampler.setParameterPolicy(dmpParameterDistribution);
% We need to add the trajectory generator to the sampler to create the
% reference trajectory. NOTE: The trajectory generator needs to be added
% *AFTER* the policy!
sampler.addParameterPolicy(trajectoryGenerator, 'getReferenceTrajectory');


%Learner for distribution -> this guy will learn from the parameters
%extracted by imitation from the single demonstrations
dmpParameterDistributionLearner = Learner.SupervisedLearner.LinearGaussianMLLearner(dataManager, dmpParameterDistribution);

% This guy uses the imitationLearner to get the parameters for the single
% demonstrations, it puts it then in the data set (parameter name +
% 'Imitation' and uses dmpParameterDistributionLearner to learn the
% distribution
imitationLearnerDistribution = TrajectoryGenerators.ImitationLearning.ParameterDistributionImitationLearner(dataManager, imitationLearner, dmpParameterDistributionLearner, trajectoryGenerator);
imitationLearnerDistribution.setAddInitialSigma(true);

%create new data
trData = dataManager.getDataObject(0); 

%Load the data from file
samplerFromFile.createSamples(trData);


% Learn the parameter distribution
imitationLearnerDistribution.updateModel(trData);

% new data structure for creating data from SL
newData = dataManager.getDataObject(); 

% Create 10 trajectories with SL
tic
sampler.numSamples = 10;
sampler.createSamples(newData);
toc


% Create the reference trajectory and compare the results - should be the
% same
refDMP = newData.getDataEntry('referencePos', 1);
realTraj = newData.getDataEntry('jointPositions', 1);
trainTraj = trData.getDataEntry('jointPositions', 1);

for i = 1:7
    figure;
    
    plot(refDMP(:,i));
    hold all;
    plot(realTraj(:,i), '--');
    plot(trainTraj(:,i), '-.');
    
    legend('desired trajectory (from DMPs)', 'real trajectory', 'original trajectory');
end

newData.getDataEntry('returns')

