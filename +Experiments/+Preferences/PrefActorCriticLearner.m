classdef PrefActorCriticLearner < Experiments.Configurator
    
    methods
        function obj = PrefActorCriticLearner(learnerName)
            obj = obj@Experiments.Configurator(learnerName);
        end
        
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.Configurator(trial);
            
            
            Common.Settings().setProperty('kernelMedianBandwidthFactorStates', 0.1);
                        
            trial.setprop('actorUpdater', @Learner.ActorCritic.PrefREPSStateActionDistribution.CreateFromTrial);
        end
        
        function postConfigureTrial(obj, trial)
           
            trial.actorUpdater = trial.actorUpdater(trial);            
            
            obj.postConfigureTrial@Experiments.Configurator(trial);                                    
        end
        
         function [] = setupScenarioForLearners(obj, trial)            
            obj.setupScenarioForLearners@Experiments.Configurator(trial);
         
            trial.policyEvaluationPreProcessor.addLearner(trial.actorUpdater);     
            trial.scenario.addInitObject(trial.actorUpdater);
            %trial.scenario.addDataPreprocessor(trial.sampleDensityPreprocessor, true);
            
        end
    end
    
end

