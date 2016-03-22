clear variables;
close all;

dataManager = Data.DataManager('steps');

dataManager.addDataEntry('states', 2);
dataManager.addDataEntry('actions', 2);

dataManager.finalizeDataManager();

newData = dataManager.getDataObject(100);
newData.setDataEntry('states', randn(100,2));

gaussianDistribution = Distributions.Gaussian.GaussianLinearInFeatures(dataManager, 'actions', 'states', 'ActionPolicy');

gaussianDistribution.initObject();

weights = randn(gaussianDistribution.dimOutput, gaussianDistribution.dimInput);
bias =  randn(gaussianDistribution.dimOutput,1);

gaussianDistribution.setWeightsAndBias(weights, bias);

gaussianDistribution.callDataFunction('sampleFromDistribution', newData);
samples = newData.getDataEntry('actions');
mean = gaussianDistribution.callDataFunctionOutput('getExpectation', newData);

cov(samples - mean)

dataProbabilities = gaussianDistribution.callDataFunctionOutput('getDataProbabilities', newData);