/**
\package Common

This package contains the base class for all classes in the toolbox (IASObject). 
The base class provides a simple management of the settings using a 
parameter pool. See Common.Settings and Common.IASObject. The Common package is still 
under construction, but the main functionality that is required is there. The parameter 
pool functionality is implemented by two main classes:
 - Common.Settings: This class represents a parameter pool. There is a global parameter pool
 which can be accessed by Common.Settings(). There is also the option to create individual
 parameter pools. The parameter pool maintains a list of parameters and the corresponding
 values. Whenever a value is changed, the objects that maintain this parameter will 
 be informed (and their data member will be changed). However, this basic functionality 
 so far only works at the creation of the objects, if a parameter is changed on runtime 
 the other objects will NOT be informed. 
 - Common.SettingsClient: Every IASObject is a SettingsClient. Clients can link properties to the global
 parameter pool with the method Common.SettingsClient.linkProperties. Properties can be linked with the 
 same name as used within the class or with a different external name. If a property is linked and the 
 property alreay exists in the parameter pool, the value from the parameter pool is used to overwrite the
 value of the property of the object. If the property does not exist in the parameter pool, it 
 property is registered in the parameter pool. The value in the parameter pool is in this case set
 to the current value of the local property. 

Please also consult the test scripts (+Common/+tests/testSettings.m) as small tutorial.

*/
