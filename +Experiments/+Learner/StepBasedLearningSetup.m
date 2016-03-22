classdef StepBasedLearningSetup < Experiments.ConfiguredLearner
    
    properties
        
    end
    
    methods
        function obj = StepBasedLearningSetup(learnerName, learnerType)
            if (~exist('learnerType','var'))
                learnerType = Experiments.LearnerType.TypeA;
            end
            obj = obj@Experiments.ConfiguredLearner(learnerName, learnerType);
        end
        
        function addDefaultCriteria(obj, trial, evaluationCriterion)            
            obj.addDefaultCriteria@ Experiments.ConfiguredLearner(trial, evaluationCriterion);
        end
        
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.ConfiguredLearner(trial);
            
           
            
            trial.setprop('learner');                        
            trial.setprop('preprocessors'); 
        end
        
        function postConfigureTrial(obj, trial)
            if (~isprop(trial,'stateFeatures'))
                warning('pst: no configured state features found. Maybe you forget to add the feature configurator (before the configurator for the learner');
            else            
                if (strcmp(class(trial.stateFeatures), 'function_handle'))
                    warning('pst: state Features have not been configured, still anonymous function. Maybe you forget to add the feature configurator (before the configurator for the learner');
                end
            end
                                   
                                  
            obj.postConfigureTrial@Experiments.ConfiguredLearner(trial);
                      
            
            %trial.preprocessors = DataPreprocessors.DataProbabilitiesPreprocessor(trial.dataManager, trial.actionPolicy);
           
        end
                                   
      
                     
        function setupLearner(obj, trial)
            if (~isempty(trial.learner))
                trial.learner=trial.learner(trial);
            end
        end
        
        function [] = setupScenarioForLearners(obj, trial)            
            obj.setupScenarioForLearners@Experiments.ConfiguredLearner(trial);         
        end
        
        function registerSamplers(obj, trial)
            obj.registerSamplers@Experiments.ConfiguredLearner(trial);
               
                                
        end           
    end
    
end
