classdef ExperimentFromConfigurators < Experiments.Experiment
    
    
    properties(SetAccess=private)
        
        configurators
        evalCriterion;
        
        numIterations
    end
    
    properties
    end
    
    
    methods (Static)
        function [experimentName] = getTaskName(configurators)
            
            experimentName = configurators{1}.name;
            for i = 2:length(configurators)
                experimentName = [experimentName, '_', configurators{i}.name];
            end
        end
        
    end
    
    methods
        
        
        function obj = ExperimentFromConfigurators(category, configurators, evalCriterion, numIterations)
            obj = obj@Experiments.Experiment(category,  Experiments.ExperimentFromConfigurators.getTaskName(configurators));
            obj.numIterations = numIterations;
            
            obj.configurators = configurators;
            obj.evalCriterion = evalCriterion;
            
            %Common.Settings().clean();
            obj.defaultTrial = obj.createTrial(Common.Settings(), obj.path, 0);            
            obj.defaultSettings = obj.defaultTrial.settings;                       
        end
        
        
        
        
        function [trial] = createTrial(obj, settings, evalPath, trialIdx)
            if (~isempty(obj.configurators))
                trial = Experiments.TrialFromConfigurators(settings, evalPath, ...
                    trialIdx, obj.configurators, obj.evalCriterion, obj.numIterations);
            else
                trial = [];
            end
        end
        
    end
    
    
end

