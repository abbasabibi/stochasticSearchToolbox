
clear all;
close all;


%load('/home/fcportugal/data/test/PlanarHoleReaching_localRepsOneContextDiffDynamicBandwidth/numSamples_201411211948_01/eval001/trial001/trial.mat')
%load('/home/fcportugal/data/test/PlanarHoleReaching_localRepsOneContextDiffDynamicBandwidth/numSamples_201411262023_01/eval001/trial001/trial.mat')
%load('/home/fcportugal/data/test/PlanarHoleReaching_TrajectoryBased_LocalREPS/numSamples_201411291500_01/eval001/trial001/trial.mat')
%load('/home/fcportugal/data/test/PlanarHoleReaching_TrajectoryBased_LocalREPS/numSamples_201411291500_01/eval001/trial001/trial.mat')
%load('/home/fcportugal/data/test/PlanarHoleReaching_TrajectoryBased_LocalREPS/numSamples_201412021901_01/eval001/trial001/trial.mat')
%load('/home/fcportugal/data/test/PlanarHoleReaching_TrajectoryBased_LocalREPS/numSamples_201412012055_01/eval001/trial001/trial.mat')
load('/home/fcportugal/data/test/PlanarHoleReaching_TrajectoryBased_LocalREPS/numSamples_201411291500_01/eval001/trial001/trial.mat')

trial.scenario.initAllObjects();
%trial.iterIdx = 3730;
trial.parameterPolicy.initializing = 0;
%trial.kernel.bandwidth = 0.15;
goalPosDim = trial.numJoints;
weightsDim = trial.numJoints * trial.numBasis;
numElements = size(trial.parameterPolicy.contexts,1);


trial.data.numElements = numElements;
trial.data.ViaPointContext = trial.parameterPolicy.contexts;
trial.data.returns = trial.parameterPolicy.returns;
trial.data.Weights = trial.parameterPolicy.parameters(:,goalPosDim+1:end);
trial.data.GoalPos = trial.parameterPolicy.parameters(:,1:goalPosDim);
trial.data.steps = repmat(trial.data.steps(1),numElements,1);
trial.data.contextsSquared = trial.parameterPolicy.stateFeatures ;

save('01Exp.mat');

trial.start(false);