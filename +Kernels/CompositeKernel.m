classdef CompositeKernel < Kernels.Kernel
    %Product of kernels
    
    properties
        kernels
        stateIndices
    end
    
    methods(Abstract, Access = protected)
        cpObj = copyElement(obj)
    end
    
    methods
        function obj = CompositeKernel(dataManager, numDims, kernels, stateIndices, kernelName)
            
            obj@Kernels.Kernel(dataManager, numDims, kernelName);
            
            obj.kernels = kernels;
            obj.stateIndices = stateIndices;
            
            for i = 1:length(stateIndices)
                if (~islogical(stateIndices{i}))
                    temp = false(1, numDims);
                    temp(obj.stateIndices{i}) = true;
                    obj.stateIndices{i} = temp;
                end
            end
            
        end
        
        function [numParams] = getNumHyperParameters(obj)
            numParams = 0;
            
            for i = 1:length(obj.kernels)
                numParams = numParams + obj.kernels{i}.getNumHyperParameters();
            end
            
        end
        
        function [params] = getHyperParameters(obj)
            params = cell2mat(cellfun(@(kernel) kernel.getHyperParameters(), obj.kernels, 'UniformOutput', false));
        end
        
        function [] = setHyperParameters(obj, params)
            obj.setHyperParameters@Kernels.Kernel(params);
            
            index = 1;
            for i = 1:length(obj.kernels)
                obj.kernels{i}.setHyperParameters(params(index : (index + obj.kernels{i}.getNumHyperParameters() - 1)));
                index = index + obj.kernels{i}.getNumHyperParameters();
            end
        end
        
        function [params] = getBandWidth(obj)
            bandWidth = zeros(1, numel(obj.stateIndices{1}));
            for i = 1:length(bandWidth)
                bandWidth(obj.stateIndices{i}) = obj.kernel{i}.getBandWidth();
            end
        end
        
        function [] = setBandWidth(obj, params)     
            obj.kernelTag = obj.kernelTag + 1;
            for i = 1:length(obj.kernels)
                obj.kernels{i}.setBandWidth(params(obj.stateIndices{i}));
            end
        end
        

        
    end
    
    
    
end

