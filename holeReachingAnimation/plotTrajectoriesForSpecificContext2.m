%clear classes;
close all;
%clear all
%load('/home/fcportugal/data/test/PlanarHoleReaching_localRepsOneContextDiffBandwidth/numSamples_201411151346_01/eval001/trial001/trial.mat')
%load('/home/fcportugal/data/test/PlanarHoleReaching_localRepsOneContextDiffDynamicBandwidth/numSamples_201411191621_01/eval001/trial001/trial.mat')

%load('/home/fcportugal/data/test/PlanarHoleReaching_StandardRepsOneSmallContext/numSamples_201411171130_01/eval001/trial001/trial.mat')
%load('/home/fcportugal/data/test/PlanarHoleReaching_localRepsOneContextDiffDynamicBandwidth/numSamples_201411191621_01/eval001/trial001/trial.mat')
%load('/home/fcportugal/data/test/PlanarHoleReaching_StandardRepsOneSmallContext/numSamples_201411171130_01/eval001/trial001/trial.mat')

%load('/home/fcportugal/data/test/PlanarHoleReaching_localRepsOneContextDiffDynamicBandwidth/numSamples_201411191621_01/eval001/trial001/trial.mat')
%load('/home/fcportugal/data/test/PlanarHoleReaching_localRepsOneContextDiffDynamicBandwidthTest/numSamples_201411191802_01/eval001/trial001/trial.mat')

%load('/home/fcportugal/data/test/PlanarHoleReaching_localRepsOneContextDiffDynamicBandwidth/numSamples_201411191621_01/eval001/trial001/trial.mat')
%load('/home/fcportugal/data/test/PlanarHoleReaching_StandardRepsOneSmallContext/numSamples_201411171130_01/eval001/trial001/trial.mat')
%load('/home/fcportugal/data/test/PlanarHoleReaching_StandardRepsOneSmallContext/numSamples_201411211946_01/eval001/trial001/trial.mat')
%load('/home/fcportugal/data/test/PlanarHoleReaching_localRepsOneContextDiffDynamicBandwidth/numSamples_201411211948_01/eval001/trial001/trial.mat')
%load('/home/fcportugal/data/test/PlanarHoleReaching_StandardRepsOneSmallContext/numSamples_201411271916_01/eval001/trial001/trial.mat')
%load('/home/fcportugal/data/test/PlanarHoleReaching_localRepsOneContextDiffDynamicBandwidth/numSamples_201411262023_01/eval001/trial001/trial.mat')
%load('/home/fcportugal/data/test/PlanarHoleReaching_StandardRepsOneSmallContext/numSamples_201411281838_01/eval001/trial001/trial.mat')
%load('/home/fcportugal/data/test/PlanarHoleReaching_TrajectoryBased_LocalREPS/numSamples_201411241014_01/eval001/trial001/trial.mat')
%load('/home/fcportugal/data/test/PlanarHoleReaching_TrajectoryBased_LocalREPS/numSamples_201411291056_01/eval001/trial001/trial.mat')
%load('/home/fcportugal/data/test/PlanarHoleReaching_localRepsOneContextDiffDynamicBandwidth/numSamples_201411262023_01/eval001/trial001/trial.mat')
%load('/home/fcportugal/data/test/PlanarHoleReaching_TrajectoryBased_LocalREPS/numSamples_201411291500_01/eval001/trial001/trial.mat')
%load('/home/fcportugal/data/test/PlanarHoleReaching_TrajectoryBased_LocalREPS/numSamples_201412021901_01/eval001/trial001/trial.mat')

%load('/home/fcportugal/data/test/PlanarHoleReaching_TrajectoryBased_LocalREPS/numSamples_201411291420_01/eval001/trial001/trial.mat')
%load('/home/fcportugal/data/test/PlanarHoleReaching_TrajectoryBased_LocalREPS/numSamples_201411291500_01/eval001/trial001/trial.mat')
%load('/home/fcportugal/data/test/PlanarHoleReaching_TrajectoryBased_LocalREPS/numSamples_201412012055_01/eval001/trial001/trial.mat')
%load('/home/fcportugal/data/test/PlanarHoleReaching_TrajectoryBased_LocalREPS/numSamples_201412032234_01/eval001/trial001/trial.mat')

%load('/home/fcportugal/data/test/PlanarHoleReaching_TrajectoryBased_ShrinkageRepsVsShrinkagePower/numSamples_201502201747_01/eval001/trial001/trial.mat')
% a = trial.parameterPolicy.policy.getExpectation(1,0.6);
% load('/home/fcportugal/data/test/PlanarHoleReaching_TrajectoryBased_LocalREPS/numSamples_201411291322_01/eval001/trial001/trial.mat')
% b = trial.parameterPolicy.policy.getExpectation(1,0.6);
load('/home/fcportugal/policysearchtoolboxgerichange/policysearchtoolbox/+Experiments/data/test/PlanarReaching_TrajectoryBased_MOREholeReaching_ImportanceSamplingPreProc/numSamples_201506061947_01/eval001/trial001/trial.mat')


contexts1 =[1.4];
contexts2 =[0.06];
%contexts = 0.6 * ones(1,2);
parameters = [];

% for lambda = 0 :0.005:1
% 
%     newTheta = lambda*a + (1-lambda)*b;
%     parameters = [parameters;newTheta]
%     
% end




%state = data.getDataEntry('states');

%data.copyValuesFromDataStructure(iterationData);

%Plotter.PlotterData.plotTrajectoriesMeanAndStd(data, 'endEffPositions', 1:2)



close all;
holeRadius =0.1;
holeDepth = 1;

groundoffset = -0.01;

% R = data.getDataEntry('returns');
% 
% [I B]=sort(R);
% B = flip(B);
% %animate the robot
% C = B(1:20);

    


%R = data.getDataEntry('returns');

%plot(R) ;


for i =1:size(contexts1,2)


context1 = contexts1(i);
context2 = contexts2(i);
numSamples = 100;

%trial.dataManager.setRange('ViaPointContext',context1,context1);
%trial.dataManager.setRange('holeRadiusContext',context2,context2);

data =  trial.dataManager.getDataObject(0);
%numSamples = size(parameters,1);
trial.sampler.numSamples = numSamples;

trial.sampler.createSamples(data);
[min,indices] = max(data.getDataEntry('returns'));

close all;
trajectoryIndex = indices;


trial.planarKinematics.animate(data.getDataEntry('jointPositions',trajectoryIndex ))
hold all

holeRadius = context2;

a = [-5,groundoffset;context1-holeRadius,groundoffset;context1-holeRadius,-holeDepth+groundoffset;context1+holeRadius,-holeDepth+groundoffset;context1+holeRadius,0+groundoffset;5,groundoffset];
aComplex = complex(a(:,1),a(:,2));

plot(aComplex,'-xr')

reward = data.getDataEntry('returns',trajectoryIndex )
trajectoryContex = data.getDataEntry('contexts',trajectoryIndex );
title(sprintf('CONTEXT : %g,%g, REWARD: %g ', trajectoryContex,reward),'FontWeight', 'bold');

Plotter.plot2svg(sprintf('localRepsRepspolicyPosture750Sample%gContext%g.svg', trajectoryIndex,trajectoryContex), gcf);

end
% 
% plot(context-holeRadius,0,'-xr')
% plot(context+holeRadius,0,'-xr')
% plot(context+holeRadius,-holeDepth,'-xr')
% plot(context-holeRadius,-holeDepth,'-xr')


%plot trajecoty distribution (endEffector)

%Plotter.PlotterData.plotTrajectoriesMeanAndStd(data, 'endEffPositions', 1:2)