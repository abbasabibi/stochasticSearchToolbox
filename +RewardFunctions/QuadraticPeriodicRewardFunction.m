classdef QuadraticPeriodicRewardFunction < RewardFunctions.QuadraticRewardFunction
        
    methods
        function obj = QuadraticPeriodicRewardFunction(dataManager)
           obj = obj@RewardFunctions.QuadraticRewardFunction(dataManager);
           obj.usePerioridicity = true;

        end
  
    end
    
end