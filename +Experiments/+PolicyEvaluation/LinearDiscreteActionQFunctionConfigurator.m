classdef LinearDiscreteActionQFunctionConfigurator < Experiments.Configurator
    
    properties
        
    end
    
    methods
        function obj = LinearDiscreteActionQFunctionConfigurator()
            obj = obj@Experiments.Configurator('LinearQ');
        end
        
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.Configurator(trial);
            
            trial.setprop('stateActionFeatures', @PolicyEvaluation.DiscreteActionStateFeatureGenerator);
            %trial.setprop('featurePreprocessorNext', @PolicyEvaluation.DiscreteActionNextStateFeatures);
            trial.setprop('policyEvaluationFunction', @Functions.ValueFunctions.LinearQFunction);
            
        end
        
        function postConfigureTrial(obj, trial)
            obj.postConfigureTrial@Experiments.Configurator(trial);
            obj.setupPolicyFunction(trial);
        end
        
        function [] = setupPolicyFunction(obj, trial)
            
            %trial.featurePreprocessorNext =  trial.featurePreprocessorNext(trial.dataManager,trial.nextStateFeatures.outputName, trial.actionName);
            trial.stateActionFeatures =  trial.stateActionFeatures(trial.dataManager, trial.stateFeatures.outputName,  trial.discActionName);
            
            trial.policyEvaluationFunction = trial.policyEvaluationFunction(trial.dataManager, trial.stateActionFeatures.outputName);
        end
        
        function [] = setupScenarioForLearners(obj, trial)
            obj.setupScenarioForLearners@Experiments.Configurator(trial);
            trial.scenario.addInitObject(trial.policyEvaluationFunction);            
        end
    end
end
