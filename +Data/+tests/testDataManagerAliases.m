%clear variables;
%close all;
%clear all
%clc

clear Test;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% In this example we are going to see how to use aliases.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% create data manager
dataManager = Data.DataManager('episodes');

% add data entries, we creat 3 new entries
dataManager.addDataEntry('weights', 10);
dataManager.addDataEntry('goals', 2);
dataManager.addDataEntry('goalVels', 2);

% add an alias
% 'parameters' is the concatenation of 'weights', 'goal', and 'goalVels'
% (hence it has 14 dimensions). Data aliases are not stored in the
% data structure but they can be seen as pointers to other data entries 
dataManager.addDataAlias('parameters', {'weights', 'goals', 'goalVels'});

% we can also use a data alias for a subset of the dimensions of a data
% entry
subIndex = [1:5];
dataManager.addDataAlias('subWeights', {'weights'}, subIndex);

% don't forget to finalize your manager!
dataManager.finalizeDataManager();

fprintf('Creating new data object\n');
tic
myData = dataManager.getDataObject(100);
toc

sizeParam = size(myData.getDataEntry('parameters'));

parameters = randn(sizeParam);

% set parameters (should set weights, goals, and goalVels)
tic
myData.setDataEntry('parameters', parameters)
toc

weights = parameters(:, 1:10);
goals = parameters(:, 11:12);
goalVels = parameters(:, 13:14);

% check wether we did it right...
isequal(parameters, myData.getDataEntry('parameters'))
isequal( weights, myData.getDataEntry('weights') )
isequal(goals, myData.getDataEntry('goals') )
isequal(goalVels, myData.getDataEntry('goalVels') )

isequal( weights(:, subIndex), myData.getDataEntry('subWeights'))
fprintf('If everything is 1 we are fine :)\n')

