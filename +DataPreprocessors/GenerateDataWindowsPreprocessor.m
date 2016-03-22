classdef GenerateDataWindowsPreprocessor < DataPreprocessors.DataPreprocessor & Data.DataManipulator
    %GENERATEDATAWINDOWSPREPROCESSOR generates data windows for a given
    %time series.
    % Properties
    % * windowSize  = 4
    % * indexPoint  = 1
    % * inputName
    % * outputName  = <inputName>Windows
    
    properties (AbortSet, SetObservable)
        windowSize = {4};
        indexPoint = 1;
        inputNames = 'inputs';
        outputNames = 'outputs';
    end
    
    properties 
        name
        
        inputDimensions
        outputDimensions
    end
    
    methods
        function obj = GenerateDataWindowsPreprocessor(dataManager, preprocessorName)
            obj = obj@DataPreprocessors.DataPreprocessor();
            obj = obj@Data.DataManipulator(dataManager);
            
            obj.name = preprocessorName;
            
            obj.linkProperty('windowSize',[obj.name '_windowSize']);
            
            obj.linkProperty('indexPoint',[obj.name '_indexPoint']);
            
            obj.linkProperty('inputNames',[obj.name '_inputNames']);
            if ~iscell(obj.inputNames)
                obj.inputNames = {obj.inputNames};
            end
            
            obj.outputNames = cellfun(@(in) [in 'Windows'],obj.inputNames,'UniformOutput', false);
            obj.linkProperty('outputNames',[obj.name '_outputNames']);
            if ~iscell(obj.outputNames)
                obj.outputNames = {obj.outputNames};
            end
            
            assert(length(obj.inputNames) == length(obj.outputNames));
            outputValidNames = cellfun(@(on) [on 'Valid'], obj.outputNames,'UniformOutput', false);
            if not(iscell(obj.windowSize))
                obj.windowSize = {obj.windowSize};
            end
            if length(obj.windowSize) == 1
                obj.windowSize = repmat(obj.windowSize,1,length(obj.inputNames));
            end
            for i = 1:length(obj.inputNames)
                i_name = obj.inputNames{i};
                o_name = obj.outputNames{i};
                obj.inputDimensions{i} = dataManager.getNumDimensions(i_name);
                obj.outputDimensions{i} = obj.inputDimensions{i} * obj.windowSize{i};
                depth = dataManager.getDataEntryDepth(i_name);
                
                obj.dataManager.addDataEntryForDepth(depth,o_name, obj.outputDimensions{i});
                obj.dataManager.addDataEntryForDepth(depth,outputValidNames{i}, 1);
                
                % add data alias for each dimensions
                for d = 1:obj.inputDimensions{i}
                    subIndex = d:obj.inputDimensions{i}:obj.outputDimensions{i};
                    obj.dataManager.addDataAlias([o_name '_' num2str(d)],o_name,subIndex);
                end
            end
            
            obj.addDataManipulationFunction('generateDataWindows', obj.inputNames, obj.outputNames, Data.DataFunctionType.PER_EPISODE);
            obj.addDataManipulationFunction('validateDataWindows', obj.outputNames, outputValidNames, Data.DataFunctionType.PER_EPISODE);
        end
        
        function [data] = preprocessData(obj, data)
            obj.callDataFunction('generateDataWindows', data);
            obj.callDataFunction('validateDataWindows', data);
        end
        
        function varargout = generateDataWindows(obj, varargin)
            varargout = cell(size(varargin));
            
            % for each data entry
            for i = 1:length(varargin)
                data = varargin{i};
                % check number of elements
                numElements = size(data,1);
                % create array of nans
                dataWindows = nan * ones(numElements,obj.outputDimensions{i});
                
                if iscell(obj.indexPoint)
                    index_point = obj.indexPoint{i};
                else
                    index_point = obj.indexPoint;
                end
            
                % construct windows
                for j = 1:obj.windowSize{i}
                    % range of the window
                    outputRange = (j-1)*obj.inputDimensions{i}+1 : j*obj.inputDimensions{i};
                    % shift in the window matrix according to the index point
                    writeRange = max(1,index_point - j + 1) : min(numElements, numElements - j + index_point);
                    % shift in the data matrix according to the index point
                    dataRange = max(1,j-index_point+1):min(numElements,numElements-index_point+j);

                    dataWindows(writeRange,outputRange) = data(dataRange,:);
                end
                
                varargout{i} = dataWindows;
            end
        end
    end
    
    methods (Static)
        function varargout = validateDataWindows(varargin)
            varargout = cell(size(varargin));
            
            for i = 1:length(varargin)
                is_nan = any(isnan(varargin{i}),2);
                is_nan_idx = find(is_nan);
                if not(isempty(is_nan_idx)) && is_nan_idx(1) == 1
                    is_nan(is_nan_idx(2:end)-1) = true;
                else
                    is_nan(is_nan_idx-1) = true;
                end
                
                % the last window has to be invalid, since we need it as
                % successive window.
                is_nan(end) = true;
                    
                varargout{i} = not(is_nan);
            end
        end
    end
    
end

