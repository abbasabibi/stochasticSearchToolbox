classdef MixtureModel < Distributions.Distribution & Functions.Mapping
    %GAUSSIANMIXTUREMODEL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetObservable,AbortSet)
        numOptions = 1;
        baseInputVariable = '';
    end
    
    properties (SetAccess=protected)
        options = {};
        gating
        isInit = false;
        respName;
    end
    
    methods (Static)
        function [obj] = createPolicySquaredGatingLinearOptions(dataManager)
            optionInitializer = @Distributions.Gaussian.GaussianLinearInFeatures;
            gating = Distributions.Discrete.SoftMaxDistribution(dataManager, 'options', 'statesSquared', 'Gating');
            
            obj = Distributions.MixtureModel.MixtureModel(dataManager, gating, optionInitializer, 'actions', 'states', 'options');
            obj.initObject();
            obj.addDataFunctionAlias('sampleAction', 'sampleFromDistribution');
        end
        
        function [obj] = createPolicy(dataManager, gating, optionInitializer, outputVariables, inputVariables, varargin)
            obj = Distributions.MixtureModel.MixtureModel(dataManager, gating, optionInitializer, outputVariables, inputVariables, varargin{:});
            obj.initObject();
            obj.addDataFunctionAlias('sampleAction', 'sampleFromDistribution');
        end
        
        function [obj] = createParameterPolicy(dataManager, gating, optionInitializer, outputVariables, inputVariables, varargin)
            obj = Distributions.MixtureModel.MixtureModel(dataManager, gating, optionInitializer, outputVariables, inputVariables, varargin{:});
            obj.initObject();
            obj.addDataFunctionAlias('sampleParameter', 'sampleFromDistribution');
        end
    end
    
    methods
        
        %%
        function obj = MixtureModel(dataManager, gating, optionInitializer, outputVariables, inputVariables, optionsName, respName)
            superargs = {};
            if (nargin >= 1)
                superargs = {dataManager, outputVariables, inputVariables};
            end
            
            obj = obj@Functions.Mapping(superargs{:});
            obj = obj@Distributions.Distribution();
            
            obj.setAdditionalInputVariables(optionsName);
            obj.gating = gating;
            
            obj.linkProperty('numOptions');
            
            if(~exist('respName','var') || isempty(respName) )
                obj.respName = 'responsibilities';
            else
                obj.respName = respName;
            end
            
            
            %       obj.addDataManipulationFunction('getDataProbabilitiesAllOptions', [obj.inputVariables, obj.outputVariable, obj.additionalInputVariables{1:end-1}], [obj.dataProbabilityEntries, 'AllOptions']);
            
            
            for i = 1 : obj.numOptions
                obj.options{i} = optionInitializer(dataManager, outputVariables, inputVariables, [optionsName, num2str(i)]); %init weights
            end
            
            obj.addDataManipulationFunction('getDataProbabilities', ...
                {obj.inputVariables, obj.outputVariable, obj.gating.inputVariables}, [obj.options{1}.dataProbabilityEntries{:}]);
            
            
            obj.addDataManipulationFunction('getDataProbabilitiesAllOptions', ...
                {obj.inputVariables, obj.outputVariable}, [obj.options{1}.dataProbabilityEntries{:}, 'oAllOptions']);
            
            obj.addDataManipulationFunction('getDataProbabilitiesSingleOptions', ...
                {obj.inputVariables, obj.outputVariable, obj.additionalInputVariables}, [obj.options{1}.dataProbabilityEntries{:}, 'o']);
            
            obj.addMappingFunction('sampleFromDistributionOption');
            
            
            %             dataManager.addDataEntry(obj.respName, obj.numOptions);
            depth = dataManager.getDataEntryDepth(obj.outputVariable);
            subManager = dataManager.getDataManagerForDepth(depth);
            subManager.addDataEntry(obj.respName, obj.numOptions);
            %             distribution.registerProbabilityNames(dataManager, layerName);
            dataManager.addDataEntryForDepth(depth, optionsName, 1, 1, obj.numOptions);
            
            
            if(isempty(obj.gating.inputVariables))
                obj.addDataManipulationFunction('computeResponsibilities', {obj.outputVariable }, {obj.respName});
            else
                obj.addDataManipulationFunction('computeResponsibilities', {obj.outputVariable, obj.inputVariables{:}, obj.gating.inputVariables{:} }, {obj.respName});
            end
            
            
        end
        
        
        %%
        function setDataProbabilityEntries(obj)
            obj.setDataProbabilityEntries@Distributions.Distribution();
            obj.dataProbabilityEntries{1} = [obj.dataProbabilityEntries{1},'o'];
            
        end
        
        %%
        function initObject(obj)
            obj.initObject@Functions.Mapping();
            
            for i = 1 : obj.numOptions
                obj.options{i}.initObject();
            end
            
            if(~obj.isInit)
                obj.registerSamplingFunctions();
            end
            obj.setDataProbabilityEntries();
            
            %             obj.gating.numItems = obj.numOptions;
            %             obj.gating.initObject();
            %             obj.gating.setOutputVariables(obj.gating.outputVariable);
            
            
            obj.isInit = true;
            
        end
        
        %%
        function registerSamplingFunctions(obj)
            % Add a data alias that connects the sampling from the gating and the
            % sampling from the mixture components
            %First call the sampleFromDistribution function from the gating
            obj.addDataFunctionAlias('sampleFromDistribution', 'sampleFromDistribution', obj.gating);
            % Then call the sampleFromDistributionOption function from this class
            obj.addDataFunctionAlias('sampleFromDistribution', 'sampleFromDistributionOption');
        end
        
        
        %%
        function option = getOption(obj, idx)
            option = obj.options{idx};
        end
        
        %%
        function [value] = sampleFromDistributionOption(obj, numElements, varargin)
            %varargin is [state, option]
            %value is [action]
            
            value = zeros(numElements,obj.dataManager.getNumDimensions(obj.outputVariable));
            for o = 1 : obj.numOptions
                idx   = find(varargin{end}==o);
                if(~isempty(idx))
                    tmp   = cellfun(@(input)(input(idx,:)), varargin,'UniformOutput', false);
                    value(idx,:)  = obj.options{o}.sampleFromDistribution(numel(idx), tmp{1:end-1} );
                end
            end
            
        end
        
        %%
        
        function [logQAso] = getDataProbabilities(obj, inputPolicy, outputPolicy, inputGating)
            logQAso = zeros(size(inputPolicy,1),1);
            if (~isempty(inputGating))
                itemProb = obj.gating.getItemProbabilities(size(inputGating, 1), inputGating);
            else
                itemProb = obj.gating.getItemProbabilities(size(inputGating, 1));                
            end
            
            for o = 1 : obj.numOptions                
                logQAso  = logQAso + itemProb(:,o) .* exp(obj.options{o}.getDataProbabilities(inputPolicy, outputPolicy)); %Missing coefficient?                
            end
            logQAso = log(logQAso);
        end
        
        function [logQAso] = getDataProbabilitiesSingleOptions(obj, varargin)
            logQAso = zeros(size(varargin{1},1),1);
            
            for o = 1 : obj.numOptions
                idx             = find(varargin{end}==o);
                if(~isempty(idx))
                    tmp             = cellfun(@(input)(input(idx,:)), varargin,'UniformOutput', false);
                    logQAso(idx)  = obj.options{o}.getDataProbabilities(tmp{1:end-1}); %Missing coefficient?
                end
            end
            
        end
        
        %%
        function [logQAso] = getDataProbabilitiesAllOptions(obj, varargin)
            logQAso = zeros(size(varargin{2},1),obj.numOptions);
            
            for o = 1 : obj.numOptions
                logQAso(:,o)  = obj.options{o}.getDataProbabilities(varargin{:}); %Missing coefficient?
            end
            
        end
        
        %%
        function [responsibilities, respNormalizers] = computeResponsibilities(obj, actions, policyFeatures, gatingFeatures)
            if(exist('policyFeatures','var'))
                logQAso = obj.getDataProbabilitiesAllOptions(policyFeatures, actions);
                qOs   = obj.gating.getItemProbabilities(size(actions,1),gatingFeatures);
            else
                logQAso = obj.getDataProbabilitiesAllOptions([], actions);
                qOs   = obj.gating.getItemProbabilities(size(actions,1));
            end
            
            
            
            responsibilities = logQAso + log(qOs);
            respNormalizers  = sum(exp(responsibilities),2);
            
            %substract max, then exp then normalize. This is the most stable
            %version of getting the responsibilities
            responsibilities = bsxfun(@minus, responsibilities, max(responsibilities, [], 2));
            responsibilities = exp(responsibilities );
            responsibilities = bsxfun(@rdivide, responsibilities, sum(responsibilities,2));
        end
        
        
        function [] = registerProbabilityNames(obj, dataManager, layerName)
            %             for i = 1:length(obj.dataProbabilityEntries)
            %                 dataManager.addDataEntry([layerName, '.', obj.dataProbabilityEntries{i}], 1);
            %             end
        end
        
        function [outMatrix] = sampleFromDistribution(obj, numElements, inputGating, inputPolicies)
            optionSamples = obj.gating.sampleFromDistribution(numElements, inputGating);
            [optionsUniqe] = unique(optionSamples);
            outMatrix = zeros(size(inputGating, 1), obj.dimOutput);
            for i = 1:length(optionsUniqe)
                outMatrix(optionSamples == optionUnique(i), :) = obj.options{optionUnique(i)}.sampleFromDistribution(numElements, inputPolicies);
            end
        end
        
        
    end
    
end



