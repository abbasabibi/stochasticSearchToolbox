% load trial and iter file
%load +Experiments/data/test/PlanarReaching_localRepsReachingTaskDiffBandwidth/numSamples_201409300120_01/eval005/trial005/trial.mat
%load +Experiments/data/test/PlanarReaching_localRepsReachingTaskDiffBandwidth/numSamples_201409300120_01/eval005/trial005/iter_00631_00640.mat

%load('/home/hamidreza/policysearchtoolboxForICRA/+Experiments/data/test/PlanarHoleReaching_localRepsOneContextDiffBandwidth/numSamples_201410011734_01/eval001/trial001/trial.mat')
%load('/home/hamidreza/policysearchtoolboxForICRA/+Experiments/data/test/PlanarHoleReaching_localRepsOneContextDiffBandwidth/numSamples_201410011734_01/eval001/trial001/iter_01401_01410.mat')
%load('/home/hamidreza/policysearchtoolboxForICRA/+Experiments/data/test/PlanarHoleReaching_LocalRepsOneContextDiffMaxSamples/numSamples_201410022036_01/eval001/trial001/trial.mat')
%load('/home/hamidreza/policysearchtoolboxForICRA/+Experiments/data/test/PlanarHoleReaching_LocalRepsOneContextDiffMaxSamples/numSamples_201410022036_01/eval001/trial001/iter_00471_00480.mat')
load('/home/hamidreza/policysearchtoolboxForICRA/+Experiments/data/test/PlanarHoleReaching_localRepsOneContextDiffSmallBandwidth/numSamples_201410130754_01/eval001/trial001/trial.mat')
load('/home/hamidreza/policysearchtoolboxForICRA/+Experiments/data/test/PlanarHoleReaching_localRepsOneContextDiffSmallBandwidth/numSamples_201410130754_01/eval001/trial001/iter_02471_02480.mat')
 
%create data and copy data from iteration
data = trial.dataManager.getDataObject(0);
iterationData =iter02471.data;
trajectoryIndex = 42 ;
context = iterationData.ViaPointContext(trajectoryIndex);
holeRadius =0.1;
holeDepth = 1;
data.copyValuesFromDataStructure(iterationData);


%animate the robot
trial.planarKinematics.animate(data.getDataEntry('jointPositions',trajectoryIndex ))

hold all
plot(context-holeRadius,0,'*r')
plot(context+holeRadius,0,'*r')
plot(context+holeRadius,-holeDepth,'*r')
plot(context-holeRadius,-holeDepth,'*r')
%plot trajecoty distribution (endEffector)
reward = iterationData.returns(trajectoryIndex)

%Plotter.PlotterData.plotTrajectoriesMeanAndStd(data, 'endEffPositions', 1:2)