classdef ReturnEvaluatorNewSamples < Evaluator.Evaluator
   
   
    
  
    methods
        function [obj] = ReturnEvaluatorNewSamples()
            obj = obj@Evaluator.Evaluator('avgReturn', {'endLoop'}, Experiments.StoringType.ACCUMULATE);          
        end                        
        
        function [evaluation] = getEvaluation(obj, data, newData, trial)               
            evaluation = mean(newData.getDataEntry('returns'));
            msg = 'avgReturn:';
            fprintf('%50s %.3g\n', msg, evaluation);
        end
                
    end   
    
end