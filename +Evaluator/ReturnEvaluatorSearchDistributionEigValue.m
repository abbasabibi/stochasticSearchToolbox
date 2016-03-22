
classdef ReturnEvaluatorSearchDistributionEigValue< Evaluator.Evaluator
   

  
    methods
        function [obj] = ReturnEvaluatorSearchDistributionEigValue()
            obj = obj@Evaluator.Evaluator('searchDistributionEigValue', {'endLoop'}, Experiments.StoringType.ACCUMULATE);          
        end                        
        
        function [evaluation] = getEvaluation(obj, data, newData, trial)               
            
           cholAEval = trial.parameterPolicy.cholA;
           evaluation = eig(cholAEval'*cholAEval)';
 
        end
                
    end   
    
end

