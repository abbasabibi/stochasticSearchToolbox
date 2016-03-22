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
m = cell(1,31);
Y_out = cell(1,30);

m{1} = gkkfLearner.filter.getEmbeddings(Yw);

hold off;
% plot(Y_out(1,:)); hold on; plot(Y,'r')

for t = 1:30
    Y_out{t} = gkkfLearner.filter.outputTransformation(m{t});
    m{t+1} = gkkfLearner.filter.transition(m{t});
    hold off
    plot(t:length(Y_out{t})+t-1,Y_out{t}(1,:)'); hold on; plot(Yw(:,obs_ind),'r');
    pause
end