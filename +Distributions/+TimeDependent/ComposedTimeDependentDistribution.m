classdef ComposedTimeDependentDistribution < Distributions.Distribution & Functions.Mapping
    properties (SetAccess = protected)
        distributionInitializer
        distributionPerTimeStep                
    end
    
    properties (SetObservable,AbortSet)
        numModels
    end
    
    methods
        %%
        function obj = ComposedTimeDependentDistribution(dataManager, distributionInitializer)
            
            superargs = {};
            if (nargin > 1)
                superargs = {dataManager};
            end
            obj = obj@Distributions.Distribution();
            obj = obj@Functions.Mapping(superargs{:});
            
            if (nargin > 0)
                obj.distributionInitializer = distributionInitializer;
            end
            obj.linkProperty('numModels', 'numTimeSteps');          
            
            for i = 1:obj.numModels
                obj.distributionPerTimeStep{i} = obj.distributionInitializer(dataManager);
            end
        
            obj.initializeDataInterfaceFromStepDistributions();
        end
        
        %%
        function obj = initObject(obj)
            obj.initObject@Functions.Mapping();
            for i = 1:obj.numModels
                obj.distributionPerTimeStep{i}.initObject();
            end              
        end     
        
        function [samples] = sampleFromDistribution(obj, numElements, varargin)
            dataManipulationStruct = obj.manipulationFunctions.('sampleFromDistribution');
            samples = obj.callDataFunctionInternalMatrices(dataManipulationStruct, {numElements}, varargin);
        end
        
        function [varargout] = getDataProbabilities(obj, varargin)
            dataManipulationStruct = obj.manipulationFunctions.('getDataProbabilities');
            varargout = callDataFunctionInternalMatrices(dataManipulationStruct, {}, varargin);
        end

        function [] = setInputVariables(obj, varargin)
            for i = 1:obj.numModels
                obj.distributionPerTimeStep{i}.setInputVariables(varargin{:});
            end            
            obj.initializeDataInterfaceFromStepDistributions();
        end
        
        function [] = setOutputVariable(obj, outputVariable)
            for i = 1:obj.numModels
                obj.distributionPerTimeStep{i}.setOutputVariable(outputVariable);
            end            
            obj.initializeDataInterfaceFromStepDistributions();
        end
    end
    
    methods (Access=protected)
          
        function [varargout] = callDataFunctionInternalMatrices(obj, dataManipulationStruct, numElements, data, varargin)            
            nOut = length(dataManipulationStruct.outputArguments); 
                        
            timeSteps = varargin{end};
            numElementsLocal = size(timeSteps, 1);
            
            maxTimeSteps = max(timeSteps);
            minTimeSteps = min(timeSteps);
            
            varargin = {varargin{1:end-1}};
            isFirst = true;
            for i = minTimeSteps:maxTimeSteps
                timeStepIndices = timeSteps == i;
                vararginTimeStep = {};
                for j = 1:length(varargin)
                    vararginTimeStep{j} = varargin{j}(timeStepIndices,:);
                end
                
                if (~isempty(numElements))
                    numElements = {sum(timeStepIndices)};
                end
                [varargoutTimeStep{1:nOut}] = obj.distributionPerTimeStep{i}.(dataManipulationStruct.functionName)(numElements{:}, vararginTimeStep{:});
                
                if (isFirst)
                    for j = 1:nOut
                        varargout{j} = zeros(numElementsLocal,size(varargoutTimeStep{j},2));
                    end
                    isFirst = false;
                end
                
                for j = 1:length(varargout)
                    varargout{j}(timeStepIndices, :) = varargoutTimeStep{j};
                end                
            end
        end        
                                         
        function [] = initializeDataInterfaceFromStepDistributions(obj)
            obj.cloneDataManipulationFunctions(obj.distributionPerTimeStep{1});
                        
            
            functionNames = fieldnames(obj.manipulationFunctions);
            for i = 1:length(functionNames)
%                inputArgs = obj.manipulationFunctions.(functionNames{i}).inputArguments;
                obj.manipulationFunctions.(functionNames{i}).inputArguments{end + 1} = 'timeSteps';                
            end            
            
            obj.dimInput = obj.dataManager.getNumDimensions(obj.inputVariables);
            obj.dataProbabilityEntries = obj.distributionPerTimeStep{1}.dataProbabilityEntries;
        end
    end
    
end