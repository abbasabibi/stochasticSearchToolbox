classdef TimeDependentPolicyConfigurator < Experiments.ActionPolicies.ActionPolicyConfigurator
    
    properties
        
    end
    
    methods
        function obj = TimeDependentPolicyConfigurator()
            obj = obj@Experiments.ActionPolicies.ActionPolicyConfigurator('TimeDependentPolicy');
        end
        
        function addDefaultCriteria(obj, trial, evaluationCriterion)            
            obj.addDefaultCriteria@Experiments.ActionPolicies.ActionPolicyConfigurator(trial, evaluationCriterion);
        end
        
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.ActionPolicies.ActionPolicyConfigurator(trial);
                                    
            trial.setprop('actionPolicyPerTimeStep',  @Distributions.Gaussian.GaussianActionPolicy);            
            trial.setprop('actionPolicy',@Distributions.TimeDependent.ComposedTimeDependentPolicy);
            
            trial.setprop('policyLearnerPerTimeStep',  @Learner.SupervisedLearner.LinearGaussianMLLearner);            
            trial.setprop('policyLearner',@Learner.SupervisedLearner.TimeDependentLearner);
        end
        
        function [policy] = createPolicy(obj, trial,  inputFeatures)
            policy = trial.actionPolicy(trial.dataManager, trial.actionPolicyPerTimeStep);
            
        end
        
        function [policyLearner] = createPolicyLearner(obj, trial)
            policyLearner = trial.policyLearner(trial.dataManager, trial.actionPolicy, trial.policyLearnerPerTimeStep);
        end
        
    end
    
end
