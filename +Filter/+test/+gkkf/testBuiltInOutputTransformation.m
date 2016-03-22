clear variables;
close all;

Filter.test.preludes.pendulumWindowsGkkf;

%%
i = 30;
Y = testData.getDataEntry('thetaNoisyWindows',i);
Yw = testData.getDataEntry('thetaNoisyWindows',i);
valid = testData.getDataEntry('thetaNoisyWindowsValid',i);
Y = Y(logical(valid),:);
Yw = Yw(logical(valid),:);

%%
m = cell(1,31);
Y_out = cell(1,30);
Yt_out = cell(1,30);

m{1} = gkkfLearner.filter.getEmbeddings(Y);

for t = 1:30
    Y_out{t} = gkkfLearner.filter.outputTransMatrix * gkkfLearner.filter.Ko2 * m{t};
    Yt_out{t} = gkkfLearner.filter.outputTransformation(m{t});
    m{t+1} = (gkkfLearner.filter.K11 + gkkfLearner.transitionModelLearner.lambdaT *eye(kernel_size)) \ gkkfLearner.filter.K12 * m{t};
    hold off
    plot(t:length(Y_out{t})+t-1,Y_out{t}(1,:)'); hold on; plot(t:length(Yt_out{t})+t-1,Yt_out{t}(1,:)','k'); plot(Yw(:,obs_ind),'r');
    pause
end