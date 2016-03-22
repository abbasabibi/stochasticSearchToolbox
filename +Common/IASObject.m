classdef IASObject < matlab.mixin.Copyable & Common.SettingsClient & dynamicprops
   
   properties
      aliasList     = {};
      settings
      
      isInitialized = false;
   end
   
   % Class methods
   methods 
       
       function obj = IASObject()
          obj.settings = Common.Settings();
       end
       
       function [] = initObject(obj)
            obj.isInitialized = true;
       end
       
       
       
   end
   
end
