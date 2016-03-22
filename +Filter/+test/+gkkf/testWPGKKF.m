Common.clearClasses
clear variables;
close all;

cond_operator_type = 'reg';

Filter.test.preludes.pendulumWindowsWPGkkf;

obsPoints = true(30,1);
data.setDataEntry('obsPoints',repmat(obsPoints,numEpisodes,1));

%%

gkkfLearner.filter.callDataFunction('filterData',data,1:20);

%%
dataStructure = data.dataStructure;

for t = 1:20
    plot(dataStructure.steps(t).filteredMu)
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
