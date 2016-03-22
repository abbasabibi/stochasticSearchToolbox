classdef ObservationPointsPreprocessor < DataPreprocessors.DataPreprocessor & Data.DataManipulator
    %GENERATEDATAWINDOWSPREPROCESSOR generates data windows for a given
    %time series.
    % Properties
    % * windowSize  = 4
    % * indexPoint  = 1
    % * inputName
    % * outputName  = <inputName>Windows
    
    properties (AbortSet, SetObservable)
        observationIndices = ':';
        observationPointsDataEntryName = 'obsPoints';
    end
    
    properties 
        name
    end
    
    methods (Static)
        function obj = createFromTrial(trial)
            obj = ObservationPointsPreprocessor(trial.dataManager, trial.observationPointsPreprocessorName);
            obj.observationIndices = find(trial.obsPoints);
        end
    end
    
    methods
        function obj = ObservationPointsPreprocessor(dataManager, preprocessorName)
            obj = obj@DataPreprocessors.DataPreprocessor();
            obj = obj@Data.DataManipulator(dataManager);
            
            obj.name = preprocessorName;
            
            obj.linkProperty('observationIndices',[obj.name '_observationIndices']);
            obj.linkProperty('observationPointsDataEntryName',[obj.name '_observationPointsDataEntryName']);
            
            depth = 2;
            obj.dataManager.addDataEntryForDepth(depth,obj.observationPointsDataEntryName, 1);
            
            obj.addDataManipulationFunction('generateObservationPoints', {}, obj.observationPointsDataEntryName, Data.DataFunctionType.PER_EPISODE);
        end
        
        function [data] = preprocessData(obj, data)
            obj.callDataFunction('generateObservationPoints', data);
        end
        
        function obsPoints = generateObservationPoints(obj, numElements)
            obsPoints = false(numElements,1);
            obsPoints(obj.observationIndices) = true;
        end
    end
    
end

