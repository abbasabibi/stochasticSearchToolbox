classdef RewardToComePreprocessor < DataPreprocessors.DataPreprocessor & Data.DataManipulator
    
   properties
      rewardName;
      rewardToComeName;
      finalRewardName;
      layer;
   end
   
   % Class methods
   methods
      function obj = RewardToComePreprocessor(dataManager, rewardName, finalRewardName, rewardToComeName, layer)
            obj = obj@DataPreprocessors.DataPreprocessor();
            obj = obj@Data.DataManipulator(dataManager);
            
            
            if (~exist('rewardName', 'var'))
                rewardName = 'rewards';
            end
            
            if (~exist('rewardToComeName', 'var'))
                rewardToComeName = 'rewardsToCome';
            end
            
            if (~exist('finalRewardName', 'var'))
                finalRewardName = 'finalRewards';
            end
            
            if (~exist('layer', 'var'))
                layer = 'steps';
            end
            
            obj.finalRewardName = finalRewardName;                     
            obj.rewardToComeName = rewardToComeName;
            obj.rewardName = rewardName;
            obj.dataManager.addDataEntry([layer, '.', rewardToComeName], 1);
            obj.layer = obj.dataManager.getDataManagerDepth(layer);
            
            if (isempty(obj.finalRewardName))
                obj.addDataManipulationFunction('computeRewardToComePerEpisode', {obj.rewardName}, {obj.rewardToComeName});
            else
                obj.addDataManipulationFunction('computeRewardToComePerEpisode', {obj.rewardName, obj.finalRewardName}, {obj.rewardToComeName});
            end
            
      end 
      
      function [rewardsToCome] = computeRewardToComePerEpisode(obj, rewards, finalRewards)
            if (obj.layer == 2)
                rewardsToCome = cumsum(rewards(end:-1:1));
                rewardsToCome = rewardsToCome(end:-1:1);
            else
                rewardsToCome = sum(rewards);
            end
            
            if (exist('finalRewards', 'var'))
                rewardsToCome = rewardsToCome + finalRewards;
            end
        end   
            
      function data = preprocessData(obj, data)
           for i = 1:data.getNumElements()
                obj.callDataFunction('computeRewardToComePerEpisode', data, i, :);
           end
      end
   
   end
end
