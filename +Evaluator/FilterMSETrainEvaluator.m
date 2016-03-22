classdef FilterMSETrainEvaluator < Evaluator.FilterMSEEvaluator 
    
    methods
        function obj = FilterMSETrainEvaluator()
            obj = obj@Evaluator.FilterMSEEvaluator('Train');
        end
        
        function [data] = getEvaluationData(obj, data, trial)
        end
    end
    
    methods (Static)
        
    end
end

