classdef AbstractFilter < Data.DataManipulator
    %ABSTRACTFILTER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        stateDims
        obsDims
        outputDims
    end
    
    methods
        function obj = AbstractFilter(dataManager, stateDims, obsDims)
            obj = obj@Data.DataManipulator(dataManager);
            
            obj.stateDims = stateDims;
            obj.obsDims = obsDims;
            obj.outputDims = stateDims;
        end
        
        function initFiltering(obj, observationNames, outputNames, outputDims)
            obj.outputDims = outputDims;
            
            % register data entries at the same depth as the observations
            depth = obj.getDataManager().getDataEntryDepth(observationNames{1});
            for i = 1:length(outputNames)
                if not(obj.getDataManager().isDataEntry(outputNames{i}) || obj.getDataManager().isDataAlias(outputNames{i}))
                    obj.getDataManager().addDataEntryForDepth(depth,outputNames{i},sum(cell2mat(outputDims)));
                end
            end
            
            % register data manipulation function
            obj.addDataManipulationFunction('filterData', observationNames, outputNames, Data.DataFunctionType.PER_EPISODE);
        end
        
        function [varargin] = outputTransformation(varargin)
        end
    end
    
    methods(Abstract)
        varargout = filterData(obj, observations, observationPoints, outputIdx);
    end
    
end

