classdef PreferenceCountEvaluator < Evaluator.Evaluator
   
   
    
  
    methods
        function [obj] = PreferenceCountEvaluator()
            obj = obj@Evaluator.Evaluator('reqPrefs', {'endLoop'}, Experiments.StoringType.ACCUMULATE);          
        end                        
        
        function [evaluation] = getEvaluation(obj, data, newData, trial)               
            evaluation = trial.preferenceGenerator.prefCount;
            fprintf('Requested preferences(total) : %d\n', evaluation);
        end
                
    end   
    
end