
classdef ReturnEvaluatorSearchDistributionVariance< Evaluator.Evaluator
   

  
    methods
        function [obj] = ReturnEvaluatorSearchDistributionVariance()
            obj = obj@Evaluator.Evaluator('searchDistributionVariance', {'endLoop'}, Experiments.StoringType.ACCUMULATE);          
        end                        
        
        function [evaluation] = getEvaluation(obj, data, newData, trial)               
            
           cholAEval = trial.parameterPolicy.cholA;
           evaluation = diag(cholAEval*cholAEval')';
 
        end
                
    end   
    
end
