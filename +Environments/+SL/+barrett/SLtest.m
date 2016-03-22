clear all
close all

load('/home/garry/analytical_test.mat'); % Load example trajectory data
%nsteps = size(D,1);
nsteps = 7649-1949+1;
trajectory = zeros(nsteps,9);
trajectory(:,1) = D(1949:7649,2);
trajectory(:,2) = D(1949:7649,12);
trajectory(:,3) = D(1949:7649,22);
trajectory(:,4) = D(1949:7649,32);
trajectory(:,5) = D(1949:7649,42);
trajectory(:,6) = D(1949:7649,52);
trajectory(:,7) = D(1949:7649,62);
trajectory(:,8) = D(1949:7649,72);
trajectory(:,9) = D(1949:7649,82);

time        = 0;                % Waiting time between commands/states
maxSteps    = 2;                % Number of commands/states
stateBuffer = [-0.3 0.85 0.15]; % Ballcannon serve target
%%

% WARNING: At execution, the state machine initial state is 0, so you
% must initially then next state, state 1. After the initial
% start, you must call SLSendTrajectory with state 0, then 1, 2...
%or you must use timeOut to add delay between state transitions


for i=1:2
    SLSendTrajectory(trajectory, time, 1, maxSteps, stateBuffer);
    [reward, ~, flag] = SLSendTrajectory(trajectory, time, 2, maxSteps, stateBuffer,50);
    [joints, jointsVel, jointsAcc, jointsDes, jointsVelDes, jointsAccDes, torque, cart, state] = SLGetEpisode();
end