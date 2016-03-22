classdef PathIntegralPreprocessor < DataPreprocessors.DataPreprocessor & Data.DataManipulator
    
    properties
        stateRewardName;
        actionRewardName;
        pathCostName;
        finalRewardName;
        layer;
        
        dynamicalSystem
        
        uFactor;
    end
    
    properties (SetObservable,AbortSet)
        PathIntegralCostActionMultiplier = 1;
    end
    
    % Class methods
    methods
        function obj = PathIntegralPreprocessor(dataManager, dynamicalSystem, layer, stateRewardName, actionRewardName, finalRewardName, pathCostName)
            obj = obj@DataPreprocessors.DataPreprocessor();
            obj = obj@Data.DataManipulator(dataManager);
            
            obj.dynamicalSystem = dynamicalSystem;
            obj.dynamicalSystem.registerControlNoiseInData();
            
            if (~exist('stateRewardName', 'var'))
                stateRewardName = 'stateRewards';
            end
            
            if (~exist('actionRewardName', 'var'))
                actionRewardName = 'logProbTransUC';
            end
            
            if (~exist('pathCostName', 'var'))
                pathCostName = 'pathCostsToCome';
            end
            
            if (~exist('finalRewardName', 'var'))
                if (dataManager.isDataEntry('finalRewards'))
                    finalRewardName = 'finalRewards';
                else
                    finalRewardName = [];
                end
            end
            
            if (~exist('layer', 'var'))
                layer = 'steps';
            end
            
            obj.finalRewardName = finalRewardName;
            obj.pathCostName = pathCostName;
            obj.actionRewardName = actionRewardName;
            obj.stateRewardName = stateRewardName;
            
            obj.linkProperty('PathIntegralCostActionMultiplier');
            
            obj.dataManager.addDataEntry('steps.logProbTransUC', 1);            
            obj.dataManager.addDataEntry([layer, '.', pathCostName], 1);
            obj.layer = obj.dataManager.getDataManagerDepth(layer);
            
            if (isempty(obj.finalRewardName))
                obj.addDataManipulationFunction('computePathCostsToComePerEpisode', {obj.stateRewardName, obj.actionRewardName}, {obj.pathCostName});
            else
                obj.addDataManipulationFunction('computePathCostsToComePerEpisode', {obj.stateRewardName, obj.actionRewardName, obj.finalRewardName}, {obj.pathCostName});
            end            
        end                    
        
        function [pathCostsToCome] = computePathCostsToComePerEpisode(obj, stateRewards, actionRewards, finalRewards)
            if (obj.layer == 2)
                pathCostsToCome = cumsum(stateRewards(end:-1:1)) / obj.PathIntegralCostActionMultiplier + cumsum(actionRewards(end:-1:1));
                pathCostsToCome = pathCostsToCome(end:-1:1);
            else
                pathCostsToCome = sum(stateRewards) / obj.PathIntegralCostActionMultiplier + sum(actionRewards);
            end
            if (exist('finalRewards', 'var'))
                pathCostsToCome = pathCostsToCome + finalRewards / obj.PathIntegralCostActionMultiplier;
            end
        end
        
        function data = preprocessData(obj, data)
            obj.dynamicalSystem.callDataFunction('getUncontrolledTransitionProbabilities', data);
            for i = 1:data.getNumElements()
                obj.callDataFunction('computePathCostsToComePerEpisode', data, i, :);
            end
        end
        
    end
end
