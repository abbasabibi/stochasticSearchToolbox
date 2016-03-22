clear variables;
close all;

dataManager = Data.DataManager('steps');

dataManager.addDataEntry('states', 2);
dataManager.addDataEntry('actions', 2);

dataManager.finalizeDataManager();

newData = dataManager.getDataObject(100);
newData.setDataEntry('states', randn(100,2));

linearFunction = Functions.FunctionLinearInFeatures(dataManager, 'actions', 'states', 'ActionPolicy');

linearFunction.initObject();

weights = randn(linearFunction.dimOutput, linearFunction.dimInput);
bias =  randn(linearFunction.dimOutput,1);

linearFunction.setWeightsAndBias(weights, bias);
output = linearFunction.callDataFunctionOutput('getExpectation', newData);

%test if everything is ok, should be zero
output - (newData.getDataEntry('states') * weights' + repmat(bias', size(output,1), 1))

% now test the linear features
linearFeatures = FeatureGenerators.LinearFeatures(dataManager, 'states', 1);
linearFunction.setFeatureGenerator(linearFeatures);

weights = randn(linearFunction.dimOutput, linearFunction.dimInput);
bias =  randn(linearFunction.dimOutput,1);

linearFunction.setWeightsAndBias(weights, bias);
output2 = linearFunction.callDataFunctionOutput('getExpectationGenerateFeatures', newData);

% now test the squared features
squaredFeatures = FeatureGenerators.SquaredFeatures(dataManager, 'states', 1:2);
linearFunction.setFeatureGenerator(squaredFeatures);

weights = randn(linearFunction.dimOutput, linearFunction.dimInput);
bias =  randn(linearFunction.dimOutput,1);

linearFunction.setWeightsAndBias(weights, bias);
output3 = linearFunction.callDataFunctionOutput('getExpectationGenerateFeatures', newData);

