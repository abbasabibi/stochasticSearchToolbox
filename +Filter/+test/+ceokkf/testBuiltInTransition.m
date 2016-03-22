clear variables;
close all;

state_bandwidth_factor = 1;
Filter.test.preludes.pendulumWindowsCeokkf;

%%
i = 30;
Y = testData.getDataEntry('thetaNoisyWindows',i);
Yw = testData.getDataEntry('thetaNoisyWindows',i);
valid = testData.getDataEntry('thetaNoisyWindowsValid',i);
Y = Y(logical(valid),:);
Yw = Yw(logical(valid),:);

%%
m = cell(1,31);
mt = cell(1,31);
Y_out = cell(1,30);
Yt_out = cell(1,30);

m{1} = ceokkfLearner.filter.getEmbeddings(Yw);

for t = 1:30
    Y_out{t} = ceokkfLearner.filter.outputTransformation(m{t});
    m{t+1} = ceokkfLearner.filter.transition(m{t});
    hold off
    plot(t:length(Y_out{t})+t-1,Y_out{t}(1,:)'); hold on; plot(Y,'r');
    pause
end