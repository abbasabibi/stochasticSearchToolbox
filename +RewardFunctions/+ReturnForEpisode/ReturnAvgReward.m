classdef ReturnAvgReward < RewardFunctions.ReturnForEpisode
    
    properties
                       
    end
    
    methods
        function obj = ReturnAvgReward( dataManager)
           obj = obj@RewardFunctions.ReturnForEpisode(dataManager);
           

           obj.setReturnInputs('rewards');        

        end
        
        
        function [returns] = returnFunction(obj, rewards)                    
            returns = sum(rewards) / numel(rewards);
            
        end        
    end        
end