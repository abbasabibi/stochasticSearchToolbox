
classdef ReturnEvaluatorSearchDistributionMean < Evaluator.Evaluator
   

  
    methods
        function [obj] = ReturnEvaluatorSearchDistributionMean()
            obj = obj@Evaluator.Evaluator('searchDistributionMean', {'endLoop'}, Experiments.StoringType.ACCUMULATE);          
        end                        
        
        function [evaluation] = getEvaluation(obj, data, newData, trial)               
            
            evaluation=[trial.parameterPolicy.bias', trial.parameterPolicy.weights(:)'];
 
        end
                
    end   
    
end