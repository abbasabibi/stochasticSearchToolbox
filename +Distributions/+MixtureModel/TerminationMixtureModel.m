classdef TerminationMixtureModel < Functions.Mapping
    %GAUSSIANMIXTUREMODEL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetObservable,AbortSet)
        numOptions = 1;
    end
    
    properties (SetAccess=protected)
        terminations = {};
        terminationName;
    end
    
    methods
        
        %%
        function obj = TerminationMixtureModel(dataManager, optionInitializer, inputVariables, optionsName, optionsOldName)
            superargs = {};
            if (nargin >= 1)
                superargs = {dataManager, optionsName, inputVariables};
            end
            
            obj = obj@Functions.Mapping(superargs{:});
            
            obj.setAdditionalInputVariables(optionsOldName);
            
            obj.linkProperty('numOptions');
            
            for i = 1 : obj.numOptions
                obj.terminations{i} = optionInitializer(dataManager, optionsName, inputVariables,...
                    [optionsName, num2str(i)]); %init weights
            end
            
            obj.terminationName = 'terminations';
            
            obj.addDataManipulationFunction('getDataProbabilitiesAllOptions', ...
                [obj.inputVariables, obj.outputVariable, obj.additionalInputVariables{1:end-1}], [obj.terminations{1}.dataProbabilityEntries{:}, 'terminationAllOptions']);
            
            obj.addDataManipulationFunction('getDataProbabilities', ...
                [obj.inputVariables, obj.outputVariable, obj.additionalInputVariables{1:end-1}], [obj.terminations{1}.dataProbabilityEntries{:}, 'termination']);
            
            obj.addMappingFunction('sampleTerminationEvent');
            
            
        end
        
        
        %%
        function setDataProbabilityEntries(obj)
            obj.setDataProbabilityEntries@Distributions.Distribution();
            obj.dataProbabilityEntries{1} = [obj.dataProbabilityEntries{1},'termination'];
            
        end
        
        %%
        function initObject(obj)
            obj.initObject@Functions.Mapping();
            
            for i = 1 : obj.numOptions
                obj.terminations{i}.initObject();
            end
            
        end
        
        
        %%
        function option = getTerminationOption(obj, idx)
            option = obj.terminations{idx};
        end
        
        %%
        function [value] = sampleTerminationEvent(obj, numElements, varargin)
            %varargin is [state, oldOption]
            %value is [action]
            
            value = zeros(numElements,obj.dataManager.getNumDimensions(obj.outputVariable));
            for o = 1 : obj.numOptions
                idx   = find(varargin{end}==o);
                if(~isempty(idx))
                    tmp   = cellfun(@(input)(input(idx,:)), varargin,'UniformOutput', false);
                    value(idx,:)  = obj.terminations{o}.sampleFromDistribution(numel(idx), tmp{1:end-1} );
                end
            end
            
        end
        
        %%
        function [logQBso] = getDataProbabilities(obj, varargin)
            logQBso = zeros(size(varargin{1},1),1);
            
            for o = 1 : obj.numOptions
                idx             = find(varargin{end}==o);
                if(~isempty(idx))
                    tmp             = cellfun(@(input)(input(idx,:)), varargin,'UniformOutput', false);
                    logQBso(idx)  = obj.terminations{o}.getDataProbabilities(tmp{1:end-1}); %Missing coefficient?
                end
            end
            
        end
        
        %%
        function [logQBso] = getDataProbabilitiesAllOptions(obj, varargin)
            logQBso = zeros(size(varargin{1},1),obj.numOptions);
            
            for o = 1 : obj.numOptions
                logQBso(:,o)  = obj.terminations{o}.getDataProbabilities(varargin{:},1); %Missing coefficient?
            end
            
        end
        
        
        %%
        function [terminatioName] = getTerminationName(obj)
            terminatioName = obj.terminationName;
        end
        
        
    end
    
end



