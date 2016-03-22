clear variables;
close all;
rng(0)

dataManager = Data.DataManager('episodes');
dataManager.addDataEntry('states', 1, -ones(1,1), ones(1,1));
dataManager.addDataEntry('actions', 2, -ones(1,1), ones(1,1));

settings = Common.Settings();
settings.setProperty('GPVarianceNoiseFactorActions', 10^-1);
settings.setProperty('maxNumOptiIterations', 300);
settings.setProperty('CMANumRestarts', 5);
settings.setProperty('maxSizeReferenceSet', 10);
settings.setProperty('GPLearnerActions', 'GPSparse');

numSamples = 60;
states = sort(rand(numSamples,1)*2*pi);
actions = [cos(states) + randn(size(states,1),1) * 0.01, sin(3 * states) + randn(size(states,1),1) * 0.1];
statesTest = linspace(0, 2 * pi, 100)';

rng(2)

initializer = @Kernels.GPs.GaussianProcess.CreateSquaredExponentialGP;
GPcomposite = Kernels.GPs.CompositeOutputModel(dataManager, 'actions', 'states', initializer);

learnerInitializer = @Kernels.Learner.GPHyperParameterLearnerTestSetLikelihood.CreateWithStandardReferenceSet;
GPcompositeLearner = Kernels.GPs.CompositeOutputModelLearner(dataManager, GPcomposite, learnerInitializer);

GPcompositeLearner.compositeOutputModelLearner{1}.debugMessages = true;
GPcompositeLearner.compositeOutputModelLearner{2}.debugMessages = true;

data = dataManager.getDataObject(numSamples);
data.setDataEntry('states', states);
data.setDataEntry('actions', actions);

tic
GPcompositeLearner.updateModel(data);
toc

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
likelihood = GPcompositeLearner.sumCompositeLearnerFunctions('objectiveFunction')

