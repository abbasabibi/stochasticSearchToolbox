Common.clearClasses;
close all;
clc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% In this example we are going to see how to access the data-entries in the
% restricted or unrestricted form. Restricted means that the data is
% limited between minRange and maxRange. The restricted entry can be
% obtained by prepending "restricted" and first letter upper case
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% create data manager
dataManager = Data.DataManager('episodes');

% add data entries, we creat 1 new entries with different max ranges
dataManager.addDataEntry('actions', 5, -ones(1,5) * 2, ones(1,5));
% don't forget to finalize your manager!
dataManager.finalizeDataManager();

fprintf('Creating new data object\n');
tic
myData = dataManager.getDataObject(100);
toc

sizeParam = size(myData.getDataEntry('actions'));

actions = randn(sizeParam) * 2;

% set parameters (should set weights, goals, and goalVels)
tic
myData.setDataEntry('actions', actions)
toc

% The actions can be accesed in the standard way
actionsData = myData.getDataEntry('actions');
% If we want to access the restricted data entry, we need to 
% prepend "restricted". Note that the "restricted" is a keyword 
% and not stored as an own data entry
actionsDataRestricted = myData.getDataEntry('restrictedActions');

minRange = dataManager.getMinRange('actions');
maxRange = dataManager.getMaxRange('actions');

actionsRestricted = bsxfun(@max, bsxfun(@min, actions, maxRange), minRange);


% check wether we did it right...
isequal(actions, actionsData)
isequal( actionsDataRestricted, actionsRestricted )


