

classdef ReturnEvaluatorAllSamples < Evaluator.Evaluator
   
    methods
        function [obj] = ReturnEvaluatorAllSamples()
            obj = obj@Evaluator.Evaluator('avgReturnAll', {'endLoop'}, Experiments.StoringType.ACCUMULATE);          
        end                        
        
        function [evaluation] = getEvaluation(obj, data, newData, trial)               
            evaluation = mean(data.getDataEntry('returns'));
            fprintf('avgReturnAll: %f\n', evaluation);
        end
                
    end   
    
end
