clear variables;
close all;

addpath('~/svn_projects/sl/clmc');
indexFile = fopen('~/data/autonomous_data/log_file_key.txt');
C = textscan(indexFile, '%s %s\n');

index = 1;

[D, vars, freq] = clmcplot_convert(sprintf('~/data/autonomous_data/%s', C{2}{index}));

for i = 1:length(vars)
    fprintf('%d: %s\n', i, vars(i).name);
end

dataManager = Data.DataManager('episodes');
subDataManager = Data.DataManager('steps');

dataManager.setSubDataManager(subDataManager);


dataManager.addDataEntry('trajectoryIndex', 1);
dataManager.addDataEntryForDepth(2, 'electrodes', 19);
dataManager.addDataEntryForDepth(2, 'fastFrequencySignals', 22);

dataManager.addDataEntryForDepth(2, 'handPositions', 3);
dataManager.addDataEntryForDepth(2, 'handVelocities', 3);
dataManager.addDataEntryForDepth(2, 'zVelocities', 1);

dataManager.addDataEntryForDepth(2, 'pressure', 1);
dataManager.addDataEntryForDepth(2, 'contactPositions', 3);
dataManager.addDataEntryForDepth(2, 'contactNormals', 3);


indexTrainL = repmat([true(1,5), false(1,5)], 1, 42);
indexTestL = not(indexTrainL);

indexTrain = find(indexTrainL);
indexTest = find(indexTestL);

indexSet{1} = indexTrain;
indexSet{2} = indexTest;

dataManager.addDataAlias('states', {'pressure', 'electrodes', 'zVelocities'});
dataManager.addDataAlias('outputs', {'handVelocities'});


dataManager.finalizeDataManager();


index_electrodes = 150:168;
index_electrodes_mean = 287:305;
index_high_frequency = 169:190;
index_pressure = 193;

index_handPositions = 72:74;
index_handVelocities = 75:77;

index_contactPositions = 275:277;
index_contactNormals = 281:283;


for j = 1:length(indexSet)
    
    data{j} = dataManager.getDataObject(length(indexSet{j}));
    
    index_l = indexSet{j};
    for i = 1:length(index_l)
        index = index_l(i);
        [D, vars, freq] = clmcplot_convert(sprintf('~/data/autonomous_data/%s', C{2}{index}));

        pressure = D(:, index_pressure);
        pressureMean = mean(pressure(1:300));
        pressure = pressure - pressureMean;
        firstIndex = find(pressure > 5, 1);
        lastIndex = find(pressure > 5, 2, 'last');
        if (~isempty(lastIndex))
       
            lastIndex = lastIndex(1);

            numElements = lastIndex - firstIndex + 1;

            data{j}.reserveStorage(numElements, i);
            data{j}.setDataEntry('pressure', pressure(firstIndex:lastIndex,:), i);

            data{j}.setDataEntry('electrodes', D(firstIndex:lastIndex,index_electrodes) - D(firstIndex:lastIndex,index_electrodes_mean), i);
            data{j}.setDataEntry('fastFrequencySignals', D(firstIndex:lastIndex,index_high_frequency), i);
            data{j}.setDataEntry('handPositions', D(firstIndex:lastIndex, index_handPositions), i);
            %velocity in data is shit, compute on our own from the positions
            data{j}.setDataEntry('handVelocities', diff(D(firstIndex:(lastIndex + 1), index_handPositions)) / 0.01, i);
            data{j}.setDataEntry('zVelocities', diff(D(firstIndex:(lastIndex + 1), index_handPositions(end))) / 0.01, i);

            data{j}.setDataEntry('contactPositions', D(firstIndex:lastIndex, index_contactPositions), i);
            data{j}.setDataEntry('contactNormals', D(firstIndex:lastIndex, index_contactNormals), i);


            data{j}.setDataEntry('pressure', pressure(firstIndex:lastIndex,:), i);
        end
    end
end

dataTrainingStruct = data{1}.dataStructure;
dataTestStruct = data{2}.dataStructure;


save('data/Tactile/dataTactile.mat', 'dataTrainingStruct', 'dataTestStruct', 'dataManager');
dataCell = data;

data = dataCell{1};
save('data/Tactile/dataTactile_train.mat', 'data');

data = dataCell{2};
save('data/Tactile/dataTactile_test.mat', 'data');


