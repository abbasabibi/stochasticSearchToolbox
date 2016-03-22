classdef NextStateLinearFeatureDiscreteActionQ < Experiments.PolicyEvaluation.PolicyEvaluationNextStateFeatureConfigurator
    
    properties
        
    end
    
    methods
        function obj = NextStateLinearFeatureDiscreteActionQ()
            obj = obj@Experiments.PolicyEvaluation.PolicyEvaluationNextStateFeatureConfigurator('Q');
        end
        
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.PolicyEvaluation.PolicyEvaluationNextStateFeatureConfigurator(trial);
            
            trial.setprop('nextStateActionFeatures', @PolicyEvaluation.DiscreteActionNextStateFeaturesCurrentPolicy.CreateFromTrial);            
        end               
    end
end
