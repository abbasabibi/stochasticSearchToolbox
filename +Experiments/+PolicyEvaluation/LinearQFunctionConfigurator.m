classdef LinearQFunctionConfigurator < Experiments.Configurator
    
    properties
        
    end
    
    methods
        function obj = LinearQFunctionConfigurator()
            obj = obj@Experiments.Configurator('LinearQ');
        end
        
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.Configurator(trial);
                        
            trial.setprop('policyEvaluationFunction', @Functions.ValueFunctions.LinearQFunction);
            
        end
        
        function postConfigureTrial(obj, trial)
            obj.postConfigureTrial@Experiments.Configurator(trial);
            obj.setupPolicyFunction(trial);
        end
        
        function [] = setupPolicyFunction(obj, trial)
                        
            trial.policyEvaluationFunction = trial.policyEvaluationFunction(trial.dataManager, trial.stateActionFeatures.outputName);
            trial.policyEvaluationFunction.setFeatureGenerator(trial.stateActionFeatures);
        end
        
        function [] = setupScenarioForLearners(obj, trial)
            obj.setupScenarioForLearners@Experiments.Configurator(trial);
            trial.scenario.addInitObject(trial.policyEvaluationFunction);            
        end
    end
end
