Common.clearClasses
clear variables
clc

% obsPointsIdx = [1:5,20];
obsPointsIdx = [1:30];

process_noise = 1;

numEpisodes = 100;

Filter.test.setup.PendulumSampler;
Filter.test.setup.NoisePreprocessor;

monteCarloFilter = Filter.MonteCarloFilter(dataManager,1,1);
monteCarloFilter.initFiltering({'theta','obsPoints'},{'filteredMu','filteredVar'},1);

data = dataManager.getDataObject([20,30]);

sampler.createSamples(data);
noisePrepro.preprocessData(data);

obsPoints = false(numSamplesPerEpisode,1);
obsPoints(obsPointsIdx) = true;
data.setDataEntry('obsPoints',repmat(obsPoints,numEpisodes,1));

monteCarloFilter.sampleShitloadOfData(sampler);

%%
monteCarloFilter.callDataFunction('filterData',data);

filteredMu = data.getDataEntry('filteredMu');
groundtruth = data.getDataEntry('states');

squared_error = (filteredMu(:,1) - groundtruth(:,1)).^2;
mse = sum(squared_error(:)) / length(squared_error(:));

%%

for i = 41:60
%     monteCarloFilter.callDataFunction('filterData',data,i);
    dataStruct = data.getDataStructure();
    hold off;
    Plotter.shadedErrorBar([],dataStruct.steps(i).filteredMu(:,1),2*sqrt(dataStruct.steps(i).filteredVar(:,1)) + .2,'-k',1);
    hold on;
    %plot(testDataStruct.steps(1).filteredMu);
    plot(dataStruct.steps(i).thetaNoisy(:,1))
    plot(dataStruct.steps(i).states(:,1),':');
    pause
end
close all