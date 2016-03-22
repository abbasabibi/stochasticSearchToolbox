classdef SupervisedLearner < Experiments.ConfiguredLearner
    
    properties
    end
    
    methods
        function obj = SupervisedLearner(learnerName)
            obj = obj@Experiments.ConfiguredLearner(learnerName, Experiments.LearnerType.TypeA);
        end
        
        
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.ConfiguredLearner(trial);
            
%             trial.setprop('contextFeatures', @FeatureGenerators.SquaredFeatures);            

            trial.setprop('functionApproximator');
            trial.setprop('learningAlgorithm');            
            
        end
        
        function postConfigureTrial(obj, trial)
            
            obj.setupFunctionApproximator(trial);
            obj.setupLearningAlgorithm(trial);
            
            obj.postConfigureTrial@Experiments.ConfiguredLearner(trial);
        
        end
        
        
        function [] = setupScenarioForLearners(obj, trial)
            
            obj.setupScenarioForLearners@Experiments.ConfiguredLearner(trial);
            
            trial.scenario.addInitObject(trial.functionApproximator);
            trial.scenario.addLearner(trial.learningAlgorithm);
        end
        
        function addDefaultCriteria(obj, trial, evaluationCriterion)
            obj.addDefaultCriteria@ Experiments.ConfiguredLearner(trial, evaluationCriterion);
            if (~isempty(trial.learner))
                trial.learner.addDefaultCriteria(trial, evaluationCriterion);
            end
            evaluationCriterion.registerEvaluator(Evaluator.SupervisedLearningMSETrainEvaluator());
            if (~isempty(trial.fileNameTest))
                evaluationCriterion.registerEvaluator(Evaluator.SupervisedLearningMSETestEvaluator());            
            end
        end   
    end
    
end


