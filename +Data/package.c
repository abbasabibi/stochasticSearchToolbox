/**
\package Data 

This package contains the classes that are responsible for the data management. 
The data is organized hierarchically. Data-entries can be registered at different 
layers of the hierarchy, e.g., we can specify a data entry for the episodes (e.g., parameters)
or for the steps of an episodes (e.g. states and actions). The data entries and the 
hierarchy are defined by the Data.DataManager class, where we need an individual 
DataManager per level of the hierarchy. Each data manager can have a sub-datamanager, 
that defines the next level of the hiearchy. If a data manager does not have a sub-datamanager, 
it is the last level of the hierarchy. 

The DataManager is also used to create the Data.Data object. The object contains 
a data structure that again contains all data entries that have been registered 
by the data manager. The data structure also contains a structure array that 
contains all the data entries of the lower level of the hierarchies. So far, 
three levels of the hierarchy are supported.

Finally, the DataManipulator class defines the interfaces for manipulating the data structure. 
Every DataManipulator can publish its data-manipulation functions. For each data 
manipulation function, we have to specify the input and the output data entries. 
If we call a function with the data manipulation interface (DataManipulator.callDataFunction), 
the input arguments get automatically parsed out of the data structure and are put in as matrices 
for the function call. The output arguments of the function are also automatically stored back 
in the data structure. Almost every object that is supposed to change a data object 
is implemented as DataManipulator. This includes sampling episodes from differen 
environments, policies, learned forward models or reward functions.

Please consult the test files +test/testDataManager.m, +test/testDataManagerAliases.m 
and +test/testDataManipulator.m, which you can use as small tutorials.

*/
