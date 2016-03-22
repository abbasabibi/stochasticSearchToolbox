classdef SupervisedLearningMSETrainEvaluator < Evaluator.SupervisedLearningMSEEvaluator 
    
    methods
        function obj = SupervisedLearningMSETrainEvaluator()
            obj = obj@Evaluator.SupervisedLearningMSEEvaluator('Train');
        end
        
        function [data] = getEvaluationData(obj, data, trial)
            data = data;
        end
    end
    
    methods (Static)
        
    end
end

