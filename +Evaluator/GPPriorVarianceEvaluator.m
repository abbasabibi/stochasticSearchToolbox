classdef GPPriorVarianceEvaluator < Evaluator.Evaluator
        
    methods
        function [obj] = GPPriorVarianceEvaluator() 
            obj = obj@Evaluator.Evaluator('GPPriorVariance',{'endLoop'}, Experiments.StoringType.ACCUMULATE);
        end
        
        function [evaluation] = getEvaluation(obj, data, newData, trial)
            evaluation = trial.actionPolicy.outputModels{1,1}.GPPriorVariance;
        end
    end
    
end

