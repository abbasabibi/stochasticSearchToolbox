clear variables;

addpath(genpath('Helper/'));

load Helper/PendulumTrajs/data.mat
%%
close all;
traj    = data.steps(1).states(:,1);
torques = data.steps(1).actions;
% plot(traj)
% 
% figure

%
y = cos(traj);
x = sin(traj);

numSteps = size(traj,1);
colorArray = bsxfun(@times, linspace(0.7, 0.3, numSteps)', [1 1 1]);



% plot(x,y, 'o', 'MarkerSize',15, 'LineWidth',2)

figure
hold on
for i = 1 : numSteps
   plot([0,x(i)], [0, y(i)], 'Color', colorArray(i,:), 'LineWidth',4) 
%    axis equal
%    pause(0.1)
end
scatter(x,y,200,colorArray, 'filled')
axis equal

figure
plot(traj)

figure
plot(torques)


%%
print('plots/Swingup','-dsvg')
