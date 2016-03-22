classdef PolicyEvaluationNextStateFeatureConfigurator < Experiments.Configurator
    
    properties
        
    end
    
    methods
        function obj = PolicyEvaluationNextStateFeatureConfigurator(name)
            obj = obj@Experiments.Configurator(name);
        end
        
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.Configurator(trial);
            
            trial.setprop('optimalPolicy');
            trial.setprop('nextStateActionFeatures');
            
        end
        
        function postConfigureTrial(obj, trial)
            obj.postConfigureTrial@Experiments.Configurator(trial);
            obj.setupOptimalPolicy(trial);
            obj.setupNextStateFeatures(trial);
        end
        
        function [] = setupOptimalPolicy(obj, trial)
            if (~isempty(trial.optimalPolicy))
                trial.optimalPolicy = trial.optimalPolicy(trial);
            end
        end
        
        function [] = setupNextStateFeatures(obj, trial)
            
            trial.nextStateActionFeatures =  trial.nextStateActionFeatures(trial);
        end
        
        function [] = setupScenarioForLearners(obj, trial)
            obj.setupScenarioForLearners@Experiments.Configurator(trial);
        end
    end
end
