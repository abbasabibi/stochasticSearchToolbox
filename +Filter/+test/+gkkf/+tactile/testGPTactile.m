Common.clearClasses;
close all;
rng(0)

settings = Common.Settings();

settings.setProperty('GPVarianceNoiseFactorOutputs', 10^-1);
settings.setProperty('maxNumOptiIterationsGPOptimizationOutputs', 0);
settings.setProperty('CMANumRestarts', 1);
settings.setProperty('maxSizeReferenceSet', 1000);
settings.setProperty('GPLearnerOutputs', 'GPSparse');
settings.setProperty('kernelMedianBandwidthFactor', 5.0);

% Please run the script Environments.DynamicalSystems.tests.testQuadLink
% before
load('+Filter/+test/+gkkf/+tactile/dataTactile.mat');


rng(2)
current_data_pipe = {'states'};
Filter.test.setup.WindowPreprocessor


initializer = @Kernels.GPs.GaussianProcess.CreateSquaredExponentialGP;
GPcomposite = Kernels.GPs.CompositeOutputModel(dataManager, 'outputs', current_data_pipe{1}, initializer);

learnerInitializer = @Kernels.Learner.GPHyperParameterLearnerTestSetLikelihood.CreateWithStandardReferenceSet;
GPcompositeLearner = Kernels.GPs.CompositeOutputModelLearner(dataManager, GPcomposite, learnerInitializer);

for i = 1:length(GPcompositeLearner.compositeOutputModelLearner)
    GPcompositeLearner.compositeOutputModelLearner{i}.debugMessages = true;
end

dataTraining = dataManager.getDataObject(0);
dataTest = dataManager.getDataObject(0);

dataTraining.copyValuesFromDataStructure(dataTrainingStruct);
dataTest.copyValuesFromDataStructure(dataTestStruct);

windowsPrepro.preprocessData(dataTraining);
windowsPrepro.preprocessData(dataTest);

tic
GPcompositeLearner.updateModel(dataTraining);
toc

input = dataTest.getDataEntry(current_data_pipe{1});
validId = not(any(isnan(input),2));

tic
likelihoodTest = GPcomposite.callDataFunctionOutput('getDataProbabilities', dataTest);
likelihoodTest = sum(likelihoodTest(validId)) / sum(validId);
toc

likelihood = - GPcompositeLearner.sumCompositeLearnerFunctions('objectiveFunction') / dataTraining.getNumElementsForDepth(2)

for i = 1:20
    handPos = dataTest.getDataEntry('handPositions', i);
    output = dataTest.getDataEntry('outputs',i);
    [prediction, predictionSigma] = GPcomposite.callDataFunctionOutput('getExpectationAndSigma', dataTest, i); 

    figure(1);
    clf;
    Plotter.shadedErrorBar(1:length(prediction), prediction(:,1), predictionSigma(:,1) * 2);
    hold all;
    plot(output(:,1));

    
    figure(2);
    clf;
    Plotter.shadedErrorBar(1:length(prediction), prediction(:,2), predictionSigma(:,2) * 2);
    hold all;
    plot(output(:,2));

    
    figure(3);
    clf;
    Plotter.shadedErrorBar(1:length(prediction), prediction(:,3), predictionSigma(:,3) * 2);
    hold all;
    plot(output(:,3));

    figure(4);
    plot(handPos);
    pause;
end