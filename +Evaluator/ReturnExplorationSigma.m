classdef ReturnExplorationSigma < Evaluator.Evaluator
   

  
    methods
        function [obj] = ReturnExplorationSigma()
            obj = obj@Evaluator.Evaluator('explorationSigma', {'endLoop'}, Experiments.StoringType.ACCUMULATE);          
        end                        
        
        function [evaluation] = getEvaluation(obj, data, newData, trial)               
            
           [mu, sigma] = trial.actionPolicy.callDataFunctionOutput('getExpectationAndSigma', data);
           evaluation = mean(sigma);
           fprintf('Sigma:\n');
           evaluation

 
        end
                
    end   
    
end