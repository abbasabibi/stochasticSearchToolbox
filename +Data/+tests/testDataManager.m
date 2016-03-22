%clear variables;
%close all;
%clear all
%clc

clear Test;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% In this example we are going to see how data managers work. We will
% create a data manager, fill it with some random data and then learn how
% to retrieve it.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Initialization of the manager
% create data managers with 3 hierarchical layers (episodes, steps,
% subSteps)
dataManager = Data.DataManager('episodes');
subDataManager = Data.DataManager('steps');
subSubDataManager = Data.DataManager('subSteps');

% add data entries to each of the layers
% here we add an entry named 'parameters' with 5 elements in range [-1,1]
dataManager.addDataEntry('parameters', 5, -ones(5,1), ones(5,1));
% here we add an entry named 'context' with 2 elements in range [-1,1]
dataManager.addDataEntry('context', 2, -ones(2,1), ones(2,1));

% so far we have said that an episode his characterized by 5 parameters and
% 2 contexts

% we can check them using
dataManager.getDataEntries{2}
% or
dataManager.dataEntries('parameters')

% now add a data alias
% subParameters is now an alias for the [1 3 5] dimension of parameters
dataManager.addDataAlias('subParameters', 'parameters', [1:2:5]);
dataManager.addDataAlias('subParameters', 'context');

% do the same with the sub-manager: we have states and actions as data for
% each steps
subDataManager.addDataEntry('states', 1, -ones(1,1), ones(1,1));
subDataManager.addDataEntry('actions', 2, -ones(2,1), ones(2,1));

% ... and the same for the sub-sub-manager
subSubDataManager.addDataEntry('subStates', 1, -ones(1,1), ones(1,1));
subSubDataManager.addDataEntry('subActions', 2, -ones(2,1), ones(2,1));

% now we only need to connect the data managers and finalize them 
% (this ALWAYS needs to be done for the root)
dataManager.setSubDataManager(subDataManager);
subDataManager.setSubDataManager(subSubDataManager);
dataManager.finalizeDataManager();

% now we can do
dataManager.subDataManager.getDataEntries{1}'
% to get the first entry for the sub-manager (i.e. 'actions')
% or also
dataManager.subDataManager.dataEntries('actions')

%% Initialization of the data
% so far we have defined the structure of our data
% now we want to create new data

% here we create new data object with 100 episodes, 10 steps and 5 sub-steps 
% (i.e. 5000 substeps in total)
tic
myData = dataManager.getDataObject([100, 10, 5]);
toc

% we can also reserve more data storage (i.e. the matrices for all 
% necessary data entries are enlarged)
tic
myData.reserveStorage([100, 20, 5]);
toc

% with this line we can see how our data is structured
myData.dataEntries

% with the following instead we can see the single entries for each data 
% (all 0 since we just initialized it)
myData.dataStructure

% we can also access the internal data structure in this way
myData.getDataStructure()

% the internal data structure contains a matrix for each data entry on the 
% corresponding layer
size(myData.getDataStructure().parameters)

% it also contains a dataStructure array for the data entries of the next
% layer. E.g., the following command accesses the steps dataStructure of
% the first episode
myData.getDataStructure().steps(1)

% and the following command the subSteps of the first step of the first
% episode
myData.getDataStructure().steps(1).subSteps(1)

%% Generation of random data
% now generate random data ...
actions = randn(myData.getNumElementsForDepth(2),2);
subActions = randn(myData.getNumElementsForDepth(3),2);

fprintf('Setting actions and subactions\n');
tic
% ... and copy them into actions ...
myData.setDataEntry('actions',actions);
toc
tic
% ... and sub-actions
myData.setDataEntry('subActions',subActions);
toc

%% Retrieval of our data
fprintf('Getting actions and subactions\n');
tic
% we can retrieve all our data ...
tempActions = myData.getDataEntry('subActions');
toc

% ... or use indices to access the hierarchical data structure
% and get all subactions of the first data structure 
tempActionsFirstEpisode = myData.getDataEntry('subActions', 1);

% we can also use the ':' sign to specify that we want to have all elements
% of this layer of the hierarchy this commands returns the first subActions 
% of all episodes of the first step. We can specify as many indices as 
% there are layers. If an index is not specified, it is assumed to be ":".
tempActions = myData.getDataEntry('subActions', :, 1, 1);

% indicing also works for the setting functions
myData.setDataEntry('subActions',tempActions + 5, :, 1, 1);

% We can also access the last element with negative indices. NOTE: this is
% only implemented for getting the dataEntry. Works on 2nd and 3rd layer.
% Did not implement on 1st layer
all(myData.getDataEntry('actions', :, -1) == myData.getDataEntry('actions', :, 20))

all(myData.getDataEntry('subActions', :, 1, -1) == myData.getDataEntry('subActions', :, 1, 5))

% we can also access the internal data structure
myData.getDataStructure()
% the internal data structure contains a matrix for each data entry on the 
% corresponding layer
size(myData.getDataStructure().parameters)
% It also contains a datastructure array for the data entries of the next
% layer. E.g., the following command accesses the steps datastructure of
% the first episode
myData.getDataStructure().steps(1)
% And the following command the subSteps of the first step of the first
% episode
myData.getDataStructure().steps(1).subSteps(1)

% getDataEntryCellArray returns several data entries, which are listed in 
% the cell array of the first argument. Also here, we can use the 
% hierarchical indexing. The index is ignored for data entries which are 
% located on a lower layer. I.e., the following command will return the 2nd 
% action of the 1st episode and the 1st subaction of the 2nd step of the 
% 1st episode.

fprintf('Getting multiple entries in cell array, 100 times \n');
tic
for i = 1 : 100
    cellArray = myData.getDataEntryCellArray({{'actions'}, 'subActions'}, 1, 2, 1);
end
toc

cellArray2 = cellArray;
cellArray2{1} = cellArray{1} * 2;
fprintf('Setting multiple entries in cell array, 100 times \n');
tic
for i = 1 : 100
    myData.setDataEntryCellArray({'actions', 'subActions'}, cellArray2, 1, 2, 1);
end
toc

fprintf('Checking results... is it zero?');
cellArray = myData.getDataEntryCellArray({{'actions'}, 'subActions'}, 1, 2, 1);
checkVar = cellArray2{1} - cellArray{1}


fprintf('Thats it, the show is over...\n');
