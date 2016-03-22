Common.clearClasses
close all;

rng(1)

dataManager = Data.DataManager('episodes');
dataManager.addDataEntry('states', 1, -ones(1,1), ones(1,1));
dataManager.addDataEntry('actions', 1, -ones(1,1), ones(1,1));
dataManager.addDataEntry('weights', 1, zeros(1,1), ones(1,1));


settings = Common.Settings();
settings.setProperty('GPVarianceNoiseFactorActions', 10^-1);
settings.setProperty('maxSizeReferenceSet', 10);
settings.setProperty('GPLearnerActions', 'GPStandard');


numSamples = 100;
states = sort(rand(numSamples,1)*2*pi);
actions = [cos(states) + randn(size(states)) * 0.2];%, sin(states) + randn(size(states)) * 0.1];
weights = rand(numSamples, 1);

statesTest = linspace(0, 2 * pi, 100)';
actionsTest = [cos(statesTest)];%, sin(statesTest)];

kernel = Kernels.ExponentialQuadraticKernel(dataManager, 1, 'stateKernel');

GP = Kernels.GPs.GaussianProcess(dataManager, kernel, 'actions', 'states');

kernelReferenceSetLearner = Kernels.Learner.RandomKernelReferenceSetLearner(dataManager, GP);
kernelBandWidthLearner = Kernels.Learner.MedianBandwidthSelectorAndGPVariance(dataManager, GP, []);
hyperParameterLearner = Kernels.Learner.GPHyperParameterLearnerMarginalLikelihood(dataManager, GP, []);
hyperParameterLearnerLOOCV = Kernels.Learner.GPHyperParameterLearnerLOOCVLikelihood(dataManager, GP, []);
hyperParameterLearnerTestSet = Kernels.Learner.GPHyperParameterLearnerTestSetLikelihood(dataManager, GP, []);

kernelReferenceSetLearner.setWeightName('weights');
kernelBandWidthLearner.setWeightName('weights');
hyperParameterLearner.setWeightName('weights');
hyperParameterLearnerLOOCV.setWeightName('weights');
hyperParameterLearnerTestSet.setWeightName('weights');

hyperParameterLearner.initObject();
hyperParameterLearnerLOOCV.initObject();
hyperParameterLearnerTestSet.initObject();
hyperParameterLearnerTestSet.initObject();


data = dataManager.getDataObject(numSamples);
data.setDataEntry('states', states);
data.setDataEntry('actions', actions);
data.setDataEntry('weights', weights);

kernelReferenceSetLearner.updateModel(data);
kernelBandWidthLearner.updateModel(data);

tic
[meanGP, sigmaGP] = GP.getExpectationAndSigmaFunction(size(statesTest,1), statesTest);
toc

figure;

referenceSetIndices = GP.getReferenceSetIndices();

Plotter.shadedErrorBar(statesTest, meanGP(:,1), 2 * sigmaGP(:,1));
hold all;
%Plotter.shadedErrorBar(statesTest, meanGP(:,2), 2 * sigmaGP(:,2));
plot(states, actions, '*');
plot(statesTest, actionsTest, 'r');
plot(states(referenceSetIndices,:), actions(referenceSetIndices,:), 'm*');

dataTest = dataManager.getDataObject(size(statesTest,1));

dataTest.setDataEntry('states', statesTest);
dataTest.setDataEntry('actions', actionsTest);

GP.getHyperParameters()

likelihoodTest = mean(GP.callDataFunctionOutput('getDataProbabilities', data))

hyperParameterLearner.processTrainingData(data);
hyperParameterLearnerLOOCV.processTrainingData(data);

likelihood = hyperParameterLearner.objectiveFunction()
likelihoodCV = hyperParameterLearnerLOOCV.objectiveFunction()






% Now optimize the hyper parameters with the marginal log likelihood

hyperParameterLearner.debugMessages = true;
tic 
hyperParameterLearner.updateModel(data);
toc

[meanGP, sigmaGP] = GP.getExpectationAndSigmaFunction(size(statesTest,1), statesTest);

figure;
Plotter.shadedErrorBar(statesTest, meanGP(:,1), 2 * sigmaGP(:,1));
hold all;
%Plotter.shadedErrorBar(statesTest, meanGP(:,2), 2 * sigmaGP(:,2));
plot(states, actions, '*');
plot(statesTest, actionsTest, 'r');
plot(states(referenceSetIndices,:), actions(referenceSetIndices,:), 'm*');

dataTest = dataManager.getDataObject(size(statesTest,1));

dataTest.setDataEntry('states', statesTest);
dataTest.setDataEntry('actions', [cos(statesTest)]);%, sin(statesTest)]);

GP.getHyperParameters()


likelihoodTest = mean(GP.callDataFunctionOutput('getDataProbabilities', data))

likelihood = hyperParameterLearner.objectiveFunction()
likelihoodCV = hyperParameterLearnerLOOCV.objectiveFunction()





% Now optimize the hyper parameters with the LOOCV
hyperParameterLearnerLOOCV.debugMessages = true;
tic 
hyperParameterLearnerLOOCV.updateModel(data);
toc

[meanGP, sigmaGP] = GP.getExpectationAndSigmaFunction(size(statesTest,1), statesTest);

figure;

Plotter.shadedErrorBar(statesTest, meanGP(:,1), 2 * sigmaGP(:,1));
hold all;
%Plotter.shadedErrorBar(statesTest, meanGP(:,2), 2 * sigmaGP(:,2));
plot(states, actions, '*');
plot(statesTest, actionsTest, 'r');
plot(states(referenceSetIndices,:), actions(referenceSetIndices,:), 'm*');


GP.getHyperParameters()


likelihoodTest = mean(GP.callDataFunctionOutput('getDataProbabilities', data))

likelihood = hyperParameterLearner.objectiveFunction(GP.getHyperParameters())
likelihoodCV = hyperParameterLearnerLOOCV.objectiveFunction(GP.getHyperParameters())



% Now optimize the hyper parameters with the 2 fold CV GP
hyperParameterLearnerTestSet.debugMessages = true;
tic 
hyperParameterLearnerTestSet.updateModel(data);
toc

[meanGP, sigmaGP] = GP.getExpectationAndSigmaFunction(size(statesTest,1), statesTest);

figure;

Plotter.shadedErrorBar(statesTest, meanGP(:,1), 2 * sigmaGP(:,1));
hold all;
%Plotter.shadedErrorBar(statesTest, meanGP(:,2), 2 * sigmaGP(:,2));
plot(states, actions, '*');
plot(statesTest, actionsTest, 'r');
plot(states(referenceSetIndices,:), actions(referenceSetIndices,:), 'm*');


GP.getHyperParameters()


likelihoodTest = mean(GP.callDataFunctionOutput('getDataProbabilities', data))

likelihood = hyperParameterLearner.objectiveFunction(GP.getHyperParameters())
likelihoodCV = hyperParameterLearnerLOOCV.objectiveFunction(GP.getHyperParameters())


%%%% Sparse GP

settings.setProperty('GPLearnerActions', 'GPSparse');
settings.unregisterProperty('ParameterMapGPOptimizationActions');
hyperParameterLearnerTestSetSparse = Kernels.Learner.GPHyperParameterLearnerTestSetLikelihood(dataManager, GP, kernelReferenceSetLearner);
hyperParameterLearnerTestSetSparse.initObject();


% Now optimize the hyper parameters with the sparse GP
hyperParameterLearnerTestSetSparse.debugMessages = true;
tic 
hyperParameterLearnerTestSetSparse.updateModel(data);
toc

[meanGP, sigmaGP] = GP.getExpectationAndSigmaFunction(size(statesTest,1), statesTest);

figure;

Plotter.shadedErrorBar(statesTest, meanGP(:,1), 2 * sigmaGP(:,1));
hold all;
%Plotter.shadedErrorBar(statesTest, meanGP(:,2), 2 * sigmaGP(:,2));
plot(states, actions, '*');
plot(statesTest, actionsTest, 'r');
plot(states(referenceSetIndices,:), actions(referenceSetIndices,:), 'm*');
