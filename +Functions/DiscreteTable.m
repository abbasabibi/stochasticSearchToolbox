classdef DiscreteTable < Functions.Mapping & Functions.MappingInterface
    % Discrete Table
    properties (SetAccess = protected)
        tableEntries
        numItems
    end
    
    methods
        function obj = DiscreteTable(dataManager, outputVariable, inputVariable, mappingName)
            obj = obj@Functions.Mapping(dataManager, outputVariable, inputVariable, mappingName);
            range = dataManager.getRange(inputVariable) + 1;
            obj.tableEntries = zeros(range, 1);      
            obj.numItems = range;
        end
        
        function [numItems] = getNumItems(obj)
            numItems = obj.numItems;
        end

        function [values] = getExpectation(obj, numElements, inputs)
            values = obj.tableEntries(inputs);
        end
        
        function [tableEntries] = getTableValues(obj)
            tableEntries = obj.tableEntries;
        end
        
        function [tableEntries] = setTableValues(obj, tableEntries)
            obj.tableEntries = tableEntries;
        end
        
    end
    
    
end
