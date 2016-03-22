classdef RandomEventPreprocessor < DataPreprocessors.DataPreprocessor & Data.DataManipulator
    %ADDITIVEGAUSSIANNOISEPREPROCESSOR adds gaussian noise to given data
    % Properties
    % * sigma       = 1
    % * inputName
    % * outputName  = <inputName>RandomEvent
    % 
    
    
    
    properties (AbortSet, SetObservable)
        inputNames;
        outputNames
        eventProbability = 1/30;
        eventFunction = @(d) d + pi/4;
    end
    
    properties (SetAccess=protected)
        name
    end
    
    methods
        function obj = RandomEventPreprocessor(dataManager, preprocessorName)
            obj = obj@DataPreprocessors.DataPreprocessor();
            obj = obj@Data.DataManipulator(dataManager);
            
            obj.name = preprocessorName;
            
            obj.linkProperty('inputNames',[obj.name '_inputNames']);
            if ~iscell(obj.inputNames)
                obj.inputNames = {obj.inputNames};
            end
            
            obj.outputNames = cellfun(@(in) [in 'Noisy'],obj.inputNames,'UniformOutput', false);
            obj.linkProperty('outputNames',[obj.name '_outputNames']);
            assert(length(obj.inputNames) == length(obj.outputNames));
            
            obj.linkProperty('eventProbability',[obj.name '_eventProbability']);
            obj.unlinkProperty([obj.name '_eventProbability']);
            obj.linkProperty('eventFunction',[obj.name '_eventFunction']);
            
            % add data manipulation function
            for i = 1:length(obj.inputNames)
                i_name = obj.inputNames{i};
                o_name = obj.outputNames{i};
                level = dataManager.getDataEntryDepth(i_name);
                dataManager.addDataEntryForDepth(level, o_name, dataManager.getNumDimensions(i_name));
                dataManager.setPeriodicity(o_name,dataManager.getPeriodicity(i_name));
            end
            
            obj.addDataManipulationFunction('getNoisyVariates', obj.inputNames, obj.outputNames);
        end
        
        function varargout = getNoisyVariates(obj, varargin)
            varargout = cell(size(varargin));
            
            if obj.eventProbability == 0
                varargout = varargin;
                return
            end
            
            for i = 1:length(varargin)
                data = varargin{i};
                eventIdx = find(rand(size(data)) <= obj.eventProbability);
                
                data(eventIdx) = obj.eventFunction(data(eventIdx));
                varargout{i} = data;
            end
        end
        
        function [data] = preprocessData(obj, data)
            obj.callDataFunction('getNoisyVariates',data);
        end 
    end
    
end

