classdef RankingEvaluator < Evaluator.Evaluator
        
    methods
        function [obj] = RankingEvaluator() 
            obj = obj@Evaluator.Evaluator('ranks',{'endLoop'}, Experiments.StoringType.STORE_PER_ITERATION);
        end
        
        function [evaluation] = getEvaluation(obj, data, newData, trial)
            evaluation = data.getDataEntry('returnsranks');
        end
    end
    
end

