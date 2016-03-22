classdef SaltAndPepperNoisePreprocessor < DataPreprocessors.DataPreprocessor & Data.DataManipulator
    %ADDITIVEGAUSSIANNOISEPREPROCESSOR adds gaussian noise to given data
    % Properties
    % * sigma       = 1
    % * inputName
    % * outputName  = <inputName>Noisy
    % 
    
    
    
    properties (AbortSet, SetObservable)
        saltProb = .1;
        pepperProb = .1;
        inputNames;
        outputNames
    end
    
    properties (SetAccess=protected)
        name
    end
    
    methods
        function obj = AdditiveGaussianNoisePreprocessor(dataManager, preprocessorName)
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
            
            obj.linkProperty('sigma',[obj.name '_sigma']);
            
            % check sigma
            l_sigma = length(obj.sigma(:));
            if (l_sigma == 1)
                obj.sigma = eye(dataManager.getNumDimensions(obj.inputNames{1})) * obj.sigma;
            elseif (l_sigma == dataManager.getNumDimensions(obj.inputNames{1}))
                obj.sigma = diag(obj.sigma);
            end
            
            
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
            
            if obj.sigma == 0
                varargout = varargin;
                return
            end
            
            for i = 1:length(varargin)
                varargout{i} = varargin{i} + randn(size(varargin{i})) * chol(obj.sigma);
            end
        end
        
        function [data] = preprocessData(obj, data)
            obj.callDataFunction('getNoisyVariates',data);
        end 
    end
    
end

