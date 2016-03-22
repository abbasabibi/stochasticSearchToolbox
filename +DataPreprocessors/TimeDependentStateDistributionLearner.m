classdef TimeDependentStateDistributionLearner < DataPreprocessors.DataPreprocessor
   %%% time dependent state distrib learner
   properties
       stateDistribLearner;
   end
      
   methods
      function obj = TimeDependentStateDistributionLearner(stateDistribLearner)
          obj = obj@DataPreprocessors.DataPreprocessor();
          obj.stateDistribLearner = stateDistribLearner;
      end 
      
      function data = preprocessData(obj, data)
          obj.stateDistribLearner.updateModel(data);                   
      end      
   end
end

