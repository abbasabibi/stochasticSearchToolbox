classdef TimeDependentRewardTest < RewardFunctions.TimeDependent.TimeDependentRewardFunction
    
    properties
                       
    end
    
    methods
        function obj = TimeDependentRewardTest(settings,  sampler)
           obj = obj@RewardFunctions.TimeDependent.TimeDependentRewardFunction(settings, sampler);
        end

        function [reward] = rewardFunction(obj, states, actions, nextStates, timeSteps)        
            reward = randn(size(states,1),1);
        end
        
        function [finalReward] = sampleFinalReward(obj, nextStates, timeSteps)        
            finalReward = 1;
        end

    end
    
end