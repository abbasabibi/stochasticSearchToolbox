classdef DirectPolicyLearner < Experiments.Configurator
    
    methods
        function obj = DirectPolicyLearner(learnerName)
            obj = obj@Experiments.Configurator(learnerName);
        end
        
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.Configurator(trial);
            
            trial.setprop('actorUpdater', @Learner.ActorCritic.DirectPolicyIteration.CreateFromTrial);
        end
        
        function postConfigureTrial(obj, trial)
           
            trial.actorUpdater = trial.actorUpdater(trial);
            
            obj.postConfigureTrial@Experiments.Configurator(trial);                                    
        end
        
         function [] = setupScenarioForLearners(obj, trial)            
            obj.setupScenarioForLearners@Experiments.Configurator(trial);
         
            trial.policyEvaluationPreProcessor.addLearner(trial.actorUpdater);     
            trial.scenario.addInitObject(trial.actorUpdater);
        end
    end
    
end

