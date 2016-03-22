classdef TestRewardFunction < RewardFunctions.RewardFunction    
    properties
                       
    end
    
    methods
        function obj = TestRewardFunction( stepSampler)
           obj = obj@RewardFunctions.RewardFunction(stepSampler);           
        end
        
        function [rewards] = rewardFunction(obj, states, actions, varargin)        
            rewards = - sum(states.^2, 2);
        end
    end    
end