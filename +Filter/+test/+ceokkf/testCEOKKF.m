Common.clearClasses();
clear variables;
close all;

internal_objective = 'llh';

Filter.test.preludes.pendulumWindowsCeokkf;

numObservedSamples = numSamplesPerEpisode;

%%
% i = 30;
% Y = testData.getDataEntry('thetaNoisyWindows',i);
% Yw = testData.getDataEntry('thetaNoisyWindows',i);
% valid = testData.getDataEntry('thetaNoisyWindowsValid',i);
% Y = Y(logical(valid),:);
% Yw = Yw(logical(valid),:);
% Y_trans = ceokkfLearner.filter.outputTransformation(ceokkfLearner.filter.getEmbeddings(Y));
% 
% plot(Y_trans(1,:)'); hold on; plot(Yw(:,obs_ind),'r')

testData.setDataEntry('obsPoints',repmat([true(numObservedSamples,1);false(numSamplesPerEpisode-numObservedSamples,1)],numEpisodes,1));

fprintf('filtering testData\n');
i = 1;
% ceokkfLearner.filter.initialMean = ceokkfLearner.filter.getEmbeddings(testData.getDataEntry(feature_name,i,1));
ceokkfLearner.filter.callDataFunction('filterData',testData, i);
% 
%%
testDataStruct = testData.getDataStructure();
figure; hold on;
Plotter.shadedErrorBar([1:30],testDataStruct.steps(i).filteredMu(1:end,1),2*sqrt(testDataStruct.steps(i).filteredVar(1:end,1)),'-k',1);
% plot(testDataStruct.steps(i).filteredMu(1:110,1));
plot(testDataStruct.steps(i).thetaNoisy(:,1));
plot(testDataStruct.steps(i).states(:,1),':');