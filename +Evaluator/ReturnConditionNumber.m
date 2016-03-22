classdef ReturnConditionNumber< Evaluator.Evaluator
   

  
    methods
        function [obj] = ReturnConditionNumber()
            obj = obj@Evaluator.Evaluator('conditionNumber', {'endLoop'}, Experiments.StoringType.ACCUMULATE);          
        end                        
        
        function [evaluation] = getEvaluation(obj, data, newData, trial)               
            
           cov = trial.parameterPolicy.getCovariance;
           evaluation = rcond(cov);
           evaluation = [evaluation cond(cov)];
           fprintf('conditionNumberR: %d conditionNumber: %d\n', evaluation);

 
        end
                
    end   
    
end