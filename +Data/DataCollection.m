classdef DataCollection < Common.IASObject
   
    properties
        dataMap;
    end
    
    methods
        
        function obj = DataCollection(standardData)
            obj.dataMap = containers.Map;
            obj.dataMap('data') = standardData;
        end
        
        function [] = addDataObject(obj, data, dataName)
            obj.dataMap(dataName) = data;
        end
        
        function [data] = getStandardData(obj)
            data = obj.dataMap('data');
        end
        
        function [data] = getDataObjectForName(obj, dataName)
            data = obj.dataMap(dataName);
        end
        
    end
    
end