classdef ConfiguredLearner < Experiments.Configurator;
    
    properties(SetAccess=protected)
        type;
        
       
    end
    
    methods
        
        function obj = ConfiguredLearner(name, type)
            obj = obj@Experiments.Configurator(name);
            obj.type = type;
        end              
        
        function addDataPreprocessor(obj, hook, dataPreProcessor)
            if (strcmp(hook, 'beginning'))
                obj.dataPreProcessorsBeginning{end + 1} = dataPreProcessor;
            elseif (strcmp(hook, 'end'))
                obj.dataPreProcessorsEnd{end + 1} = dataPreProcessor;
            end
        end
        
        
        
         function preConfigureTrial(obj, trial)            
            trial.setprop('preprocessors', {}, false);
            trial.setprop('initialDataFileName');
            trial.setprop('initialDataFromFileSampler');
            
            trial.setprop('initialLeaner');
            trial.setprop('learner');
            trial.setprop('resetInitialData', 1);
        end
        
        function postConfigureTrial(obj, trial)
            
            obj.setupLearner(trial);
            obj.setupInitialLearner(trial);
            %Common.Settings().setProperty('numIterations', trial.numIterations);
        end
        
        function setupLearner(obj, trial)
            if (~isempty(trial.learner))
                trial.learner=trial.learner(trial);
            end
        end
        
        function setupInitialLearner(obj, trial)
            if (~isempty(trial.initialLeaner))
                trial.initialLeaner=trial.initialLeaner(trial);
            end
        end
        
        function [] = setupSampler(obj, trial)
            trial.setprop('initialDataFromFileSampler');
            if (~isempty(trial.initialDataFileName))
                trial.initialDataFromFileSampler = Sampler.SamplerFromFile(trial.dataManager, trial.initialDataFileName);
            end
        end
        
        function addDefaultCriteria(obj, trial, evaluationCriterion)
            for i = 1:length(trial.learner)
                trial.learner.addDefaultCriteria(trial, evaluationCriterion);
            end
        end
        

        function setupScenarioForLearners(obj, trial)
            if (~isempty(trial.initialDataFromFileSampler))
                trial.scenario.addInitialSampler(trial.initialDataFromFileSampler);
            end
            
            if (~isempty(trial.initialLeaner))
                trial.scenario.addInitialLearner(trial.initialLeaner);
            end
            
            for i = length(trial.preprocessors):-1:1
                trial.scenario.addDataPreprocessor(trial.preprocessors{i}, true);
            end                        
            
            if (~isempty(trial.learner))
                trial.scenario.addLearner(trial.learner);
                trial.scenario.addInitObject(trial.learner); 
            end
        end               
        
        function [] = registerSamplers(obj, trial)
        end        

    end
        
end

