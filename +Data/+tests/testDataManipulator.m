%clear variables;
%close all;
%clc

clear Test;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% In this example we are going to see how manipulate data.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% create data managers with 2 hierarchical layers (episodes, steps)
dataManager = Data.DataManager('episodes');
dataManagerSteps = Data.DataManager('steps');

% add the data entries to each layer
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

% create the test class
testClass = Data.tests.DataManipulatorTestClass(dataManager);

% now we can call the data manipulation function. It is called with 10
% numElements as we have 10 episodes in the data structure
testClass.callDataFunction('sampleRandomParameters', myData);
% now all the parameters should be set to 1 (look in the test class why)
parameters = myData.getDataEntry('parameters')

% we can also use the standard hierarchical indexing here,
% e.g., only call the function for the first 5 elements
myData.setDataEntry('parameters', ones(10,10) * 50);
testClass.callDataFunction('sampleRandomParameters', myData, 1:5);

% now the first 5 parameters should be set to 1
parameters = myData.getDataEntry('parameters')

% now we call the function 'sampleStates'
% NB: the function 'callDataFunction' is just an interface, then the class 
% 'DataManipulatorTestClass' has a function called 'sampleStates'
testClass.callDataFunction('sampleStates', myData); % put a break point into the function to see what is happening

% look at the first state of all episodes
states = myData.getDataEntry('states', :, 1)

% do the same with the sampleAction function. This time we only want to do 
% that for the first action of all episodes (look at the indicing)
testClass.callDataFunction('sampleActions', myData, :, 1);

% get all first actions
actions = myData.getDataEntry('actions', :, 1)

% get all second actions
actions = myData.getDataEntry('actions', :, 2)

% we can also call the functions without storing it in the data structure.
% In this case, we get back the output arguments of the function as a
% matrix.
actions = testClass.callDataFunctionOutput('sampleActions', myData, :, 1)
