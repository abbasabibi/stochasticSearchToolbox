classdef GPRegularizerEvaluator < Evaluator.Evaluator
        
    methods
        function [obj] = GPRegularizerEvaluator() 
            obj = obj@Evaluator.Evaluator('GPRegularizer',{'endLoop'}, Experiments.StoringType.ACCUMULATE);
        end
        
        function [evaluation] = getEvaluation(obj, data, newData, trial)
            evaluation = trial.actionPolicy.outputModels{1,1}.GPRegularizer;
        end
    end
    
end

