classdef MixtureModelExploration < Distributions.MixtureModel.MixtureModelWithTermination
    %GAUSSIANMIXTUREMODEL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetObservable,AbortSet)
    end
    
    properties (SetAccess=protected)
        parametersOldName = 'parametersOld';
    end
    
    
    methods (Static)
        function [obj] = createPolicy(dataManager, gating, optionInitializer, outputVariables, ...
                inputVariables, inputVariablesTermination, terminationPolicyInitializer, optionsName, optionsOldName)
            
            obj = Distributions.MixtureModel.MixtureModelExploration(dataManager, gating, optionInitializer, outputVariables, ...
                inputVariables, inputVariablesTermination, terminationPolicyInitializer, optionsName, optionsOldName);
            
            obj.initObject();
            
            obj.addDataFunctionAlias('sampleAction', 'sampleFromDistribution');
        end
        
        function [obj] = createParameterPolicy(dataManager, gating, optionInitializer, outputVariables, ...
                inputVariables, inputVariablesTermination, terminationPolicyInitializer, optionsName, optionsOldName)
            
            obj = Distributions.MixtureModel.MixtureModelExploration(dataManager, gating, optionInitializer, outputVariables, ...
                inputVariables, inputVariablesTermination, terminationPolicyInitializer, optionsName, optionsOldName);
            
            obj.initObject();
            obj.addDataFunctionAlias('sampleParameter', 'sampleFromDistribution');
        end
        
        
    end
    
    methods
        
        %%
        function obj = MixtureModelExploration(dataManager, gating, optionInitializer, outputVariables, ...
                inputVariables, inputVariablesTermination, terminationPolicyInitializer, optionsName, optionsOldName)
            superargs = {};
            if (nargin >= 1)
                superargs = {dataManager, gating, optionInitializer, outputVariables, inputVariables, ...
                    inputVariablesTermination, terminationPolicyInitializer, optionsName, optionsOldName};
            end
            
            obj = obj@Distributions.MixtureModel.MixtureModelWithTermination(superargs{:});
            
            obj.setAdditionalInputVariables(obj.parametersOldName);
                  
        end
        
        

         %%
        function registerSamplingFunctions(obj)
            obj.registerSamplingFunctions@Distributions.MixtureModel.MixtureModelWithTermination();
            
            obj.addDataManipulationFunction('setParametersAfterTermination', ...
                {obj.outputVariable, obj.parametersOldName, obj.terminationName}, [obj.outputVariable]);            
        end
        
        
        %%
        function [parameters] = setParametersAfterTermination(obj, parameters, parametersOld, termination) %this termination is now a matrix. I hope
            %2 is not terminated. Selects new options if no initial option
            %is set.
            parameters(termination==2) = parametersOld(termination==2);
        end
        
        
    end
    
end



