classdef RmatrixEvaluation < Evaluator.Evaluator
   

  
    methods
        function [obj] = RmatrixEvaluation()
            obj = obj@Evaluator.Evaluator('RmatrixEvaluation', {'endLoop'}, Experiments.StoringType.ACCUMULATE);          
        end                        
        
        function [evaluation] = getEvaluation(obj, data, newData, trial)               
           R = trial.learner.Raa; 
          
           if(all(eig(R)<0))
          
           evaluation = 0;
           
          else
              
          evaluation = 1;
          fprintf('Warning: The R matrix is not negative definite\n');
          end
          
        end
                
    end   
    
end