classdef MixtureModelWithTermination < Distributions.MixtureModel.MixtureModel
    %GAUSSIANMIXTUREMODEL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetObservable,AbortSet)
    end
    
    properties (SetAccess=protected)
        terminationPolicyInitializer
        terminationMM
        optionsName
        optionsOldName
        terminationName
    end
    
    
    methods (Static)
        function [obj] = createPolicy(dataManager, gating, optionInitializer, outputVariables, ...
                inputVariables, inputVariablesTermination, terminationPolicyInitializer, optionsName, optionsOldName)
            
            obj = Distributions.MixtureModel.MixtureModelWithTermination(dataManager, gating, optionInitializer, outputVariables, ...
                inputVariables, inputVariablesTermination, terminationPolicyInitializer, optionsName, optionsOldName);
            
            obj.initObject();
            
            obj.addDataFunctionAlias('sampleAction', 'sampleFromDistribution');
        end
        
        function [obj] = createParameterPolicy(dataManager, gating, optionInitializer, outputVariables, ...
                inputVariables, inputVariablesTermination, terminationPolicyInitializer, optionsName, optionsOldName)
            
            obj = Distributions.MixtureModel.MixtureModelWithTermination(dataManager, gating, optionInitializer, outputVariables, ...
                inputVariables, inputVariablesTermination, terminationPolicyInitializer, optionsName, optionsOldName);
            
            obj.initObject();
            obj.addDataFunctionAlias('sampleParameter', 'sampleFromDistribution');
        end
        
        
    end
    
    methods
        
        %%
        function obj = MixtureModelWithTermination(dataManager, gating, optionInitializer, outputVariables, ...
                inputVariables, inputVariablesTermination, terminationPolicyInitializer, optionsName, optionsOldName)
            superargs = {};
            if (nargin >= 1)
                superargs = {dataManager, gating, optionInitializer, outputVariables, inputVariables, optionsName};
                superargsTermination = {dataManager, terminationPolicyInitializer, inputVariablesTermination, 'terminations', optionsOldName};
            end
            

            
            obj = obj@Distributions.MixtureModel.MixtureModel(superargs{:});
            
            if(~exist('optionsOldName','var'))
                optionsOldName = 'optionsOld';
            end
            
            obj.optionsName = optionsName;
            obj.optionsOldName = optionsOldName;
            
            

            obj.setAdditionalInputVariables(optionsOldName);

            obj.terminationPolicyInitializer = terminationPolicyInitializer;

            obj.terminationMM = Distributions.MixtureModel.TerminationMixtureModel(superargsTermination{:});
            
            obj.terminationName = obj.terminationMM.getTerminationName();
 
           
                  
        end
        
        
        %%
        function initObject(obj)
       
            obj.initObject@Distributions.MixtureModel.MixtureModel();
            
            obj.terminationMM.initObject();
            
        end
        
         %%
        function registerSamplingFunctions(obj)
             %First call the terminationDistribution
            obj.addDataFunctionAlias('sampleFromDistribution', 'sampleTerminationEvent', obj.terminationMM);
             % Add a data alias that connects the sampling from the gating and the
            % sampling from the mixture components            
            %First call the sampleFromDistribution function from the gating
            obj.addDataFunctionAlias('sampleFromDistribution', 'sampleFromDistribution', obj.gating);
            
            obj.addDataManipulationFunction('setOptionAfterTermination', ...
                {obj.optionsName, obj.optionsOldName, obj.terminationName}, [obj.optionsName]);
            
            
            obj.addDataFunctionAlias('sampleFromDistribution', 'setOptionAfterTermination');
            
            % Then call the sampleFromDistributionOption function from this class
            obj.addDataFunctionAlias('sampleFromDistribution', 'sampleFromDistributionOption');
        end
        
        
        
        %%
        function [options] = setOptionAfterTermination(obj, options, optionsOld, termination) %this termination is now a matrix. I hope
            %2 is not terminated. Selects new options if no initial option
            %is set.
            options(termination==2) = optionsOld(termination==2);
        end
        
        
        
        
        
    end
    
end



