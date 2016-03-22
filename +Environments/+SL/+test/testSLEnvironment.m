clear variables;
close all;
Common.clearClasses;

% Create Sampler for SL environment
sampler = Environments.SL.SLSampler();
dataManager = sampler.getEpisodeDataManager();

numBasis = 25;

% Set properties -> we want to learn the weights only, 25 Basis with 7
% joints -> 174 parameters!
settings = Common.Settings.createNewSettings();
settings.setProperty('useTau', false);
settings.setProperty('numBasis', numBasis);
settings.setProperty('useWeights', false);
                                  
% Create sampler to load the joint data for imitation learning
samplerFromFile = Sampler.SamplerFromFile(dataManager, '+Environments/+SL/+barrett/BallInACup_InitTrajectory.mat');

% create the robot
robot = Environments.SL.barrett.BarrettCommunication();
% create the SL task
task = Environments.SL.SLRobotTask(dataManager, robot);

dimJoints = robot.dimJoints;

%We want to learn with trajectory generators
environment = Environments.SL.SLTrajectoryEnvironment(dataManager, robot);
environment.setTask(task);
sampler.setSLEpisodeSampler(environment);

%which are DMPs...
trajectoryGenerator = TrajectoryGenerators.DynamicMovementPrimitives(dataManager, dimJoints);

dataManager.finalizeDataManager();

%create new data
trData = dataManager.getDataObject(0); 

%Load the data from file
samplerFromFile.createSamples(trData);

%Imitation learning fro DMPs: 
% -Imitation for a single trajectory
imitationLearner = TrajectoryGenerators.ImitationLearning.DMPsImitationLearner(dataManager, trajectoryGenerator, 'jointPositions');
imitationLearner.updateModel(trData);

% We need to add the trajectory generator to the sampler to create the
% reference trajectory
sampler.addSamplerFunctionToPool('ParameterPolicy', 'getReferenceTrajectory', trajectoryGenerator);

% new data structure for creating data from SL
newData = dataManager.getDataObject(); 

% Create 10 trajectories with SL
tic
sampler.numSamples = 1;
environment.numTimeSteps = 2000;
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

for i = 1:10
    newData_i{i} = dataManager.getDataObject(); 

    sampler.numSamples = 5;
    sampler.createSamples(newData_i{i});
    
    newData_i{i}.getDataEntry('SLreturns')
    pause(rand(1) * 5);
end