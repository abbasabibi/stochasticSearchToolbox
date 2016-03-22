%clear variables;
%close all;
%clear all
%clc

clear Test;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% In this example we see how data manipulation function aliases work.
% A function alias can point to a single data manipulation function or also 
% do a sequence of data manipulation functions.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% create data managers with 2 hierarchical layers (episodes, steps)
dataManager = Data.DataManager('episodes');
dataManagerSteps = Data.DataManager('steps');

% add the data entries add the different layers
dataManager.addDataEntry('parameters', 10);
dataManagerSteps.addDataEntry('actions', 2);
dataManagerSteps.addDataEntry('states', 2);

% connect and finalize the managers!
dataManager.setSubDataManager(dataManagerSteps);
dataManager.finalizeDataManager();

fprintf('Creating new data object, 10 episodes, 10 steps\n');
tic
myData = dataManager.getDataObject([10, 10]);
toc

% create the test class and create parameters
testClass = Data.tests.DataManipulatorTestClass(dataManager);

% sample the data
testClass.callDataFunction('sampleRandomParameters', myData);
parameters = myData.getDataEntry('parameters');

% now add an alias that calls first 'sampleStates' and then 'sampleAction'.
% we can also provide another instance of a data manipulation function.
% the alias then points to the data manipulation function of this instance
testClass.addDataFunctionAlias('sampleStateActions', 'sampleStates');
testClass.addDataFunctionAlias('sampleStateActions', 'sampleActions', testClass);

% call sampling function (because previously we added an alias, now the
% function should call 2 data manipulation functions, sampleStates 
% and sampleActions)
testClass.callDataFunction('sampleStateActions', myData);

% check results, both should be set... (i.e. with one call we sampled both
% states and actions)
myData.getDataEntry('states')
myData.getDataEntry('actions')
