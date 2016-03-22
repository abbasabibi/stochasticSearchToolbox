classdef NextStateLinearFeatureDiscreteActionSARSA < Experiments.PolicyEvaluation.PolicyEvaluationNextStateFeatureConfigurator
    
    properties
        
    end
    
    methods
        function obj = NextStateLinearFeatureDiscreteActionSARSA()
            obj = obj@Experiments.PolicyEvaluation.PolicyEvaluationNextStateFeatureConfigurator('SARSA');
        end
        
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.PolicyEvaluation.PolicyEvaluationNextStateFeatureConfigurator(trial);
            
            trial.setprop('nextStateActionFeatures', @PolicyEvaluation.DiscreteActionNextStateFeatures.CreateFromTrial);            
        end               
    end
end
