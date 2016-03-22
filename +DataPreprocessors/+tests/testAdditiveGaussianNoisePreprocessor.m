

dataManager = Data.DataManager('episodes');
subDataManager = Data.DataManager('steps');
subDataManager.addDataEntry('states',2);
dataManager.setSubDataManager(subDataManager);
dataManager.finalizeDataManager();

additiveGaussianNoisePrepro = DataPreprocessors.AdditiveGaussianNoisePreprocessor(dataManager,.01,'states');
dataManager.finalizeDataManager();


data = dataManager.getDataObject([5, 10]);
states = [ones(data.getNumElementsForDepth(2),1), zeros(data.getNumElementsForDepth(2),1)];
data.setDataEntry('states',states);

additiveGaussianNoisePrepro.preprocessData(data);