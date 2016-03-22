Common.clearClasses;
close all;
rng(0)

settings = Common.Settings();
settings.setProperty('GPVarianceNoiseFactorActions', 10^-1);
settings.setProperty('maxNumOptiIterationsGPOptimizationNextStates', 1000);
settings.setProperty('CMANumRestarts', 1);
settings.setProperty('maxSizeReferenceSet', 800);
settings.setProperty('GPLearnerNextStates', 'GPSparse');
settings.setProperty('kernelMedianBandwidthFactor', 5.0);
settings.setProperty('ParameterMapGPOptimizationNextStates', logical([1 1 1 1 1 1 1 1 1 1 1]));

settings.setProperty('GPOptimizationNextStatesOptiAlgorithm', 'CMA-ES');
settings.setProperty('GPOptimizationNextStatesOptiAbsfTol', 10^-3);

% Please run the script Environments.DynamicalSystems.tests.testQuadLink
% before
load('+Environments/+DynamicalSystems/+tests/quadLinkTrajectories.mat');

rng(2)

initializer = @Kernels.GPs.GaussianProcess.CreateSquaredExponentialGP;
GPcomposite = Kernels.GPs.CompositeOutputModel(dataManager, 'nextStates', 'states', initializer);

learnerInitializer = @Kernels.Learner.GPHyperParameterLearnerTestSetLikelihood.CreateWithStandardReferenceSet;
GPcompositeLearner = Kernels.GPs.CompositeOutputModelLearner(dataManager, GPcomposite, learnerInitializer);

for i = 1:length(GPcompositeLearner.compositeOutputModelLearner)
    GPcompositeLearner.compositeOutputModelLearner{i}.debugMessages = true;
end

testData = dataManager.getDataObject();
testData.copyValuesFromDataStructure(newData2.dataStructure);

trainData = testData.cloneDataSubSet(1:200);
testData = testData.cloneDataSubSet(201:1000);
% 
% 
% %% Do the whole thing with CMA-ES
% tic
% GPcompositeLearner.updateModel(trainData);
% toc
% tic
% likelihoodTestCMA = sum(GPcomposite.callDataFunctionOutput('getDataProbabilities', testData)) / testData.getNumElementsForDepth(2)
% toc
% likelihoodCMA = GPcompositeLearner.sumCompositeLearnerFunctions('objectiveFunction') / trainData.getNumElementsForDepth(2)

%% Do the whole thing with fminunc
rng(1);
settings.setProperty('GPOptimizationNextStatesOptiAlgorithm', 'FMinUnc');

GPcompositeLearner = Kernels.GPs.CompositeOutputModelLearner(dataManager, GPcomposite, learnerInitializer);

tic
GPcompositeLearner.compositeOutputModelLearner{1}.updateModel(trainData);
toc
% tic
% likelihoodTestFMinUnc = sum(GPcomposite.callDataFunctionOutput('getDataProbabilities', testData)) / testData.getNumElementsForDepth(2)
% toc
% likelihoodFMinUnc = GPcompositeLearner.sumCompositeLearnerFunctions('objectiveFunction') / trainData.getNumElementsForDepth(2)

%%
rng(1);
settings.setProperty('GPOptimizationNextStatesOptiAlgorithm', 'NLOPT_LN_PRAXIS');

GPcompositeLearner = Kernels.GPs.CompositeOutputModelLearner(dataManager, GPcomposite, learnerInitializer);


for i = 1:length(GPcompositeLearner.compositeOutputModelLearner)
    GPcompositeLearner.compositeOutputModelLearner{i}.debugMessages = true;
    GPcompositeLearner.compositeOutputModelLearner{i}.initializerParams.updateReferenceSet = false;
    
end

tic
GPcompositeLearner.compositeOutputModelLearner{1}.updateModel(trainData);
toc
% tic
% likelihoodTestNLOpt = sum(GPcomposite.callDataFunctionOutput('getDataProbabilities', testData)) / testData.getNumElementsForDepth(2)
% toc
% likelihoodNLOpt = GPcompositeLearner.sumCompositeLearnerFunctions('objectiveFunction') / trainData.getNumElementsForDepth(2)


