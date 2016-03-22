classdef Returnmax < Evaluator.Evaluator
   
   
    
  
    methods
        function [obj] = Returnmax()
            obj = obj@Evaluator.Evaluator('maxReturn', {'endLoop'}, Experiments.StoringType.ACCUMULATE);          
        end                        
        
        function [evaluation] = getEvaluation(obj, data, newData, trial)               
            evaluation = max(newData.getDataEntry('returns'));
            msg = 'maxReturn:';
            fprintf('%50s %.3g\n', msg, evaluation);
        end
                
    end   
    
end