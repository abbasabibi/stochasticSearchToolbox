
classdef CompositeOutputModel < Distributions.DistributionWithMeanAndVariance & Functions.Mapping & Functions.Function
    %Gaussian Process Policy  Selecting actions according to GP
    %   GP fitted on weighted samples
    %   conditioned on S, policy is a Gaussian
    
    properties (SetObservable, AbortSet)
       
    end
    
    properties
        outputModels      
    end
    
    methods
        function obj = CompositeOutputModel(dataManager, varOut, varIn, outputModelInitializer)
            
            obj = obj@Distributions.DistributionWithMeanAndVariance();
            obj = obj@Functions.Mapping(dataManager, varOut, varIn, 'GaussianProcess');
            
            numDimensions = dataManager.getNumDimensions(varOut);
            for i = 1:numDimensions
                obj.outputModels{i} = outputModelInitializer(dataManager, varOut, varIn, i);
            end       
            
            obj.registerMappingInterfaceDistribution();
        end
        
        function [] = initObject(obj)
            obj.initObject@Functions.Mapping()            
            for i = 1:numel(obj.outputModels)
                if ismethod(obj.outputModels{i},'initObject' )
                    obj.outputModels{i}.initObject()
                end
            end               
        end
        
        function [] = setHyperParameters(obj, hyperParameters)           
            index = 1;
            for i = 1:length(obj.kernels)
                obj.outputModels{i}.setHyperParameters(hyperParameters(index : (index + obj.outputModels{i}.getNumHyperParameters() - 1)));
                index = index + obj.outputModels{i}.getNumHyperParameters();
            end

        end
        
        function [params] = getHyperParameters(obj)
            params = cell2mat(cellfun(@(outputModel) outputModel.getHyperParameters(), obj.outputModels, 'UniformOutput', false))';

        end
        
        function [numParameters] = getNumHyperParameters(obj)
            numParameters = 0;
            for i = 1:length(obj.outputModels{i})
                numParameters = numParameters + obj.outputModels{i}.getNumHyperParameters();
            end
        end
        
        function [sumVal] = sumCompositeModelFunctions(obj, functionName, varargin)
            sumVal = 0;
            
            for i = 1:length(obj.outputModels)
               sumVal = sumVal + obj.outputModels{i}.(functionName)(varargin{:});
            end
        end
        
        function [outputModel] = getOutputModel(obj, index)
            outputModel = obj.outputModels{index};
        end        
        
        function [numModels] = getNumModels(obj)
            numModels = length(obj.outputModels);
        end
        
        function [meanGP] = getExpectation(obj, numElements, inputData)
            meanGP = obj.getExpectationAndSigma(numElements, inputData);
        end
        
        function [meanGP, sigmaGP] = getExpectationAndSigma(obj, numElements, inputData)
            if (nargout == 1)
                meanGP = zeros(size(inputData,1), length(obj.outputModels));
                
                for i = 1:length(obj.outputModels)
                    meanGP(:,i) = obj.outputModels{i}.getExpectationAndSigma(numElements, inputData);
                end
            else
                meanGP = zeros(size(inputData,1), length(obj.outputModels));
                sigmaGP = zeros(size(inputData,1), length(obj.outputModels));
                for i = 1:length(obj.outputModels)                    
                    [meanGP(:,i), sigmaGP(:,i)] = obj.outputModels{i}.getExpectationAndSigma(numElements, inputData);
                end                
            end            
        end
                               
    end
end

