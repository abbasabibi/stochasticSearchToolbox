classdef AbstractSmoother < Filter.AbstractFilter
    %ABSTRACTSMOOTHER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function obj = AbstractSmoother(dataManager, stateDims, obsDims)
            obj = obj@Filter.AbstractFilter(dataManager, stateDims, obsDims);
        end
        
        function initSmoothing(obj, observationNames, outputNames, outputDims)
            obj.outputDims = outputDims;
            
            % register data entries at the same depth as the observations
            depth = obj.getDataManager().getDataEntryDepth(observationNames{1});
            for i = 1:length(outputNames)
                obj.getDataManager().addDataEntryForDepth(depth,outputNames{i},sum(cell2mat(outputDims)));
            end
            
            % register data manipulation function
            obj.addDataManipulationFunction('smoothData', observationNames, outputNames, Data.DataFunctionType.PER_EPISODE);
        end
    end
    
    methods(Abstract)
        varargout = smoothData(obj, observations, observationPoints, outputIdx);
    end
    
end

