clear variables;
close all;
Common.clearClasses;

% We want to test the learning progress of a robot arm in this test file.
% The robot works in a two dimensional plane. It should move from its 
% starting position to the coordinates (1,1) and then fully extend itself 
% in the x-direction.
%
% To learn this progress we will use the Learner.SupervisedLearner.LinearGaussianMLLearner
% over only one iteration. 

% Number of base functions used to model the trajectory 
numBasis = 5;
% number of Joints of the Robot
numJoints = 3;


settings = Common.Settings();


% Number of steps the Sampler will run
settings.setProperty('numTimeSteps', 100);

settings.setProperty('useWeights', 1);
settings.setProperty('minWeights', -500);
settings.setProperty('maxWeights', 500);


% Parameters of the InitialStateSampler
settings.setProperty('InitialStateDistributionMinRange', - [0.5 0 0 0 0 0]);
settings.setProperty('InitialStateDistributionMaxRange', [0.5 0 0 0 0 0]);
settings.setProperty('InitialStateDistributionType', 'Uniform');

% Creating an EpisodeWithStepsSampler.
sampler = Sampler.EpisodeWithStepsSampler();

dataManager = sampler.getEpisodeDataManager();

% Set the StepSampler to terminate after a <tt>’numTimeSteps’</tt> many
% steps by using the apropiate IsActiveSampler.
sampler.getStepSampler.setIsActiveSampler(Sampler.IsActiveStepSampler.IsActiveNumSteps(dataManager));


environment = Environments.DynamicalSystems.LinearSystem(sampler, numJoints);
% Use the InitialStateSamplerStandard sampler to create a random starting 
% position defined by the settings.
initialStateSampler = Sampler.InitialSampler.InitialStateSamplerStandard(sampler);

sampler.setTransitionFunction(environment);
sampler.setInitialStateSampler(initialStateSampler);


settings.setProperty('useTau', 1);
settings.setProperty('numBasis', numBasis);
% Trajectory Generator
dmp = TrajectoryGenerators.DynamicMovementPrimitives(dataManager,numJoints);
controller = TrajectoryGenerators.TrajectoryTracker.LinearTrajectoryTracker(dataManager, numJoints);


%Reward Function
% To define our reward function we use the struct viaPoint
% viaPoint.times shows in which step we want to reach each point. In this
% example we want to reach point 1 after 40 steps and point 2 after 100 steps.
viaPoint.times   = [40, 100]; 
% viaPoint.factors weights the dimensions of the points in the reward 
% function. In this case we use <tt>[1000, 1000, 0, 0]</tt> meaning we only 
% evaluate the current position in the plane and not the momentum. 
viaPoint.factors = repmat([1e4, 1e4, 0, 0], length(viaPoint.times), 1);
% The coordinates of the Points we the robot should reach. 
viaPoint.points{1}  = [1.0, 1.0, 0.0, 0.0];
viaPoint.points{2}  = [numJoints, 0.0, 0.0, 0.0];
% Negative return added each step
viaPoint.uFactor = 0.5 * 10^0;

% planarKinematics are used in the Reward Function to calculate the
% position of the end effector 
planarKinematics = Environments.Misc.PlanarForwardKinematics(dataManager, numJoints);

% TaskSpaceViaPointRewardFunction uses the input form the viaPoint struct to calculate the reward
rewardFunction = RewardFunctions.TimeDependent.TaskSpaceViaPointRewardFunction(dataManager, planarKinematics, viaPoint.times,viaPoint.points,viaPoint.factors,viaPoint.uFactor);

% Return equals the summed rewards
returnSampler = RewardFunctions.ReturnForEpisode.ReturnSummedReward(dataManager);

% Upper Level Policy
% To learn the desired Function we use the gaussian functions given by
% <tt>Distributions.Gaussian.GaussianParameterPolicy</tt> as base functions. 
parameterPolicy = Distributions.Gaussian.GaussianParameterPolicy(dataManager);
sampler.setParameterPolicy(parameterPolicy);

% We will use the <tt>Learner.SupervisedLearner.LinearGaussianMLLearner</tt>
% as policy lerner. We will register it via constructor to the repsLearner 
% <tt>Learner.EpisodicRL.EpisodicREPS</tt>.

settings.setProperty('epsilonAction', 0.5);
%TODO Usage of gerneral RLByWeightedML learner
parameterPolicyLearner = Learner.SupervisedLearner.LinearGaussianMLLearner(dataManager, parameterPolicy);
repsLearner = Learner.EpisodicRL.EpisodicREPS(dataManager, parameterPolicyLearner, 'returns', 'returnWeightings');

% TODO
sampler.addSamplerFunctionToPool('ParameterPolicy', 'generatePhase', dmp.phaseGenerator );
sampler.addSamplerFunctionToPool('ParameterPolicy', 'generateBasis', dmp.basisGenerator);
sampler.addSamplerFunctionToPool('ParameterPolicy', 'getReferenceTrajectory', dmp);

% register reward and return function etc
sampler.setRewardFunction(rewardFunction);
sampler.setReturnFunction(returnSampler);
sampler.setActionPolicy(controller);

dataManager.finalizeDataManager();
newData = dataManager.getDataObject(10);

parameterPolicy.initObject();
repsLearner.initObject();


% The EpisodewithStepsSampler will now run 100 Episodes for 100 steps parallelly.
sampler.numSamples = 100;
sampler.setParallelSampling(true);

fprintf('Generating Data\n');
tic
sampler.createSamples(newData);
toc

% Plotting?

muParams = parameterPolicy.bias
sigmaParams = parameterPolicy.getCovariance()
% Now the reps learner will use the rewards of those samples to update the
% action policy by adjusting the weights of the base functions.
repsLearner.updateModel(newData);

muParams = parameterPolicy.bias
sigmaParams = parameterPolicy.getCovariance()

Plotter.PlotterData.plotTrajectories(newData, 'endEffPositions', 1, figure);

Plotter.PlotterData.plotTrajectories(newData, 'jointPositions', 1, figure);
Plotter.PlotterData.plotTrajectories(newData, 'referencePos', 1, figure);

planarKinematics.animate(newData.getDataEntry('jointPositions',1));




