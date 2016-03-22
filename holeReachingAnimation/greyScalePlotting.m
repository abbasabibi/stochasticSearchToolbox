close all;

%load('/home/fcportugal/data/test/PlanarHoleReaching_localRepsOneContextDiffBandwidth/numSamples_201411121556_01/eval001/trial001/trial.mat')%a=trial.parameterPolicy.sampleFromDistribution(100,0.2*ones(100,1))
%load('/home/fcportugal/data/test/PlanarHoleReaching_localRepsOneContextDiffBandwidth/numSamples_201411151346_01/eval001/trial001/trial.mat')
%load('/home/fcportugal/data/test/PlanarHoleReaching_StandardRepsOneSmallContext/numSamples_201411171130_01/eval001/trial001/trial.mat')
% eig(trial.parameterPolicy.policy.cholA*trial.parameterPolicy.policy.cholA')
%load('/home/fcportugal/data/test/PlanarHoleReaching_localRepsOneContextDiffDynamicBandwidthTest/numSamples_201411181904_01/eval001/trial001/trial.mat')
%load('/home/fcportugal/data/test/PlanarHoleReaching_localRepsOneContextDiffDynamicBandwidth/numSamples_201411191621_01/eval001/trial001/trial.mat')

%load('/home/fcportugal/data/test/PlanarHoleReaching_localRepsOneContextDiffDynamicBandwidth/numSamples_201411191621_01/eval001/trial001/trial.mat')
%load('/home/fcportugal/data/test/PlanarHoleReaching_localRepsOneContextDiffDynamicBandwidthTest/numSamples_201411191802_01/eval001/trial001/trial.mat')
%load('/home/fcportugal/data/test/PlanarHoleReaching_localRepsOneContextDiffDynamicBandwidth/numSamples_201411191621_01/eval001/trial001/trial.mat')
%load('/home/fcportugal/data/test/PlanarHoleReaching_localRepsOneContextDiffDynamicBandwidthTest/numSamples_201411191802_01/eval001/trial001/trial.mat')
% return
%kernel = trial.parameterPolicy.kernel; 
%load('/home/fcportugal/data/test/PlanarHoleReaching_localRepsOneContextDiffDynamicBandwidth/numSamples_201411211948_01/eval001/trial001/trial.mat')
%load('/home/fcportugal/data/test/PlanarHoleReaching_localRepsOneContextDiffDynamicBandwidth/numSamples_201411211948_01/eval001/trial001/trial.mat')
%load('/home/fcportugal/data/test/PlanarHoleReaching_localRepsOneContextDiffDynamicBandwidth/numSamples_201411262023_01/eval001/trial001/trial.mat')

%load('/home/fcportugal/data/test/PlanarHoleReaching_localRepsOneContextDiffDynamicBandwidth/numSamples_201411262023_01/eval001/trial001/trial.mat')
%load('/home/fcportugal/data/test/PlanarHoleReaching_localRepsOneContextDiffDynamicBandwidth/numSamples_201411262023_01/eval001/trial001/trial.mat')
%load('/home/fcportugal/data/test/PlanarHoleReaching_TrajectoryBased_LocalREPS/numSamples_201411291322_01/eval001/trial001/trial.mat')
%load('/home/fcportugal/data/test/PlanarHoleReaching_TrajectoryBased_LocalREPS/numSamples_201411291500_01/eval001/trial001/trial.mat')
%load('/home/fcportugal/data/test/PlanarHoleReaching_TrajectoryBased_LocalREPS/numSamples_201412012055_01/eval001/trial001/trial.mat')
%load('/home/fcportugal/data/test/PlanarHoleReaching_TrajectoryBased_LocalREPS/numSamples_201412021901_01/eval001/trial001/trial.mat')
load('/home/fcportugal/data/test/PlanarHoleReaching_TrajectoryBased_LocalREPS/numSamples_201412032234_01/eval001/trial001/trial.mat')


R=trial.parameterPolicy.returns; %return
C=trial.parameterPolicy.contexts(:,2); %context
%R= trial.data.returns;
%C= trial.data.ViaPointContext;
nrData = size(C,1);
%max(R)
%sum(R>-90000)

%return
z=[1:size(C,1)]; % Data 

% scale of grey, number lower than 1, greater than 0
greyscale = z./max(z); % if all z are >0

figure(1)
hold on,
for i=1:nrData
    
plot(C(i),R(i),'o','markerfacecolor',[1 1 1]*greyscale(i))
end

plot([0.0 0.5],[-40000 -40000],'r');
%Plotter.plot2svg('psamples.svg', gcf);
%axis([-2 2 -10e7 0])