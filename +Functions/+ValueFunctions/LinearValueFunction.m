classdef LinearValueFunction < Functions.FunctionLinearInFeatures
    properties (SetAccess = protected)
                
    end
    
    properties (SetObservable, AbortSet)
    end
    
    methods
                
        function obj = LinearValueFunction(dataManager)
            superargs = {};
            subManager = dataManager.getDataManagerForName('steps');
            subManager.addDataEntry('stateValues', 1);
            dataManager.finalizeDataManager();
            
            if (nargin >= 1)
                superargs = {dataManager, 'stateValues', {'stateFeatures'}, 'VFunction'};
            end
            
            obj = obj@Functions.FunctionLinearInFeatures(superargs{:});            
        end
    end
end
