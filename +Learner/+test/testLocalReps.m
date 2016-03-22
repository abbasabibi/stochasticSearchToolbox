
close all;
clear variables;

dataManager = Data.DataManager('episodes');

dataManager.addDataEntry('contexts', 1);
dataManager.addDataEntry('parameters', 2);
dataManager.addDataEntry('returns', 1);

dataManager.finalizeDataManager();

featureGenerator = FeatureGenerators.SquaredFeatures(dataManager, 'contexts');

maxfeatures = 100;
kernel = FeatureGenerators.Kernel.ExponentialQuadraticKernel(dataManager, {'contexts'}, ':', maxfeatures);
localREPS = Learner.EpisodicRL.LocalREPS(dataManager,kernel,'returns','contextsSquared','parameters');



newData = dataManager.getDataObject(100);
newData.setDataEntry('contexts', randn(100,1));
newData.setDataEntry('returns', (randn(100,1)).^2);
newData.setDataEntry('parameters', randn(100,2).*2);
featureGenerator.callDataFunction('generateFeatures',newData);


queryState = randn(1,1);

localREPS.updateModel(newData);
localREPS.callDataFunction('sampleFromDistribution',queryState);
%newSample = localREPS.sampleFromDistribution(queryState);





