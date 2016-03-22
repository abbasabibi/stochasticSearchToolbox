clear variables;
close all;

dataManager = Data.DataManager('steps');

dataManager.addDataEntry('states', 2);
dataManager.addDataEntry('actions', 2);

linearFunction = Functions.FunctionLinearInFeatures(dataManager, 'actions', 'states', 'ActionPolicy');

linearFeatures = FeatureGenerators.LinearFeatures(dataManager, 'states', 1:2, 1);
linearFunction.setFeatureGenerator(linearFeatures);

dataManager.finalizeDataManager();
linearFunction.initObject();

newData = dataManager.getDataObject(100);
newData.setDataEntry('states', randn(100,2));

weights = randn(linearFunction.dimOutput, linearFunction.dimInput);
bias =  randn(linearFunction.dimOutput,1);

linearFunction.setWeightsAndBias(weights, bias);
output = linearFunction.callDataFunctionOutput('getExpectation', newData);

%test if everything is ok, should be zero
output - (newData.getDataEntry('states') * weights' + repmat(bias', size(output,1), 1))

%test if feature recomputing works
newData.setDataEntry('states', randn(10,2), 1:10);
newData.setDataEntry('statesLinearTag', -ones(10,1), 1:10);

output = linearFunction.callDataFunctionOutput('getExpectation', newData);
%test if everything is ok, should be zero
output - (newData.getDataEntry('states') * weights' + repmat(bias', size(output,1), 1))

