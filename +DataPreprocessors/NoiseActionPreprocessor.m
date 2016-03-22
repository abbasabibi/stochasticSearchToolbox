classdef NoiseActionPreprocessor < DataPreprocessors.DataPreprocessor & Data.DataManipulator
    
    properties
        
    end
    
    % Class methods
    methods
        function obj = NoiseActionPreprocessor(dataManager)
            obj = obj@DataPreprocessors.DataPreprocessor();
            obj = obj@Data.DataManipulator(dataManager);

            obj.dataManager.addDataEntry('steps.actionsWithNoise', obj.dataManager.getNumDimensions('actions'));
            obj.addDataManipulationFunction('computeActionWithNoise', {'actions', 'actionsNoise'}, {'actionsWithNoise'});
        end
        
        function data = preprocessData(obj, data)
            obj.callDataFunction('computeActionWithNoise', data);
        end
        
        function [actionsWithNoise] = computeActionWithNoise(obj, actions, actionsNoise)
            actionsWithNoise = actions + actionsNoise;                        
        end
    end
end
