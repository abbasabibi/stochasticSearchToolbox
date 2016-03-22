classdef BayesianOptimisationLearningSetup < Experiments.Learner.BanditLearningSetup
    
    properties
        
    end
    
    methods
        function obj = BayesianOptimisationLearningSetup(learnerName)
            obj = obj@Experiments.Learner.BanditLearningSetup(learnerName);
        end
        
      
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.Learner.BanditLearningSetup(trial);
            
            trial.setprop('parameterPolicy', @BayesianOptimisation.Opt.BayesianOptimisationPolicy);            
            trial.setprop('parameterPolicyLearner', []);
                        
            trial.setprop('learner', @BayesianOptimisation.Opt.BayesianOptimisation.CreateFromTrial);                        
        end
        
     
        
    end
    
end
