classdef RestrictedActions  < Experiments.Configurator
    
    properties
        
    end
    
    methods
        function obj = RestrictedActions()
            obj = obj@Experiments.Configurator('Restricted');
        end
        
        
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.Configurator(trial);
                   
            trial.setprop('restrictedActionsGenerator', @(trial) FeatureGenerators.RestrictedFeatures(trial.dataManager, 'actions'));
        end
        
        function postConfigureTrial(obj, trial)
            trial.restrictedActionsGenerator = trial.restrictedActionsGenerator(trial);
        end
        
        
        function [] = setupScenarioForLearners(obj, trial)
            
            obj.setupScenarioForLearners@Experiments.Configurator(trial);
        end
        
        
    end
end
