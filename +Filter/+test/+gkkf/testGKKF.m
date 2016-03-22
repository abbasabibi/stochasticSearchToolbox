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
Y_trans = gkkfLearner.filter.outputTransMatrix * gkkfLearner.filter.getKernelVectorsO(Y);

plot(Y_trans(1,:)'); hold on; plot(Yw(:,obs_ind),'r')

%%
m = cell(1,30);
md = cell(1,31);
Y_out = cell(1,30);
Yd_out = cell(1,30);

m{1} = (gkkfLearner.filter.K11 + gkkfLearner.transitionModelLearner.lambdaT *eye(kernel_size)) \ gkkfLearner.filter.getKernelVectors1(Y);
md{2} = (gkkfLearner.filter.K11 + gkkfLearner.transitionModelLearner.lambdaT *eye(kernel_size)) \ gkkfLearner.filter.getKernelVectors1(Y);
Y_out{1} = gkkfLearner.filter.outputTransMatrix * gkkfLearner.filter.getKernelVectorsO(gkkfLearner.filter.data1) * m{1};
Yd_out{1} = gkkfLearner.filter.outputTransMatrix * gkkfLearner.filter.getKernelVectorsO(Y);
hold off
plot(1:length(Y_out{1}),Y_out{1}(1,:)'); hold on; plot(1:length(Yd_out{1}),Yd_out{1}(1,:)','k'); plot(Yw(:,obs_ind),'r');
pause
for t = 2:30
    Y_out{t} = gkkfLearner.filter.outputTransMatrix * gkkfLearner.filter.Ko2 * m{t-1};
    Yd_out{t} = gkkfLearner.filter.outputTransMatrix * gkkfLearner.filter.Ko2 * md{t};
    m{t} = (gkkfLearner.filter.K11 + gkkfLearner.transitionModelLearner.lambdaT *eye(kernel_size)) \ gkkfLearner.filter.K12 * m{t-1};
    md{t+1} = (gkkfLearner.filter.K11 + gkkfLearner.transitionModelLearner.lambdaT *eye(kernel_size)) \ gkkfLearner.filter.K12 * md{t};
    hold off
    plot(t:length(Y_out{t})+t-1,Y_out{t}(1,:)'); hold on; plot(t:length(Yd_out{t})+t-1,Yd_out{t}(1,:)','k'); plot(Yw(:,obs_ind),'r');
    pause
end

%


%%
% testData.setDataEntry('obsPoints',repmat([true(numObservedSamples,1);false(numSamplesPerEpisode-numObservedSamples,1)],numEpisodes,1));
% 
% fprintf('filtering testData\n');
% i = 1;
% gkkfLearner.filter.initialMean = gkkfLearner.filter.getEmbeddings(testData.getDataEntry('thetaNoisyWindowsPcaFeatures',i,1));
% gkkfLearner.filter.callDataFunction('filterData',testData, i);
% % 
% %%
% testDataStruct = testData.getDataStructure();
% figure; hold on;
% Plotter.shadedErrorBar([2:31],testDataStruct.steps(i).filteredMu(1:end,1),2*sqrt(testDataStruct.steps(i).filteredVar(1:end,1)),'-k',1);
% % plot(testDataStruct.steps(i).filteredMu(1:110,1));
% plot(testDataStruct.steps(i).thetaNoisy(:,1));

%%
% testFeatures = testData.getDataEntry('thetaNoisyWindows');
% testFeaturesValidIdx = testData.getDataEntry('thetaNoisyWindowsValid');
% validTestFeatures = testFeatures(logical(testFeaturesValidIdx),:);
% validNextTestFeatures = testFeatures(find(testFeaturesValidIdx)+1,:);
% data2 = data.getDataEntry('thetaNoisyWindows');
% data2 = data2(gkkfLearner.filter.winKernelReferenceSet.getReferenceSetIndices(),:);
% validTestFeaturesEmbeddings = gkkfLearner.filter.getEmbeddings(validTestFeatures);
% validNextTestFeaturesEmbeddings = gkkfLearner.filter.getEmbeddings(validNextTestFeatures);
% % validTestFeaturesEmbeddings = gkkfLearner.filter.winKernelReferenceSet.kernel.getGramMatrix(data2,validTestFeatures);
% % validNextTestFeaturesEmbeddings = gkkfLearner.filter.winKernelReferenceSet.kernel.getGramMatrix(data2,validNextTestFeatures);
% error = (validNextTestFeaturesEmbeddings - gkkfLearner.filter.transition(validTestFeaturesEmbeddings));
% 
% %%
% testFeatures = data.getDataEntry('thetaNoisyWindows');
% testFeaturesValidIdx = gkkfLearner.filter.winKernelReferenceSet.getReferenceSetIndices;
% validTestFeatures = testFeatures(testFeaturesValidIdx,:);
% validNextTestFeatures = testFeatures(testFeaturesValidIdx+1,:);
% data2 = data.getDataEntry('thetaNoisyWindows');
% data2 = data2(gkkfLearner.filter.winKernelReferenceSet.getReferenceSetIndices(),:);
% validTestFeaturesEmbeddings = gkkfLearner.filter.getEmbeddings(validTestFeatures);
% validNextTestFeaturesEmbeddings = gkkfLearner.filter.getEmbeddings(validNextTestFeatures);
% % validTestFeaturesEmbeddings = gkkfLearner.filter.winKernelReferenceSet.kernel.getGramMatrix(data2,validTestFeatures);
% % validNextTestFeaturesEmbeddings = gkkfLearner.filter.winKernelReferenceSet.kernel.getGramMatrix(data2,validNextTestFeatures);
% error = (validNextTestFeaturesEmbeddings - gkkfLearner.filter.transition(validTestFeaturesEmbeddings));
