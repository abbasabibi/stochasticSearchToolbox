classdef NormalizedDataPreprocessor < DataPreprocessors.DataPreprocessor & Data.DataManipulator
    %GENERATEDATAWINDOWSPREPROCESSOR generates data windows for a given
    %time series.
    % Properties
    % * windowSize  = 4
    % * indexPoint  = 1
    % * inputName
    % * outputName  = <inputName>Windows
    
    properties (AbortSet, SetObservable)
        inputName = 'states';
        validName = 'Valid';
        outputName = 'normalizedStates';
    end
    
    properties 
        name
    end
    
    methods (Static)
        function obj = createFromTrial(trial, name)
            obj = ObservationPointsPreprocessor(trial.dataManager, name);
            obj.inputName = trial.([name 'InputName']);
            obj.outputName = trial.([name 'OutputName']);
            obj.validName = trial.([name 'ValidName']);
        end
    end
    
    methods
        function obj = NormalizedDataPreprocessor(dataManager, preprocessorName)
            obj = obj@DataPreprocessors.DataPreprocessor();
            obj = obj@Data.DataManipulator(dataManager);
            
            obj.name = preprocessorName;
            
            obj.linkProperty('inputName',[obj.name '_inputName']);
            obj.linkProperty('outputName',[obj.name '_outputName']);
            obj.linkProperty('validName',[obj.name '_validName']);
            
            depth = obj.dataManager.getDataEntryDepth(obj.inputName);
            obj.dataManager.addDataEntryForDepth(depth,obj.outputName, 1);
            
            obj.addDataManipulationFunction('normalizeData', {obj.inputName obj.validName}, obj.outputName, Data.DataFunctionType.ALL_AT_ONCE);
        end
        
        function [data] = preprocessData(obj, data)
            obj.callDataFunction('normalizeData', data);
        end
        
        function normalizedData = generateObservationPoints(obj, data, valid)
            data = data(valid,:);
            m = mean(data);
            v = var(data);
            data = bsxfun(@rdivide,bsxfun(@minus,data,m),v);
        end
    end
    
end

