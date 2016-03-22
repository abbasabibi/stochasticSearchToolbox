classdef ReturnKL< Evaluator.Evaluator
   

  
    methods
        function [obj] = ReturnKL()
            obj = obj@Evaluator.Evaluator('trueKL', {'endLoop'}, Experiments.StoringType.ACCUMULATE);          
        end                        
        
        function [evaluation] = getEvaluation(obj, data, newData, trial)               
            
           evaluation = trial.parameterPolicyLearner.KL;
           fprintf('trueKL: %d \n', evaluation);

 
        end
                
    end   
    
end