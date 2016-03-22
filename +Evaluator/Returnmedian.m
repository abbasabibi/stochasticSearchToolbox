classdef Returnmedian < Evaluator.Evaluator
   
   
    
  
    methods
        function [obj] = Returnmedian()
            obj = obj@Evaluator.Evaluator('medReturn', {'endLoop'}, Experiments.StoringType.ACCUMULATE);          
        end                        
        
        function [evaluation] = getEvaluation(obj, data, newData, trial)               
            evaluation = median(newData.getDataEntry('returns'));
            msg = 'medReturn:';
            fprintf('%50s %.3g\n', msg, evaluation);
        end
                
    end   
    
end