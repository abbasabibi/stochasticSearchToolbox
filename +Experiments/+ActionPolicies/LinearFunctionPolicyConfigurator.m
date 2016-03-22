classdef LinearFunctionPolicyConfigurator < Experiments.Configurator
    
    properties
        
    end
    
    methods
        function obj = LinearFunctionPolicyConfigurator()
            obj = obj@Experiments.Configurator('LinearQ');
        end
        
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.Configurator(trial);
            
            trial.setprop('featurePreprocessor', @PolicyEvaluation.DiscreteActionStateFeatureGenerator);
            trial.setprop('featurePreprocessorNext', @PolicyEvaluation.DiscreteActionNextStateFeatures);
            trial.setprop('policyEvaluationFunction', @Functions.ValueFunctions.LinearQFunction);
            
        end
        
        function postConfigureTrial(obj, trial)
            obj.postConfigureTrial@Experiments.Configurator(trial);
            obj.setupPolicyFunction(trial);
        end
        
        function [] = setupPolicyFunction(obj, trial)
            
            trial.featurePreprocessorNext =  trial.featurePreprocessorNext(trial.dataManager,trial.nextStateFeatures.outputName, 'actions');
            trial.featurePreprocessor =  trial.featurePreprocessor(trial.dataManager, trial.stateFeatures.outputName,  'actions');
            
            trial.policyEvaluationFunction = trial.policyEvaluationFunction(trial.dataManager, trial.featurePreprocessor.outputName);
        end
        
        function [] = setupScenarioForLearners(obj, trial)
            obj.setupScenarioForLearners@Experiments.Configurator(trial);
            trial.scenario.addInitObject(trial.policyEvaluationFunction);            
        end
    end
end
