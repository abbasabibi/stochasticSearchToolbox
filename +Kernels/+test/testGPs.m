clear variables;
close all;
Common.clearClasses;

dataManager = Data.DataManager('episodes');
dataManager.addDataEntry('states', 1, -ones(1,1), ones(1,1));
dataManager.addDataEntry('actions', 2, -ones(1,1), ones(1,1));

settings = Common.Settings.createNewSettings();
settings.setProperty('GPVarianceNoiseFactorActions', 10^-6);

numSamples = 10;
states = sort(rand(numSamples,1)*2*pi);
actions = [cos(states), sin(states)];
statesTest = linspace(0, 2 * pi, 100)';

kernel = Kernels.ExponentialQuadraticKernel(dataManager, 1, 'stateKernel');

GP = Kernels.GPs.GaussianProcess(dataManager, kernel, 'actions', 'states');

kernelReferenceSetLearner = Kernels.Learner.RandomKernelReferenceSetLearner(dataManager, GP);
kernelBandWidthLearner = Kernels.Learner.MedianBandwidthSelectorAndGPVariance(dataManager, GP, kernelReferenceSetLearner);


data = dataManager.getDataObject(numSamples);
data.setDataEntry('states', states);
data.setDataEntry('actions', actions);

kernelBandWidthLearner.updateModel(data);

[meanGP, sigmaGP] = GP.getExpectationAndSigmaFunction(size(statesTest,1), statesTest);

figure;

Plotter.shadedErrorBar(statesTest, meanGP(:,1), 2 * sigmaGP(:,1));
hold all;
Plotter.shadedErrorBar(statesTest, meanGP(:,2), 2 * sigmaGP(:,2));
plot(states, actions, '*');

dataTest = dataManager.getDataObject(size(statesTest,1));

dataTest.setDataEntry('states', statesTest);
dataTest.setDataEntry('actions', [cos(statesTest), sin(statesTest)]);


likelihoodTest = mean(GP.callDataFunctionOutput('getDataProbabilities', data))


