
classdef ActionPolicyConfigurator < Experiments.Configurator
    
    properties
        
    end
    
    methods
        function obj = ActionPolicyConfigurator(policyName)
            obj = obj@Experiments.Configurator(policyName);
        end
        
        function addDefaultCriteria(obj, trial, evaluationCriterion)            
            obj.addDefaultCriteria@ Experiments.Configurator(trial, evaluationCriterion);
        end
        
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.Configurator(trial);
            
            trial.setprop('actionPolicy', []);
            trial.setprop('policyLearner', []);
                        
            trial.setprop('policyInputVariables', []);
            
            trial.setprop('usePolicyForInitialLearner',false)
        end
        
        function postConfigureTrial(obj, trial)
            obj.setupActionPolicy(trial);                                  
            obj.postConfigureTrial@Experiments.Configurator(trial);                                 
        end
        
        function [policy] = createPolicy(~, trial,  inputFeatures)
            policy = trial.settings.actionPolicy(trial.dataManager, inputFeatures);
        end
        
        function [policyLearner] = createPolicyLearner(~, trial)
            policyLearner = trial.settings.policyLearner(trial.dataManager, trial.actionPolicy);
        end
        
        function setupActionPolicy(obj, trial)
                                    
           if (~isempty(trial.settings.actionPolicy)) 
                if (~isempty(trial.settings.policyInputVariables))
                    switch (trial.settings.policyInputVariables)
                        case 'useStateFeatures'
                            trial.actionPolicy=obj.createPolicy(trial, trial.stateFeatures.outputName);
                        case 'usePolicyFeatures'                            
                            trial.actionPolicy=obj.createPolicy(trial, trial.policyFeatures.outputName);
                        case 'states'
                            trial.actionPolicy = obj.createPolicy(trial, 'states');
                        otherwise 
                            trial.actionPolicy=obj.createPolicy(trial, trial.policyFeatures.policyInputVariables);
                    end
                else
                    trial.actionPolicy=obj.createPolicy(trial, 'states');
                end                                
            end
                        
            if (~isempty(trial.policyLearner))
                trial.policyLearner=obj.createPolicyLearner(trial);
            end
        end
        
        function [] = setupScenarioForLearners(~, trial)
            trial.scenario.addInitObject(trial.actionPolicy);   
            if(trial.usePolicyForInitialLearner)
                trial.scenario.addInitialLearner(trial.policyLearner);
            end
        end
    end    
end
