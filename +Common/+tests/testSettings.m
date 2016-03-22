Common.clearClasses;
close all
clc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% In this example we are going to work with TestSettingsClass.m. This class
% has 2 properties: 'testProperty1' with default value 1 and 'testProperty2'
% with default value 'Geri'.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% get global settings
settings = Common.Settings();

% set one of the properties defined in the test class
settings.setProperty('testProperty1', 1);

% define one instance of the TestSettingsClass
dummyClass = Common.tests.TestSettingsClass();

% print the values of the parameters
% testProperty1 will be 1 because we redefined it above
% testProperty2 will be the standard value
dummyClass.testProperty1
dummyClass.testProperty2

% now set the other property. In this case the link name is different 
% ('CoolFanzyName', see the class), i.e. we can't do:
% settings.setProperty('testProperty2', 'Prof. Geri');
settings.setProperty('CoolFanzyName', 'Prof. Geri');

% now testProperty2 will be the 'Prof. Geri'
dummyClass.testProperty2

%We can also access the properties directly in the settings
settings.CoolFanzyName = 'Cool';

%Gets directly transfered to the object
dummyClass.testProperty2

%Note that this is not true the other way round:
dummyClass.testProperty2 = 'Cool2';
dummyClass.testProperty2
settings.CoolFanzyName 



