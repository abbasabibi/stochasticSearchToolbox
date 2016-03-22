Common.clearClasses
clear variables;
close all;
clc

kernel_size = 1000;
red_kernel_size = 300;
state_bandwidth_factor = 4;
lambdaT = 1e-6;
lambdaO = 1e-6;
cond_operator_type = 'std';

Filter.test.preludes.pendulumImageWindowsGkkf;

%%
i = 2;
Y = testData.getDataEntry('theta',i);
Yw = testData.getDataEntry('thetaNoisyPicturePcaFeaturesWindows',i);
valid = testData.getDataEntry('thetaNoisyPicturePcaFeaturesWindowsValid',i);
Y = Y(logical(valid),:);
Yw = Yw(logical(valid),:);
% Y_trans = gkkfLearner.filter.outputTransMatrix * gkkfLearner.filter.getKernelVectorsO(Yw);
Y_trans = gkkfLearner.filter.outputTransformation(gkkfLearner.filter.getEmbeddings(Yw));

plot(Y_trans(1,:)'); hold on; plot(Y,'r')

% %%
% m = cell(1,30);
% md = cell(1,31);
% Y_out = cell(1,30);
% Yd_out = cell(1,30);
% 
% m{1} = (gkkfLearner.gkkf.K11 + gkkfLearner.transitionModelLearner.lambdaT *eye(kernel_size)) \ gkkfLearner.gkkf.getKernelVectors1(Y);
% md{2} = (gkkfLearner.gkkf.K11 + gkkfLearner.transitionModelLearner.lambdaT *eye(kernel_size)) \ gkkfLearner.gkkf.getKernelVectors1(Y);
% Y_out{1} = gkkfLearner.gkkf.outputTransMatrix * gkkfLearner.gkkf.getKernelVectorsO(gkkfLearner.gkkf.data1) * m{1};
% Yd_out{1} = gkkfLearner.gkkf.outputTransMatrix * gkkfLearner.gkkf.getKernelVectorsO(Y);
% hold off
% plot(1:length(Y_out{1}),Y_out{1}(1,:)'); hold on; plot(1:length(Yd_out{1}),Yd_out{1}(1,:)','k'); plot(Yw(:,obs_ind),'r');
% pause
% for t = 2:30
%     Y_out{t} = gkkfLearner.gkkf.outputTransMatrix * gkkfLearner.gkkf.Ko2 * m{t-1};
%     Yd_out{t} = gkkfLearner.gkkf.outputTransMatrix * gkkfLearner.gkkf.Ko2 * md{t};
%     m{t} = (gkkfLearner.gkkf.K11 + gkkfLearner.transitionModelLearner.lambdaT *eye(kernel_size)) \ gkkfLearner.gkkf.K12 * m{t-1};
%     md{t+1} = (gkkfLearner.gkkf.K11 + gkkfLearner.transitionModelLearner.lambdaT *eye(kernel_size)) \ gkkfLearner.gkkf.K12 * md{t};
%     hold off
%     plot(t:length(Y_out{t})+t-1,Y_out{t}(1,:)'); hold on; plot(t:length(Yd_out{t})+t-1,Yd_out{t}(1,:)','k'); plot(Yw(:,obs_ind),'r');
%     pause
% end

%


%%
% testData.setDataEntry('obsPoints',repmat([true(numObservedSamples,1);false(numSamplesPerEpisode-numObservedSamples,1)],numEpisodes,1));
% 
% fprintf('filtering testData\n');
% i = 1;
% gkkfLearner.gkkf.initialMean = gkkfLearner.gkkf.getEmbeddings(testData.getDataEntry('thetaNoisyWindowsPcaFeatures',i,1));
% gkkfLearner.gkkf.callDataFunction('filterData',testData, i);
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
% data2 = data2(gkkfLearner.gkkf.winKernelReferenceSet.getReferenceSetIndices(),:);
% validTestFeaturesEmbeddings = gkkfLearner.gkkf.getEmbeddings(validTestFeatures);
% validNextTestFeaturesEmbeddings = gkkfLearner.gkkf.getEmbeddings(validNextTestFeatures);
% % validTestFeaturesEmbeddings = gkkfLearner.gkkf.winKernelReferenceSet.kernel.getGramMatrix(data2,validTestFeatures);
% % validNextTestFeaturesEmbeddings = gkkfLearner.gkkf.winKernelReferenceSet.kernel.getGramMatrix(data2,validNextTestFeatures);
% error = (validNextTestFeaturesEmbeddings - gkkfLearner.gkkf.transition(validTestFeaturesEmbeddings));
% 
% %%
% testFeatures = data.getDataEntry('thetaNoisyWindows');
% testFeaturesValidIdx = gkkfLearner.gkkf.winKernelReferenceSet.getReferenceSetIndices;
% validTestFeatures = testFeatures(testFeaturesValidIdx,:);
% validNextTestFeatures = testFeatures(testFeaturesValidIdx+1,:);
% data2 = data.getDataEntry('thetaNoisyWindows');
% data2 = data2(gkkfLearner.gkkf.winKernelReferenceSet.getReferenceSetIndices(),:);
% validTestFeaturesEmbeddings = gkkfLearner.gkkf.getEmbeddings(validTestFeatures);
% validNextTestFeaturesEmbeddings = gkkfLearner.gkkf.getEmbeddings(validNextTestFeatures);
% % validTestFeaturesEmbeddings = gkkfLearner.gkkf.winKernelReferenceSet.kernel.getGramMatrix(data2,validTestFeatures);
% % validNextTestFeaturesEmbeddings = gkkfLearner.gkkf.winKernelReferenceSet.kernel.getGramMatrix(data2,validNextTestFeatures);
% error = (validNextTestFeaturesEmbeddings - gkkfLearner.gkkf.transition(validTestFeaturesEmbeddings));
