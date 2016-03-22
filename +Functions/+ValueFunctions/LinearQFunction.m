classdef LinearQFunction < Functions.FunctionLinearInFeatures
    properties (SetAccess = protected)
                
    end
    
    properties (SetObservable, AbortSet)
    end
    
    methods
                
        function obj = LinearQFunction(dataManager, featureName, outputFeature)
            superargs = {};
            if ~exist('outputFeature','var')
                outputFeature = 'qValues';
            end
            
            subManager = dataManager.getDataManagerForName('steps');
            subManager.addDataEntry(outputFeature, 1);
            dataManager.finalizeDataManager();
            
            if (~exist('featureName', 'var'))
                featureName = 'stateActionFeatures';
            end
            if (nargin >= 1)
                superargs = {dataManager, outputFeature, {featureName}, 'QFunction'};
            end
            
            
            obj = obj@Functions.FunctionLinearInFeatures(superargs{:});            
        end
    end
end
