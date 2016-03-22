

dataManager = Data.DataManager('episodes');
subDataManager = Data.DataManager('steps');
subDataManager.addDataEntry('states',2);
dataManager.setSubDataManager(subDataManager);

generateDataWindowsPrepro = DataPreprocessors.GenerateDataWindowsPreprocessor(dataManager,3);

dataManager.finalizeDataManager();

data = dataManager.getDataObject([5, 10]);
states = [(1:data.getNumElementsForDepth(2))', zeros(data.getNumElementsForDepth(2),1)];
data.setDataEntry('states',states);

generateDataWindowsPrepro.indexPoint = 2;
generateDataWindowsPrepro.preprocessData(data);