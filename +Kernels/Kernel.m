classdef Kernel < Common.IASObject & Learner.ParameterOptimization.HyperParameterObject
    %KERNEL Base class for kernels
    % compute gram matrices of the form
    %   -------------------------------------------
    %   | k(x(1,:),y(1,:) | k(x(1,:),y(2,:) | ... |
    %   -------------------------------------------
    %   | k(x(2,:),y(1,:) | k(x(2,:),y(2,:) | ... |
    %   -------------------------------------------
    %   | ...             | ...             | ... |
    %   -------------------------------------------
    properties
        numDims;

        kernelName
        dataManager
        
        referenceSet = [];
        
        kernelTag = 1;
    end
    
    methods (Abstract)
        [params] = getHyperParameters(obj)
        [numParams] = getNumHyperParameters(obj)
        
        [G] = getGramMatrix(data1, data2)
        
        [gradientMatrices, gramMatrix] = getKernelDerivParam(data)
        [g] = getKernelDerivData(refdata, curdata)
        
        
    end
    

    
    methods (Static)
        function kernelProduct =  createKernelSQEPeriodic(dataManager, inputVariables, name)
            if(~exist('name','var'))
                name = 'Kernel';
            end
            periodicStates = logical(dataManager.getPeriodicity(inputVariables));
            
            if (any(periodicStates))
                kernelPeriodic = Kernels.PeriodicKernel(dataManager, sum(periodicStates), 'Periodic');
                kernelSQ = Kernels.ExponentialQuadraticKernel(dataManager, sum(~periodicStates), 'NonPeriodic');
          
                kernelProduct = Kernels.ProductKernel(dataManager, numel(periodicStates), {kernelPeriodic, kernelSQ}, {periodicStates, ~periodicStates}, name);            
            else
                kernelProduct = Kernels.ExponentialQuadraticKernel(dataManager, sum(~periodicStates), name);          
            end
            
        end
        
        
    end
    
    
    
    methods
               
        function obj = Kernel(dataManager, numDims, name)
            obj = obj@Common.IASObject();
            obj.dataManager = dataManager;
            obj.numDims = numDims;
            obj.kernelName = name;
        end
        
        
        function [] = setHyperParameters(obj, params)
            obj.kernelTag = obj.kernelTag + 1;
        end
        
        
        function [v] = getGramDiag(obj, data)
            % get diagonal elements of gram matrix, i.e. kernel evaluated
            % between every datapoint and itself
            v = zeros(size(data,1),1);
            for i = 1:size(data,1)
                v(i) = obj.getGramMatrix(data(i,:), data(i, :));
            end
        end               
        
       
        
        function [tag] = getKernelTag(obj)
            tag = obj.kernelTag;
        end
                                        
    end
    
end

