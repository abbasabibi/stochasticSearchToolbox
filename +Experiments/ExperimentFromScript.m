classdef ExperimentFromScript < Experiments.Experiment
    
    
    properties(SetAccess=private)
        scriptName
    end
  
    
    
   
    
    methods
        
        
        function obj = ExperimentFromScript(category, scriptName)
            obj = obj@Experiments.Experiment(category,  scriptName);
            obj.scriptName = scriptName;
            
            obj.defaultTrial = obj.createTrial(Common.Settings(), obj.path, 0);            
            obj.defaultSettings = obj.defaultTrial.settings;   
                 
        end
                        
        
        function [trial] = createTrial(obj, settings, evalPath, trialIdx)
            
            trial = Experiments.TrialFromScript(settings, evalPath, ...
                    trialIdx, obj.scriptName);            
        end
        
    end
    
    
end

