classdef ReturnDecayedSummedReward < RewardFunctions.ReturnForEpisode
    
    properties (SetObservable)
        discountFactor;
    end
    
    methods
        function obj = ReturnDecayedSummedReward( dataManager)
           obj = obj@RewardFunctions.ReturnForEpisode(dataManager);
           
           if (~obj.dataManager.isDataEntry('finalRewards'))
               obj.setReturnInputs('rewards');        
           else
               obj.setReturnInputs('rewards', 'finalRewards');        
           end
           obj.linkProperty('discountFactor');
        end
        
        
        function [returns] = returnFunction(obj, rewards, finalRewards)    
            returns = sum(bsxfun(@times,rewards,transpose(obj.discountFactor.^((1:size(rewards,1))-1))));
            if (exist('finalRewards', 'var'))
                returns = returns + finalRewards;
            end
        end        
    end        
end