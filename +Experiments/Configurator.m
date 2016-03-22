classdef Configurator < handle;
    
    properties
        name = 'unnamedConfigurator';
        
        parameterSetters = {};
        
        dataPreProcessorsBeginning = {};
        dataPreProcessorsEnd = {};
    end
    
    methods
        
        function preConfigureTrial(obj, trial)
            
        end
        
        function postConfigureTrial(obj, trial)
            
        end
        
        function obj = Configurator(name)
            obj.name = name;
        end
        
        function obj = addParameterSetter(obj, parameterSetter)
            obj.parameterSetters{end + 1} = parameterSetter;
        end
        
        function [] = applyParameterSetters(obj, trial)
            for i = 1:length(obj.parameterSetters)
                parameterSetter = obj.parameterSetters{i}();
                parameterSetter.setParametersForTrial(trial);
            end
        end
        
        function addPreprocessorsToTrial(obj, hook, trial)
            if (strcmp(hook, 'beginning'))
                for i = 1:length(obj.dataPreProcessorsBeginning)
                    trial.preprocessors = {obj.dataPreProcessorsBeginning{i}(trial), trial.preprocessors{:}};
                end
            elseif (strcmp(hook, 'end'))
                for i = 1:length(obj.dataPreProcessorsEnd)
                    trial.preprocessors{end + 1} = obj.dataPreProcessorsEnd{i}(trial);
                end
            end
        end
        
        function setupScenarioForLearners(obj, trial)
        end
        
        function [] = registerSamplers(obj, trial)            
        end
        
        function [] = setupSampler(obj, trial)
        end
        
        function addDefaultCriteria(obj, trial, evaluationCriterion)
        end
    end    
    
end

