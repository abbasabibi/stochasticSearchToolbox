clear variables;
close all;

dataManager = Data.DataManager('steps');

dataManager.addDataEntry('actions', 2);


[XX, YY] = meshgrid(-5:2:5, -5:2:5);
discreteActionMap = [XX(:),YY(:)];

discreteActionInterpreter = Distributions.Discrete.DiscreteActionInterpreter(dataManager, discreteActionMap);

dataManager.finalizeDataManager();
newData = dataManager.getDataObject(100);

constantDistribution = Distributions.Discrete.ConstantDiscreteDistribution(dataManager, discreteActionInterpreter.discreteActionName, 'ActionPolicy');

constantDistribution.initObject();
constantDistribution.setDiscreteActionInterpreter(discreteActionInterpreter);

constantDistribution.callDataFunction('sampleFromDistribution', newData);
