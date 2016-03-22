classdef DiscreteActionInterpreter < Data.DataManipulator
    
    properties (SetAccess=protected)
        discreteActionMap
        
        discreteActionName
        continuousActionName
    end
    
    properties (SetObservable, AbortSet)
    end
    
    
    methods
        
        function obj = DiscreteActionInterpreter(dataManager, discreteActionMap, discreteActionName, continuousActionName)
            obj = obj@Data.DataManipulator(dataManager);

            
            obj.discreteActionMap = discreteActionMap;
            
            if (~exist('discreteActionName','var'))
                discreteActionName = 'discreteActions';            
            end
            
            if (~exist('continuousActionName','var'))
                continuousActionName = 'actions';            
            end
            
            obj.discreteActionName = discreteActionName;
            obj.continuousActionName = continuousActionName;
            
            assert(obj.dataManager.getNumDimensions(continuousActionName) == size(discreteActionMap,2));
            
            depth = obj.dataManager.getDataEntryDepth(obj.continuousActionName);
            subManager = obj.dataManager.getDataManagerForDepth(depth);
            
            subManager.addDataEntry(obj.discreteActionName, 1, 1, size(obj.discreteActionMap,1));
            dataManager.finalizeDataManager();
            obj.addDataManipulationFunction('mapDiscreteAction', {obj.discreteActionName}, {obj.continuousActionName});
            
        end
        
        function [continuousAction] = mapDiscreteAction(obj, discreteActionIndex)
             continuousAction = obj.discreteActionMap(discreteActionIndex, :);
        end
        
    end
end
