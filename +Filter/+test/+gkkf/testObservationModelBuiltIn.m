clear variables;
close all;

state_bandwidth_factor = 1;
kernel_size = 1000;
Filter.test.preludes.pendulumWindowsRegGkkf;

%%
i = 30;
Y = testData.getDataEntry('thetaNoisy',i);
Yw = testData.getDataEntry('thetaNoisyWindows',i);
valid = testData.getDataEntry('thetaNoisyWindowsValid',i);

Y = Y(logical(valid),:);
Yw = Yw(logical(valid),:);

%%
% m = cell(1,30);
% mt = cell(1,30);
% Y_out = cell(1,30);
% Yt_out = cell(1,30);

m = gkkfLearner.filter.getEmbeddings(Yw);

S = gkkfLearner.filter.initialCov;

[m, S] = gkkfLearner.filter.observation(m,S,Y);

Y_out = gkkfLearner.filter.outputTransformation(m);
plot(1:length(Y_out),Y_out(1,:)'); hold on; plot(Yw(:,obs_ind),'r');
