clear variables;
close all;

dataManager = Data.DataManager('episodes');
dataManager.addDataEntry('states', 1, -ones(1,1), ones(1,1));
dataManager.addDataEntry('actions', 2, -ones(1,1), ones(1,1));

settings = Common.Settings.createNewSettings();
settings.setProperty('GPVarianceNoiseFactorActions', 10^-6);

numSamples = 10;
states = sort(rand(numSamples,1)*2*pi);
actions = [cos(states), sin(states)];
statesTest = linspace(0, 2 * pi, 100)';

initializer = @Kernels.GPs.GaussianProcess.CreateSquaredExponentialGP;
GPcomposite = Kernels.GPs.CompositeOutputModel(dataManager, 'actions', 'states', initializer);

learnerInitializer = @Kernels.Learner.MedianBandwidthSelectorAndGPVariance.CreateWithStandardReferenceSet;
GPcompositeLearner = Kernels.GPs.CompositeOutputModelLearner(dataManager, GPcomposite, learnerInitializer);

data = dataManager.getDataObject(numSamples);
data.setDataEntry('states', states);
data.setDataEntry('actions', actions);

GPcompositeLearner.updateModel(data);

[meanGP, sigmaGP] = GPcomposite.getExpectationAndSigma(size(statesTest,1), statesTest);

figure;

Plotter.shadedErrorBar(statesTest, meanGP(:,1), 2 * sigmaGP(:,1));
hold all;
Plotter.shadedErrorBar(statesTest, meanGP(:,2), 2 * sigmaGP(:,2));
plot(states, actions, '*');

dataTest = dataManager.getDataObject(size(statesTest,1));

dataTest.setDataEntry('states', statesTest);
dataTest.setDataEntry('actions', [cos(statesTest), sin(statesTest)]);

likelihoodTest = mean(GPcomposite.callDataFunctionOutput('getDataProbabilities', data))