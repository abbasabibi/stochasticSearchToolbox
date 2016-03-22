classdef PongReturn < RewardFunctions.ReturnForEpisode
    
    properties
                       
    end
    
    methods
        function obj = PongReturn( dataManager)            
           obj = obj@RewardFunctions.ReturnForEpisode(dataManager, 'states');
           
           
        end
        
        
        function [returns] = returnFunction(obj, states)  
            tmp = states(2:end,5);
            returns = sum( states(2:end,5) );
            
            
        end        
    end        
end