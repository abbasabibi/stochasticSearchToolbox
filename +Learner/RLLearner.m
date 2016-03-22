classdef RLLearner < Learner.Learner
    
   properties

   end
   
   % Class methods
   methods
      function obj = RLLearner(varargin)
            obj = obj@Learner.Learner(varargin{:});
      end 

      function [] = printMessage(obj, data)          
          %fprintf('Average Return: %f\n', mean(data.getDataEntry('returns')));
      end
      
      function [] = addDefaultCriteria(obj, trial, evaluationCriterium)
            
      end
   end
end
