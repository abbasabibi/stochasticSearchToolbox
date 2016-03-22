clear variables;
close all;
Common.clearClasses;

% Create Sampler for SL environment
sampler = Environments.SL.SLSampler();
dataManager = sampler.getEpisodeDataManager();

numBasis = 10;

% Set properties -> we want to learn the weights only, 25 Basis with 7
% joints -> 174 parameters!
settings = Common.Settings();
settings.setProperty('useTau', false);
settings.setProperty('numBasis', numBasis);
settings.setProperty('useWeights', true);
                                  
% Create sampler to load the joint data for imitation learning
samplerFromFile = Sampler.SamplerFromFile(dataManager, '+Environments/+SL/+barrett/BeerPong_InitTrajectory.mat');

% create the robot
robot = Environments.SL.barrett.BarrettCommunication();

dimJoints = robot.dimJoints;

%We want to learn with trajectory generators
environment = Environments.SL.SLTrajectoryEnvironment(dataManager, robot);

% create the SL task (needs to be done after the environment!)
task = Environments.SL.Tasks.SLBallInACupTask(dataManager, robot);
environment.setTask(task);
sampler.setSLEpisodeSampler(environment);
environment.registerSLReturnAsReward();

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
newData = dataManager.getDataObject([1,300]); 

weightMean = trajectoryGenerator.Weights;
% Now sample 10 different trajectories

rng(1);
for i = 1:10
    newWeight = weightMean + randn(size(weightMean)) * 100;    
    
    % get robot context
    environment.callDataFunction('getRobotContext', newData);
    
    %set the weights
    newData.setDataEntry('Weights', newWeight', 1);
    
    %get the reference trajectory
    trajectoryGenerator.callDataFunction('getReferenceTrajectory', newData);
    
    %execute it
    environment.callDataFunction('sampleEpisode', newData);
    
    %get the returns
    reward(i) = newData.getDataEntry('returns');
end



