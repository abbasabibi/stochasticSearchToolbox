Common.clearClasses
clear variables;
close all;

window_prediction = true;
output_data_name = 'thetaNoisy';

Filter.test.preludes.pendulumWindowsCeokkf;

obsIndices = 1:30;

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

obsPoints = false(numSamplesPerEpisode,1);
obsPoints(obsIndices) = true;
testData.setDataEntry('obsPoints',repmat(obsPoints,numEpisodes,1));

% 
%%
for i = 1:20
    ceokkfLearner.filter.callDataFunction('filterData',testData, i);
    testDataStruct = testData.getDataStructure();
    hold off;
    plot(testDataStruct.steps(i).filteredMu); hold on
%     plot(testDataStruct.steps(i).thetaNoisy(:,1));
end