classdef DiscretizedActionConfigurator < Experiments.Configurator
    
    properties
        discreteActionMap
    end
    
    methods
        function obj = DiscretizedActionConfigurator (discreteActionMap)
            obj = obj@Experiments.Configurator('DiscreteAction');
            obj.discreteActionMap = discreteActionMap;
        end
        
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.Configurator(trial);
            
            trial.setprop('actionName', 'discreteActions');
            trial.setprop('discreteActionMap', obj.discreteActionMap);                                                
        end
       
        function postConfigureTrial(obj, trial)
            obj.setupActionDiscretizer(trial);                                  
            obj.postConfigureTrial@Experiments.Configurator(trial);                                 
        end
                
        function [] = setupActionDiscretizer(obj, trial)
            trial.setprop('discreteActionInterpreter',  Distributions.Discrete.DiscreteActionInterpreter(trial.dataManager, trial.discreteActionMap));
        end
                
    end
end
