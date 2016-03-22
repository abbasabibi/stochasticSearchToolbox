classdef PolicyFeatureGenerator< Experiments.Configurator
    %POLICYFEATUREGENERATOR configurator for policy Features
    
   properties
        
    end
    
    methods
        function obj = PolicyFeatureGenerator()
            obj = obj@Experiments.Configurator('PolicyFeatures');
        end
        
        
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.Configurator(trial);
            
            trial.setprop('policyFeatureGenerator', []);

        end
         function postConfigureTrial(obj, trial)
            if (~isempty(trial.policyFeatureGenerator))
                trial.policyFeatureGenerator = trial.policyFeatureGenerator(trial);                                   
            end

        end       

        
        function [] = setupScenarioForLearners(obj, trial)
            if(ismethod(trial.policyFeatureGenerator, 'updateModel'))
                trial.scenario.addLearner(trial.stateFeatures);    
            end
            
            obj.setupScenarioForLearners@Experiments.Configurator(trial);
            if(ismethod(trial.policyFeatureGenerator, 'initObject'))
                trial.scenario.addInitObject(trial.policyFeatureGenerator);    
            end
            
        end
        
        
    end
end

