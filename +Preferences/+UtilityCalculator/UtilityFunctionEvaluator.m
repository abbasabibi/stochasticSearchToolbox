classdef UtilityFunctionEvaluator < Evaluator.Evaluator
        
    methods
        function [obj] = UtilityFunctionEvaluator() 
            obj = obj@Evaluator.Evaluator('utilityFunctionWeights',{'endLoop'}, Experiments.StoringType.ACCUMULATE);
        end
        
        function [evaluation] = getEvaluation(obj, data, newData, trial)
            evaluation = trial.utilityFunctionCalculator.getUtilitiyFunction.weights;
        end
    end
    
end

